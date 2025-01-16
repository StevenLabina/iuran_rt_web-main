import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:iuran_rt_web/drawer.dart';
import 'dart:convert';

import 'package:iuran_rt_web/url.dart';
import 'package:iuran_rt_web/main.dart';
import 'package:iuran_rt_web/screens/buat_warga.dart';
import 'package:url_launcher/url_launcher.dart';

class BuatWargaPageCsv extends StatefulWidget {
  @override
  _BuatWargaCsvPageState createState() => _BuatWargaCsvPageState();
}

class _BuatWargaCsvPageState extends State<BuatWargaPageCsv> {
  String? fileName; // Variable to hold the name of the imported file.
  List<List<dynamic>>? importedData; // Variable to store the imported CSV data.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ketentuanDialog();
    });
  }

  Future<void> downloadExcel() async {
    const excelPath = 'uploads/Template Data Warga.xlsx';

    final excelUrl = Uri.parse(excelPath.startsWith('http')
        ? excelPath
        : '${ApiUrls.baseUrl}/$excelPath');

    if (await canLaunchUrl(excelUrl)) {
      await launchUrl(excelUrl, mode: LaunchMode.externalApplication);
      Fluttertoast.showToast(msg: 'Unduh Excel...');
    } else {
      Fluttertoast.showToast(msg: 'Tidak Bisa Unduh Excel file.');
    }
  }

  // Method to pick Excel file
  Future<void> pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      setState(() {
        fileName = result.files.single.name;
      });

      if (kIsWeb) {
        // Web: Access bytes instead of path
        Uint8List fileBytes = result.files.single.bytes!;
        convertExcelToCsv(fileBytes);
      } else {
        // Mobile: Access file path
        String path = result.files.single.path!;
        convertExcelToCsvFromPath(path);
      }
    } else {
      Fluttertoast.showToast(msg: 'Tidak ada file yang dipilih');
    }
  }

  // Method to convert Excel to CSV
  Future<void> convertExcelToCsv(Uint8List fileBytes) async {
    var excel = Excel.decodeBytes(fileBytes);
    List<List<dynamic>> rows = [];

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]?.rows ?? []) {
        List<dynamic> rowData = [];
        for (var cell in row) {
          if (cell != null) {
            rowData.add(cell
                .value); // Access the value of the cell, not the whole cell object
          } else {
            rowData.add(""); // Handle null cells gracefully
          }
        }
        rows.add(rowData);
      }
    }

    setState(() {
      importedData = rows;
    });
  }

// Method to convert Excel to CSV from path
  Future<void> convertExcelToCsvFromPath(String path) async {
    var bytes = File(path).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    List<List<dynamic>> rows = [];

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]?.rows ?? []) {
        List<dynamic> rowData = [];
        for (var cell in row) {
          if (cell != null) {
            rowData.add(cell.value);
          } else {
            rowData.add("");
          }
        }
        rows.add(rowData);
      }
    }

    setState(() {
      importedData = rows;
    });
  }

  Future<void> saveImportedData() async {
    if (importedData == null || importedData!.isEmpty) {
      Fluttertoast.showToast(
          msg: "Tidak ada data yang diimpor", toastLength: Toast.LENGTH_SHORT);
      return;
    }

    // Convert imported data to CSV
    String csvData = const ListToCsvConverter().convert(importedData!);

    // Upload CSV data to server
    final response = await http.post(
      Uri.parse('${ApiUrls.baseUrl}/import_warga.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'csv_data': csvData},
    );

    final result = jsonDecode(response.body);
    if (result['result'] == 'success') {
      Fluttertoast.showToast(
          msg: "Data Berhasil Diimpor",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal mengimpor data')));
    }
  }

  void _ketentuanDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ketentuan Impor File Excel Data Warga"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Unduh file template Excel "Template Data Warga.xlsx" \n'
                  ' (File ini berisi format yang harus diikuti untuk memasukkan data warga)\n\n'
                  '2. Isi data warga ke dalam file Excel yang sudah diunduh\n'
                  ' (Tambahkan data sesuai format tabel yang tersedia)\n\n'
                  '3. Unggah file dengan mengklik tombol di sebelah kanan kolom input teks\n'
                  ' (Pilih file Excel yang sudah Anda isi)\n\n'
                  '4. Unggah file dengan mengklik tombol di sebelah kanan kolom input teks\n'
                  ' (Pilih file PDF yang sudah Anda buat)\n\n'
                  '5. Setelah memilih file, tekan tombol "Impor Excel" untuk memproses data\n\n'
                  'Catatan Penting:\n'
                  '-Jangan menambahkan baris header/judul baru pada bagian atas tabel\n'
                  '-Pastikan semua data yang dimasukkan sesuai format',
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

  void _showConfirmationDialog() {
    if (TextEditingController(text: fileName).text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Tidak ada file excel yang diimpor",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi"),
          content: Text(
              "Apakah Anda yakin ingin mengimpor file Excel ini? Pastikan file sudah sesuai dengan ketentuan yang tertera sebelum melanjutkan."),
          actions: [
            TextButton(
              child: Text("Tidak"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Ya"),
              onPressed: () {
                saveImportedData();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFDECE8),
      
      ),
      drawer: MyDrawer(),
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
                            'assets/images/UserPlus.svg',
                            color: Colors.black,
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(width: 20),
                          Text(
                            'Isi Data Warga',
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
                    Container(
                      width: 567,
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Tombol pertama
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BuatWargaPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              'Manual',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          // Tombol kedua
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              'Excel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Ketentuan kolom excel"),
                        SizedBox(width: 3),
                         InkWell(
                          onTap: _ketentuanDialog, // Fungsi yang dijalankan saat diklik
                          child: Text(
                            'Klik Disini',
                            style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                          ),
                        ),
                       
                      ],
                    ),
                  
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Unduh Template Excel:"),
                        SizedBox(width: 3),
                         InkWell(
                          onTap: downloadExcel, 
                          child: Text(
                            'Template Data Warga.xlsx',
                            style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
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
                          // TextField di kiri
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
                                hintText: 'Tidak Ada File Yang Dipilih',
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          // Tombol di kanan
                          Container(
                            width: 100,
                            height: 60,
                            decoration: ShapeDecoration(
                              color: Color(0xFFED401C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: TextButton(
                              onPressed: pickExcelFile,
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Colors.white, 
                              ),
                              child: Text("Pilih File"),
                            ),
                          ),
                        ],
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
                          onPressed: _showConfirmationDialog,
                          child: Text(
                            'Impor Excel',
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
