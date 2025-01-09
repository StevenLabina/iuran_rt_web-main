import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:iuran_rt_web/url.dart';

class buatKkPemilikRumahPage extends StatefulWidget {
  final String no_kk;

  buatKkPemilikRumahPage({required this.no_kk});

  @override
  _buatKkPemilikRumahPageState createState() => _buatKkPemilikRumahPageState();
}

class _buatKkPemilikRumahPageState extends State<buatKkPemilikRumahPage> {
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _pendidikanController = TextEditingController();
  final TextEditingController _jenisPekerjaanController =
      TextEditingController();

  String? selectedAgamaPemilik;

  final List<String> agamaOptions = [
    'Pilih Agama',
    'Islam',
    'Katolik',
    'Kristen',
    'Hindu',
    'Budha',
    'Konghucu',
  ];
  String? selectedJenisKelaminPemilik;

  final List<String> jenisKelaminOptions = [
    'Pilih Jenis Kelamin',
    'Laki-laki',
    'Perempuan'
  ];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    ;
  }

  Future<void> buatWargaData() async {
    try {
      final response = await http.post(
        Uri.parse("${ApiUrls.baseUrl}/buatKkPemilik.php"),
        body: {
          'no_kk': widget.no_kk.toString(),
          'nama_lengkap': _namaLengkapController.text,
          'nik': _nikController.text,
          'jenis_kelamin': selectedJenisKelaminPemilik.toString(),
          'tempat_lahir': _tempatLahirController.text,
          'tanggal_lahir': _tanggalLahirController.text,
          'agama': selectedAgamaPemilik.toString(),
          'pendidikan': _pendidikanController.text,
          'jenis_pekerjaan': _jenisPekerjaanController.text,
        },
      );

      final json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        Fluttertoast.showToast(
            msg: "Buat data KK berhasil",
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
    if (selectedAgamaPemilik.toString() == 'Pilih Agama' ||
        selectedJenisKelaminPemilik.toString() == 'Pilih Jenis Kelamin' ||
        _namaLengkapController.text.isEmpty ||
        _nikController.text.isEmpty ||
        _tempatLahirController.text.isEmpty ||
        _pendidikanController.text.isEmpty ||
        _jenisPekerjaanController.text.isEmpty  ) {
      Fluttertoast.showToast(
        msg: "Kolom tidak boleh kosong",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black38,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFFDECE8),
          title:
              Text('Konfirmasi', style: GoogleFonts.lato(color: Colors.black)),
          content: Text('Apakah Anda yakin ingin membuat data KK ini?',
              style: GoogleFonts.lato(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal', style: GoogleFonts.lato(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                buatWargaData();

                Navigator.of(context).pop();
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
                            'Buat Data Kartu Keluarga',
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
                      width: 1000,
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
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.location_city,
                                    color: Color(0xFF909090)),
                                SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _namaLengkapController,
                                    enabled: true,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        hintText: 'Nama Lengkap'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.location_city,
                                    color: Color(0xFF909090)),
                                SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _nikController,
                                    enabled: true,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        hintText: 'NIK'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 1000,
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
                           Icon(Icons.location_city,
                                    color: Color(0xFF909090)),
                                SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedJenisKelaminPemilik ??
                                  "Pilih Jenis Kelamin",
                              items: jenisKelaminOptions.map((jenisKelamin) {
                                return DropdownMenuItem(
                                  value: jenisKelamin,
                                  child: Text(jenisKelamin),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedJenisKelaminPemilik = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.location_city,
                                    color: Color(0xFF909090)),
                                SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _tempatLahirController,
                                    enabled: true,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        hintText: 'Tempat Lahir'),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _tanggalLahirController,
                              readOnly: true,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                hintText: 'Tanggal Lahir',
                              ),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    _tanggalLahirController.text =
                                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 1000,
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
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.location_city,
                                    color: Color(0xFF909090)),
                                SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedAgamaPemilik ??
                                        "Pilih Agama",
                                    items:
                                        agamaOptions.map((agama) {
                                      return DropdownMenuItem(
                                        value: agama,
                                        child: Text(agama),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedAgamaPemilik = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.location_city,
                                    color: Color(0xFF909090)),
                                SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _pendidikanController,
                                    enabled: true,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        hintText: 'Pendidikan'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.location_city,
                                    color: Color(0xFF909090)),
                                SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _jenisPekerjaanController,
                                    enabled: true,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        hintText: 'Jenis Pekerjaan'),
                                  ),
                                ),
                              ],
                            ),
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

 
}