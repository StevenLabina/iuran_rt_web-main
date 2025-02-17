import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:iuran_rt_web/main.dart';
import 'package:iuran_rt_web/screens/buat_warga_csv.dart';
import 'dart:convert';

import 'package:iuran_rt_web/url.dart';
import 'package:iuran_rt_web/drawer.dart';

class BuatWargaPage extends StatefulWidget {
  @override
  _BuatWargaPageState createState() => _BuatWargaPageState();
}

class _BuatWargaPageState extends State<BuatWargaPage> {
  final TextEditingController noKavlingController = TextEditingController();
  final TextEditingController alamatKavlingController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController namaPemilikController = TextEditingController();
  final TextEditingController noTelponPemilikController =
      TextEditingController();
  final TextEditingController nikPemilikController = TextEditingController();
  final TextEditingController tempatLahirPemilikController =
      TextEditingController();
  final TextEditingController tanggalLahirPemilikController =
      TextEditingController();
  final TextEditingController statusPendidikanPemilikController =
      TextEditingController();
  final TextEditingController pekerjaanPemilikController =
      TextEditingController();
  final TextEditingController noKKPemilikController = TextEditingController();
  String? selectedAgamaPemilik;
  String? selectedJenisKelaminPemilik;

  final List<String> agamaOptions = [
    'Islam',
    'Katolik',
    'Kristen',
    'Hindu',
    'Budha',
    'Konghucu',
    'Lainnya'
  ];
  final List<String> jenisKelaminOptions = ['Laki-laki', 'Perempuan'];

  final TextEditingController noKKPenanggungJawabController =
      TextEditingController();
  final TextEditingController namaPenanggungJawabController =
      TextEditingController();

  final TextEditingController noTelponPenanggungJawabController =
      TextEditingController();
  final TextEditingController nikPenanggungJawabController =
      TextEditingController();
  final TextEditingController tempatLahirPenanggungJawabController =
      TextEditingController();
  final TextEditingController tanggalLahirPenanggungJawabController =
      TextEditingController();
  final TextEditingController statusPendidikanPenanggungJawabController =
      TextEditingController();
  final TextEditingController pekerjaanPenanggungJawabController =
      TextEditingController();
  String? selectedAgamaPenanggungJawab;
  String? selectedJenisKelaminPenanggungJawab;

  bool obscureText = true;

