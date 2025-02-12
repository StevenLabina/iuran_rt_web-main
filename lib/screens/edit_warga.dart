import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:iuran_rt_web/url.dart';

class EditDataWargaPage extends StatefulWidget {
  final int id;

  EditDataWargaPage({required this.id});

  @override
  _EditDataWargaPageState createState() => _EditDataWargaPageState();
}

class _EditDataWargaPageState extends State<EditDataWargaPage> {
  final TextEditingController _noKavlingController = TextEditingController();
  final TextEditingController _namaPenanggungJawabController =
      TextEditingController();
  final TextEditingController _namaPemilikRumahController =
      TextEditingController();
  final TextEditingController _alamatKavlingController =
      TextEditingController();
  final TextEditingController _noTelponPemilikRumahController =
      TextEditingController();
  final TextEditingController _noTelponPenanggungJawabController =
      TextEditingController();
  final TextEditingController _noKkPemilikRumahController =
      TextEditingController();
  final TextEditingController _noKkPenanggungJawabController =
      TextEditingController();
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchWargaData();
  }

  Future<void> fetchWargaData() async {
    try {
      final response = await http
          .get(Uri.parse("${ApiUrls.baseUrl}/getWarga.php?id=${widget.id}"));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['result'] == 'success') {
          setState(() {
            _noKavlingController.text = json['data']['no_kavling'];
            _namaPenanggungJawabController.text =
                json['data']['nama_penanggung_jawab'];
            _namaPemilikRumahController.text =
                json['data']['nama_pemilik_rumah'];
            _alamatKavlingController.text = json['data']['alamat_kavling'];
            _noTelponPemilikRumahController.text =
                json['data']['no_telpon_pemilik_rumah'];
            _noTelponPenanggungJawabController.text =
                json['data']['no_telpon_penanggung_jawab'];
            _noKkPemilikRumahController.text =
                json['data']['no_kk_pemilik_rumah'];
            _noKkPenanggungJawabController.text =
                json['data']['no_kk_penanggung_jawab'];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = json['message'];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to connect to server';
        isLoading = false;
      });
    }
  }
  // Future<void> kirimNotifikasiWA() async {
  //   final urlNotifikasiWA = '${ApiUrls.baseUrl}/send_whatsapp_pengurus.php';
  //   try {
  //     final responseNotifikasiWA = await http.post(
  //       Uri.parse(urlNotifikasiWA),
  //       body: {
  //         'msg':
  //             "PENGUMUMAN IURAN RT ONLINE\nProfil Warga Anda telah diupdate",
  //         'id': widget.id.toString(),
  //       },
  //     );

  //     if (responseNotifikasiWA.statusCode == 200) {
  //       final jsonResponseNotifikasiWA = jsonDecode(responseNotifikasiWA.body);

  //       // Konversi status menjadi integer untuk memastikan kompatibilitas
  //       final status = jsonResponseNotifikasiWA['status'];
  //       final statusInt =
  //           status is int ? status : int.tryParse(status.toString()) ?? 0;

  //       if (statusInt == 1) {
  //         print('Notifikasi WhatsApp berhasil dikirim');
  //       } else {
  //         print(
  //             'Gagal mengirim notifikasi WhatsApp: ${jsonResponseNotifikasiWA['reason']}');
  //       }
  //     } else {
  //       print(
  //           'Gagal mengirim notifikasi WhatsApp: ${responseNotifikasiWA.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error: Gagal terhubung ke server WhatsApp $e');
  //   }
  // }
  Future<void> updateWargaData() async {
    try {
      final response = await http.post(
        Uri.parse("${ApiUrls.baseUrl}/updateWarga.php"),
        body: {
          'id': widget.id.toString(),
          'no_kavling': _noKavlingController.text,
          'nama_penanggung_jawab': _namaPenanggungJawabController.text,
          'nama_pemilik_rumah': _namaPemilikRumahController.text,
          'alamat_kavling': _alamatKavlingController.text,
          'no_telpon_pemilik_rumah': _noTelponPemilikRumahController.text,
          'no_telpon_penanggung_jawab': _noTelponPenanggungJawabController.text,
          'no_kk_pemilik_rumah': _noKkPemilikRumahController.text,
          'no_kk_penanggung_jawab': _noKkPenanggungJawabController.text,
        },
      );

      final json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        Fluttertoast.showToast(
            msg: "Update data warga berhasil",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black38,
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(json['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update data: $e")),
      );
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFFDECE8),
          title:
              Text('Konfirmasi', style: GoogleFonts.lato(color: Colors.black)),
          content: Text('Apakah Anda yakin ingin memperbarui data warga ini?',
              style: GoogleFonts.lato(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal', style: GoogleFonts.lato(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                updateWargaData();
                //kirimNotifikasiWA();
              },
              child: Text('Ya', style: GoogleFonts.lato(color: Colors.red)),
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
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 567,
                      height: 102,
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.person,
                              size: 40, color: Color.fromARGB(255, 0, 0, 0)),
                          const SizedBox(width: 20),
                          Text(
                            'Ubah Data Warga',
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
                    Text('Kavling',
                        style:
                            TextStyle(color: Color(0xFF909090), fontSize: 18)),
                    Container(
                      width: 1000,
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Color(0xFFB7B9B6)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // No Kavling
                          Text(
                            'No Kavling',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Color(0xFF909090)),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _noKavlingController,
                                  enabled: false,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    hintText: 'No Kavling',
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16),

                          // Alamat Kavling
                          Text(
                            'Alamat Kavling',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_city,
                                  color: Color(0xFF909090)),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _alamatKavlingController,
                                  enabled: false,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    hintText: 'Alamat Kavling',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Pemilik Rumah',
                        style:
                            TextStyle(color: Color(0xFF909090), fontSize: 18)),
                    Container(
                      width: 1000,
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Color(0xFFB7B9B6)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama
                          Text(
                            'Nama',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.person, color: Color(0xFF909090)),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _namaPemilikRumahController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    hintText: 'Nama',
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16),

                          // No KK
                          Text(
                            'No KK',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.person, color: Color(0xFF909090)),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _noKkPemilikRumahController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    hintText: 'No KK',
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16),

                          
                          Text(
                            'No Telpon',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.call, color: Color(0xFF909090)),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _noTelponPemilikRumahController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    hintText: 'No Telpon',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Penanggung Jawab',
                        style:
                            TextStyle(color: Color(0xFF909090), fontSize: 18)),
                  Container(
                      width: 1000,
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Color(0xFFB7B9B6)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama
                          Text(
                            'Nama',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.person, color: Color(0xFF909090)),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _namaPenanggungJawabController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    hintText: 'Nama',
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16),

                          // No KK
                          Text(
                            'No KK',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.person, color: Color(0xFF909090)),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _noKkPenanggungJawabController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    hintText: 'No KK',
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16),

                          
                          Text(
                            'No Telpon',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.call, color: Color(0xFF909090)),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _noKkPenanggungJawabController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    hintText: 'No Telpon',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Container(
                        width: 600,
                        height: 72,
                        decoration: ShapeDecoration(
                          color: Color(0xFFED401C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: TextButton(
                          onPressed: _showConfirmationDialog,
                          child: Text(
                            'Simpan',
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

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon) {
    return Container(
      width: double.infinity,
      height: 72,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFFB7B9B6)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Color(0xFF909090)),
          SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration.collapsed(hintText: hint),
              keyboardType: hint.contains('Telpon')
                  ? TextInputType.phone
                  : TextInputType.text,
            ),
          ),
        ],
      ),
    );
  }
}
