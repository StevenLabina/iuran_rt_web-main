import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:iuran_rt_web/url.dart';
import 'package:url_launcher/url_launcher.dart';

class BuatWargaPagePdf extends StatefulWidget {
  final String no_kk;

  BuatWargaPagePdf({required this.no_kk});

  @override
  _BuatWargaPagePdfState createState() => _BuatWargaPagePdfState();
}

class _BuatWargaPagePdfState extends State<BuatWargaPagePdf> {
  String fileName = '';
  File? selectedFile;
  Uint8List? fileBytes; // Untuk web
  String? pdfUrl;

  Future<void> pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        fileName = result.files.single.name;
        if (kIsWeb) {
          // Platform web
          fileBytes = result.files.single.bytes;
        } else {
          // Platform non-web
          selectedFile = File(result.files.single.path!);
        }
      });
    } else {
      Fluttertoast.showToast(msg: 'No file selected.');
    }
  }

  Future<void> uploadPdfToServer() async {
    if ((kIsWeb && fileBytes == null) || (!kIsWeb && selectedFile == null)) {
      Fluttertoast.showToast(msg: 'Please select a file first.');
      return;
    }

    try {
      final uri = Uri.parse('${ApiUrls.baseUrl}/savePath.php');
      final request = http.MultipartRequest('POST', uri)
        ..fields['no_kk'] = widget.no_kk;

      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes!,
          filename: fileName,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          selectedFile!.path,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        //final responseBody = await response.stream.bytesToString();
        Fluttertoast.showToast(
            msg: 'File uploaded and path saved successfully.');
      } else {
        Fluttertoast.showToast(msg: 'Failed to upload file.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'An error occurred: $e');
    }
  }

  Future<void> fetchPdfPath() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}/getPdfPath.php?no_kk=${widget.no_kk}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pdfUrl = data['pdf_kk'];
        });
      } else {
        Fluttertoast.showToast(msg: 'Failed to fetch PDF path.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'An error occurred: $e');
    }
  }

  void _ketentuanDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ketentuan Upload/Update File Kartu Keluarga"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Scan kartu keluarga anda\n'
                  ' (Pastikan hasil scan terlihat jelas dan semua informasi dapat terbaca dengan baik)\n\n'
                  '2. Ubah hasil scan menjadi file berformat PDF\n'
                  ' (Gunakan aplikasi atau perangkat lunak untuk menyimpan hasil scan dalam format PDF)\n\n'
                  '3. Gunakan format penamaan file berikut:\n'
                  ' kartuKeluarga_noKK\n'
                  ' Contoh: kartuKeluarga_123456789113\n\n'
                  '4. Unggah file dengan mengklik tombol di sebelah kanan kolom input teks\n'
                  ' (Pilih file PDF yang sudah Anda buat)\n\n'
                  '5. Setelah memilih file, tekan tombol "Update File KK" untuk menyimpan\n',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Ya"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> openPdf() async {
    if (pdfUrl == null || pdfUrl!.isEmpty) {
      Fluttertoast.showToast(msg: 'No PDF available.');
      return;
    }

    final uri = Uri.parse(
        pdfUrl!.startsWith('http') ? pdfUrl! : '${ApiUrls.baseUrl}/$pdfUrl');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(msg: 'Could not open PDF.');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ketentuanDialog();
    });
    fetchPdfPath();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFDECE8),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/pexels-thelazyartist-1642125.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Color(0xFFFDECE8),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title Container
                    Container(
                      width: 567,
                      height: 102,
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/UsersFour.svg',
                            color: Colors.black,
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(width: 20),
                          Text(
                            'File PDF Kartu Keluarga',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF181C14),
                              fontSize: 40,
                              fontFamily: 'Figtree',
                              fontWeight: FontWeight.w600,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Text field to display file name
                    
                     Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Ketentuan Upload/Update File Kartu Keluarga"),
                        SizedBox(width: 3),
                        TextButton(
                          onPressed: _ketentuanDialog,
                          child: Text(
                            'Klik Disini',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                   
                    SizedBox(height: 20),
                    Container(
                      width: 500,
                      height: 80,
                      padding: const EdgeInsets.all(20),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Color(0xFFB7B9B6)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              readOnly: true,
                              obscureText: false,
                              controller: TextEditingController(text: fileName),
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                hintText: 'Nama File Pdf',
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: ShapeDecoration(
                              color: Color(0xFFED401C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: TextButton(
                              onPressed: pickPdfFile,
                              child: Icon(
                                Icons.upload_file,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Buka File PDF:'),

                    TextButton(
                      onPressed:
                          pdfUrl != null && pdfUrl!.isNotEmpty ? openPdf : null,
                      child: Text(
                        pdfUrl != null && pdfUrl!.isNotEmpty
                            ? pdfUrl!.split('/').last
                            : 'Tidak ada PDF tersedia',
                        style: TextStyle(
                          color: pdfUrl != null && pdfUrl!.isNotEmpty
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                   
                    
                    Center(
                      child: Container(
                        width: 500,
                        height: 60,
                        decoration: ShapeDecoration(
                          color: Color(0xFFED401C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            uploadPdfToServer(); 
                            Navigator.of(context)
                                .pop(); 
                          },
                          child: Text(
                            'Update File KK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Figtree',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