  Future<void> submitData() async {
    final response = await http.post(
      Uri.parse('${ApiUrls.baseUrl}/tambahDataWarga.php'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        //Akun
        'no_kavling': noKavlingController.text,
        'alamat_kavling': alamatKavlingController.text,
        'password': passwordController.text,

        //Pemilik Rumah
        'nama_pemilik_rumah': namaPemilikController.text,
        'no_telpon_pemilik': noTelponPemilikController.text,
        'nik_pemilik': nikPemilikController.text,
        'tempat_lahir_pemilik': tempatLahirPemilikController.text,
        'status_pendidikan_pemilik': statusPendidikanPemilikController.text,
        'jenis_pekerjaan_pemilik': pekerjaanPemilikController.text,
        'tanggal_lahir_pemilik': tanggalLahirPemilikController.text,
        'agama_pemilik': selectedAgamaPemilik.toString(),
        'jenis_kelamin_pemilik': selectedJenisKelaminPemilik.toString(),
        'no_kk_pemilik': noKKPemilikController.text,

        //Penanggung Jawab
        'nama_penanggung_jawab': namaPenanggungJawabController.text,
        'no_telpon_penanggung_jawab': noTelponPenanggungJawabController.text,
        'nik_penanggung_jawab': nikPenanggungJawabController.text,
        'tempat_lahir_penanggung_jawab':
            tempatLahirPenanggungJawabController.text,
        'status_pendidikan_penanggung_jawab':
            statusPendidikanPenanggungJawabController.text,
        'jenis_pekerjaan_penanggung_jawab':
            pekerjaanPenanggungJawabController.text,
        'tanggal_lahir_penanggung_jawab':
            tanggalLahirPenanggungJawabController.text,
        'agama_penanggung_jawab': selectedAgamaPenanggungJawab.toString(),
        'jenis_kelamin_penanggung_jawab':
            selectedJenisKelaminPenanggungJawab.toString(),
        'no_kk_penanggung_jawab': noKKPenanggungJawabController.text,
      },
    );

    final result = jsonDecode(response.body);
    if (result['result'] == 'success') {
      Fluttertoast.showToast(
          msg: "Data Warga Berhasil Disimpan",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Gagal Data Warga Berhasil",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void _showConfirmationDialog() {
    if (namaPemilikController.text.isEmpty ||
        namaPenanggungJawabController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Kolom Nama Lengkap tidak boleh kosong",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black38,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    if (noTelponPemilikController.text.isEmpty ||
        noTelponPenanggungJawabController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Kolom No. Telepon tidak boleh kosong",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black38,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    if (nikPemilikController.text.isEmpty ||
        nikPenanggungJawabController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Kolom NIK tidak boleh kosong",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black38,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    if (noKavlingController.text.isEmpty ||
        alamatKavlingController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Kolom Akun tidak boleh kosong",
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
          content: Text('Apakah Anda yakin ingin menyimpan data warga ini?',
              style: GoogleFonts.lato(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              child: Text('Batal', style: GoogleFonts.lato(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Kirim', style: GoogleFonts.lato(color: Colors.red)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
                submitData();
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
        elevation: 0,
      ),
      drawer: MyDrawer(
        currentPage: 'BuatWargaPage',
      ),
      body: Stack(
        children: [
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
                    Container(
                      width: 567,
                      height: 80,
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
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              'Manual',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          // Tombol kedua
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BuatWargaPageCsv()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              'Excel',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Pemilik Rumah=========================================================================================================================================================
                    Container(
                      child: Center(
                        child: Text(
                          '__________________Pemilik Rumah__________________',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 800) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.person,
                                              color: Color(0xFF909090)),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              controller: namaPemilikController,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                hintText: 'Nama Lengkap',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '*Bersifat wajib',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.call,
                                              color: Color(0xFF909090)),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              inputFormatters: [LengthLimitingTextInputFormatter(15)], 
                                              controller:
                                                  noTelponPemilikController,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                hintText: 'No Telepon',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '*Bersifat wajib',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.call,
                                              color: Color(0xFF909090)),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              inputFormatters: [LengthLimitingTextInputFormatter(16)], 
                                              controller: nikPemilikController,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                hintText: 'NIK',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '*Bersifat wajib',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person,
                                        color: Color(0xFF909090)),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: namaPemilikController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          hintText: 'Nama Lengkap',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '*Bersifat wajib',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(Icons.call, color: Color(0xFF909090)),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        inputFormatters: [LengthLimitingTextInputFormatter(15)], 
                                        controller: noTelponPemilikController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          hintText: 'No Telepon',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '*Bersifat wajib',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(Icons.call, color: Color(0xFF909090)),
                                    SizedBox(width: 12),
                                    Expanded(
                                      
                                      child: TextFormField(
                                        inputFormatters: [LengthLimitingTextInputFormatter(16)], 
                                        controller: nikPemilikController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          hintText: 'NIK',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '*Bersifat wajib',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 16),
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 800) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.person,
                                              color: Color(0xFF909090)),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  tempatLahirPemilikController,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                hintText: 'Tempat Lahir',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.call,
                                              color: Color(0xFF909090)),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  statusPendidikanPemilikController,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                hintText: 'Status Pendidikan',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.call,
                                              color: Color(0xFF909090)),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  pekerjaanPemilikController,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                hintText: 'Jenis Pekerjaan',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.person,
                                            color: Color(0xFF909090)),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                tempatLahirPemilikController,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              hintText: 'Tempat Lahir',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.call,
                                            color: Color(0xFF909090)),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                statusPendidikanPemilikController,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              hintText: 'Status Pendidikan',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.call,
                                            color: Color(0xFF909090)),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                pekerjaanPemilikController,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              hintText: 'Jenis Pekerjaan',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 16),
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 800) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          color: Color(0xFF909090)),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                              tanggalLahirPemilikController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            hintText: 'Tanggal Lahir',
                                          ),
                                          onTap: () async {
                                            DateTime? pickedDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime.now(),
                                            );
                                            if (pickedDate != null) {
                                              setState(() {
                                                tanggalLahirPemilikController
                                                        .text =
                                                    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                              });
                                            }
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
                                      Icon(Icons.account_balance,
                                          color: Color(0xFF909090)),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: selectedAgamaPemilik,
                                          items: agamaOptions
                                              .map((agama) => DropdownMenuItem(
                                                    value: agama,
                                                    child: Text(agama),
                                                  ))
                                              .toList(),
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            hintText: 'Agama',
                                          ),
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
                                      Icon(Icons.person,
                                          color: Color(0xFF909090)),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: selectedJenisKelaminPemilik,
                                          items: jenisKelaminOptions
                                              .map((jenisKelamin) =>
                                                  DropdownMenuItem(
                                                    value: jenisKelamin,
                                                    child: Text(jenisKelamin),
                                                  ))
                                              .toList(),
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            hintText: 'Jenis Kelamin',
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedJenisKelaminPemilik =
                                                  value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Tampilan untuk layar kecil (iPad, tablet, HP)
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(Icons.calendar_today,
                                              color: Color(0xFF909090)),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  tanggalLahirPemilikController,
                                              readOnly: true,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                hintText: 'Tanggal Lahir',
                                              ),
                                              onTap: () async {
                                                DateTime? pickedDate =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(1900),
                                                  lastDate: DateTime.now(),
                                                );
                                                if (pickedDate != null) {
                                                  setState(() {
                                                    tanggalLahirPemilikController
                                                            .text =
                                                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                                  });
                                                }
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
                                          Icon(Icons.account_balance,
                                              color: Color(0xFF909090)),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child:
                                                DropdownButtonFormField<String>(
                                              value: selectedAgamaPemilik,
                                              items: agamaOptions
                                                  .map((agama) =>
                                                      DropdownMenuItem(
                                                        value: agama,
                                                        child: Text(agama),
                                                      ))
                                                  .toList(),
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                hintText: 'Agama',
                                              ),
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
                                  ],
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(Icons.person,
                                        color: Color(0xFF909090)),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: selectedJenisKelaminPemilik,
                                        items: jenisKelaminOptions
                                            .map((jenisKelamin) =>
                                                DropdownMenuItem(
                                                  value: jenisKelamin,
                                                  child: Text(jenisKelamin),
                                                ))
                                            .toList(),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          hintText: 'Jenis Kelamin',
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedJenisKelaminPemilik = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: 1000,
                      padding: const EdgeInsets.all(
                          16), // Ubah padding agar lebih rapi
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Color(0xFFB7B9B6)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Color(0xFF909090)),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  inputFormatters: [LengthLimitingTextInputFormatter(16)], 
                                  controller: noKKPemilikController,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    hintText: 'No Kartu Keluarga',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text(
                            "*Bersifat wajib",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),
                    //Penanggung Jawab==============================================================================================================================================
                    Container(
                      child: Center(
                        child: Text(
                          '________________Penanggung Jawab________________',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 800) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.call,
                                              color: Color(0xFF909090)),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  namaPenanggungJawabController,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                hintText: 'Nama Lengkap',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '*Bersifat wajib',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.call,
                                              color: Color(0xFF909090)),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              inputFormatters: [LengthLimitingTextInputFormatter(15)], 
                                              controller:
                                                  noTelponPenanggungJawabController,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                hintText: 'No Telpon',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '*Bersifat wajib',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.call,
                                              color: Color(0xFF909090)),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              inputFormatters: [LengthLimitingTextInputFormatter(16)], 
                                              controller:
                                                  nikPenanggungJawabController,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                hintText: 'NIK',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '*Bersifat wajib',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.call, color: Color(0xFF909090)),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            namaPenanggungJawabController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          hintText: 'Nama Lengkap',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '*Bersifat wajib',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(Icons.call, color: Color(0xFF909090)),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        inputFormatters: [LengthLimitingTextInputFormatter(15)], 
                                        controller:
                                            noTelponPenanggungJawabController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          hintText: 'No Telpon',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '*Bersifat wajib',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(Icons.call, color: Color(0xFF909090)),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        inputFormatters: [LengthLimitingTextInputFormatter(16)], 
                                        controller:
                                            nikPenanggungJawabController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          hintText: 'NIK',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '*Bersifat wajib',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 16),
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 800) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.person,
                                          color: Color(0xFF909090)),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                              tempatLahirPenanggungJawabController,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            hintText: 'Tempat Lahir',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.call,
                                          color: Color(0xFF909090)),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                              statusPendidikanPenanggungJawabController,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            hintText: 'Status Pendidikan',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.call,
                                          color: Color(0xFF909090)),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                              pekerjaanPenanggungJawabController,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            hintText: 'Jenis Pekerjaan',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Tampilan untuk layar kecil (HP/tablet)
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person,
                                        color: Color(0xFF909090)),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            tempatLahirPenanggungJawabController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          hintText: 'Tempat Lahir',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(Icons.call, color: Color(0xFF909090)),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            statusPendidikanPenanggungJawabController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          hintText: 'Status Pendidikan',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(Icons.call, color: Color(0xFF909090)),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            pekerjaanPenanggungJawabController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          hintText: 'Jenis Pekerjaan',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 16),
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 800) {
                            // Tampilan untuk layar besar (PC / laptop)
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          color: Color(0xFF909090)),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                              tanggalLahirPenanggungJawabController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            hintText: 'Tanggal Lahir',
                                          ),
                                          onTap: () async {
                                            DateTime? pickedDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime.now(),
                                            );
                                            if (pickedDate != null) {
                                              setState(() {
                                                tanggalLahirPenanggungJawabController
                                                        .text =
                                                    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                              });
                                            }
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
                                      Icon(Icons.account_balance,
                                          color: Color(0xFF909090)),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: selectedAgamaPenanggungJawab,
                                          items: agamaOptions
                                              .map((agama) => DropdownMenuItem(
                                                    value: agama,
                                                    child: Text(agama),
                                                  ))
                                              .toList(),
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            hintText: 'Agama',
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedAgamaPenanggungJawab =
                                                  value;
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
                                      Icon(Icons.person,
                                          color: Color(0xFF909090)),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value:
                                              selectedJenisKelaminPenanggungJawab,
                                          items: jenisKelaminOptions
                                              .map((jenisKelamin) =>
                                                  DropdownMenuItem(
                                                    value: jenisKelamin,
                                                    child: Text(jenisKelamin),
                                                  ))
                                              .toList(),
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            hintText: 'Jenis Kelamin',
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedJenisKelaminPenanggungJawab =
                                                  value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Tampilan untuk layar kecil (iPad, tablet, HP)
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(Icons.calendar_today,
                                              color: Color(0xFF909090)),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  tanggalLahirPenanggungJawabController,
                                              readOnly: true,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                hintText: 'Tanggal Lahir',
                                              ),
                                              onTap: () async {
                                                DateTime? pickedDate =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(1900),
                                                  lastDate: DateTime.now(),
                                                );
                                                if (pickedDate != null) {
                                                  setState(() {
                                                    tanggalLahirPenanggungJawabController
                                                            .text =
                                                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                                  });
                                                }
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
                                          Icon(Icons.account_balance,
                                              color: Color(0xFF909090)),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child:
                                                DropdownButtonFormField<String>(
                                              value:
                                                  selectedAgamaPenanggungJawab,
                                              items: agamaOptions
                                                  .map((agama) =>
                                                      DropdownMenuItem(
                                                        value: agama,
                                                        child: Text(agama),
                                                      ))
                                                  .toList(),
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                hintText: 'Agama',
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedAgamaPenanggungJawab =
                                                      value;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(Icons.person,
                                        color: Color(0xFF909090)),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value:
                                            selectedJenisKelaminPenanggungJawab,
                                        items: jenisKelaminOptions
                                            .map((jenisKelamin) =>
                                                DropdownMenuItem(
                                                  value: jenisKelamin,
                                                  child: Text(jenisKelamin),
                                                ))
                                            .toList(),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          hintText: 'Jenis Kelamin',
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedJenisKelaminPenanggungJawab =
                                                value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: 1000,
                      padding: const EdgeInsets.all(
                          16), // Ubah padding agar lebih rapi
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Color(0xFFB7B9B6)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Menghindari overflow
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Color(0xFF909090)),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  inputFormatters: [LengthLimitingTextInputFormatter(16)], 
                                  controller: noKKPenanggungJawabController,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    hintText: 'No Kartu Keluarga',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text(
                            "*Bersifat wajib",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),
                    //Akun=======================================================================================================================
                    Container(
                      child: Center(
                        child: Text(
                          '____________________Akun____________________',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 800) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.person,
                                              color: Color(0xFF909090)),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              controller: noKavlingController,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                hintText: 'No Kavling',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '*Bersifat wajib',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.call,
                                              color: Color(0xFF909090)),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  alamatKavlingController,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                hintText: 'Alamat Kavling',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '*Bersifat wajib',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                               
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person,
                                        color: Color(0xFF909090)),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: noKavlingController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          hintText: 'No Kavling',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '*Bersifat wajib',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(Icons.call, color: Color(0xFF909090)),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: alamatKavlingController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          hintText: 'Alamat Kavling',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '*Bersifat wajib',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                
                              ],
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
   Container(
  width: 1000,
  padding: const EdgeInsets.all(16), // Sesuaikan padding
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
      Row(
        children: [
          Icon(Icons.label, color: Color(0xFF909090)),
          SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              obscureText: obscureText,
              controller: passwordController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Password',
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
              onPressed: () {
                setState(() {
                  obscureText = !obscureText;
                });
              },
              child: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "*Bersifat wajib",
          style: TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
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
                        width: 500,
                        height: 50,
                        decoration: ShapeDecoration(
                          color: Color(0xFFED401C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: TextButton(
                          onPressed: _showConfirmationDialog,
                          child: Text(
                            'Kirim',
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
