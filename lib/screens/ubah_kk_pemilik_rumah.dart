import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:iuran_rt_web/url.dart';

class ubahKkPemilikRumahPage extends StatefulWidget {
  final int id;

  ubahKkPemilikRumahPage({required this.id});

  @override
  _ubahKkPemilikRumahPageState createState() => _ubahKkPemilikRumahPageState();
}

class _ubahKkPemilikRumahPageState extends State<ubahKkPemilikRumahPage> {
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _pendidikanController = TextEditingController();
  final TextEditingController _jenisPekerjaanController =
      TextEditingController();
  String? selectedAgamaPemilik = "Pilih Agama";
  String? selectedJenisKelaminPemilik = "Pilih Jenis Kelamin";

  final List<String> agamaOptions = [
    'Pilih Agama',
    'Islam',
    'Katolik',
    'Kristen',
    'Hindu',
    'Budha',
    'Konghucu'
  ];
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
    fetchWargaData();
  }

  Future<void> fetchWargaData() async {
    try {
      final response = await http
          .get(Uri.parse("${ApiUrls.baseUrl}/getKk.php?id=${widget.id}"));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['result'] == 'success') {
          setState(() {
            _namaLengkapController.text = json['data']['nama_lengkap'];
            _nikController.text = json['data']['nik'];
            selectedJenisKelaminPemilik =
                jenisKelaminOptions.contains(json['data']['jenis_kelamin'])
                    ? json['data']['jenis_kelamin']
                    : "Pilih Jenis Kelamin";
            _tempatLahirController.text = json['data']['tempat_lahir'];
            _tanggalLahirController.text = json['data']['tanggal_lahir'];
            selectedAgamaPemilik = agamaOptions.contains(json['data']['agama'])
                ? json['data']['agama']
                : "Pilih Agama";
              selectedJenisKelaminPemilik =
                jenisKelaminOptions.contains(json['data']['jenis_kelamin'])
                    ? json['data']['jenis_kelamin']
                    : "Pilih Jenis Kelamin";

            _pendidikanController.text = json['data']['pendidikan'];
            _jenisPekerjaanController.text = json['data']['jenis_pekerjaan'];
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

  Future<void> updateWargaData() async {
    try {
      final response = await http.post(
        Uri.parse("${ApiUrls.baseUrl}/updateKkPemilik.php"),
        body: {
          'id': widget.id.toString(),
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
            msg: "Update data KK berhasil",
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
          content: Text('Apakah Anda yakin ingin memperbarui data KK ini?',
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
                updateWargaData();

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
                            'Ubah Data Kartu Keluarga',
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
                   Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Container(
      width: 1000,
      padding: const EdgeInsets.all(20),
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
          Text('Nama Lengkap', style: TextStyle(color: Colors.black, fontSize: 12)),
          SizedBox(height: 4),
          TextFormField(
            controller: _namaLengkapController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              hintText: 'Nama Lengkap',
            ),
          ),
          SizedBox(height: 12),
          Text('NIK', style: TextStyle(color: Colors.black, fontSize: 12)),
          SizedBox(height: 4),
          TextFormField(
            controller: _nikController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              hintText: 'NIK',
            ),
          ),
        ],
      ),
    ),
    SizedBox(height: 20),
    Container(
      width: 1000,
      padding: const EdgeInsets.all(20),
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
          Text('Jenis Kelamin', style: TextStyle(color: Colors.black, fontSize: 12)),
          SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: selectedJenisKelaminPemilik ?? "Pilih Jenis Kelamin",
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
          SizedBox(height: 12),
          Text('Tempat Lahir', style: TextStyle(color: Colors.black, fontSize: 12)),
          SizedBox(height: 4),
          TextFormField(
            controller: _tempatLahirController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              hintText: 'Tempat Lahir',
            ),
          ),
          SizedBox(height: 12),
          Text('Tanggal Lahir', style: TextStyle(color: Colors.black, fontSize: 12)),
          SizedBox(height: 4),
          TextFormField(
            controller: _tanggalLahirController,
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                  _tanggalLahirController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                });
              }
            },
          ),
        ],
      ),
    ),
    SizedBox(height: 20),
    Container(
      width: 1000,
      padding: const EdgeInsets.all(20),
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
          Text('Agama', style: TextStyle(color: Colors.black, fontSize: 12)),
          SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: selectedAgamaPemilik ?? "Pilih Agama",
            items: agamaOptions.map((agama) {
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
          SizedBox(height: 12),
          Text('Pendidikan Terakhir', style: TextStyle(color: Colors.black, fontSize: 12)),
          SizedBox(height: 4),
          TextFormField(
            controller: _pendidikanController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              hintText: 'Pendidikan',
            ),
          ),
          SizedBox(height: 12),
          Text('Jenis Pekerjaan', style: TextStyle(color: Colors.black, fontSize: 12)),
          SizedBox(height: 4),
          TextFormField(
            controller: _jenisPekerjaanController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              hintText: 'Jenis Pekerjaan',
            ),
          ),
        ],
      ),
    ),
  ],
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
