import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:iuran_rt_web/url.dart';

import 'package:shared_preferences/shared_preferences.dart';

class BuktiTransaksiPage extends StatefulWidget {
  @override
  _BuktiTransaksiPageState createState() => _BuktiTransaksiPageState();
}

class _BuktiTransaksiPageState extends State<BuktiTransaksiPage> {
  List<dynamic> _revisiData = [];
  bool isLoading = true;
  String errorMessage = '';
  String iMetode = 'Bayar Tunai';

  @override
  void initState() {
    super.initState();
    fetchRevisiData();
  }
  
  Future<void> fetchRevisiData() async {
    try {
      final response =
          await http.get(Uri.parse("${ApiUrls.baseUrl}/listAjukanLunas.php"));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['result'] == 'success') {
          setState(() {
            _revisiData = json['data'];
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
   Future<void> kirimNotifikasiWA(String id, String namaIuran, String nominalIuran) async {
    final urlNotifikasiWA = '${ApiUrls.baseUrl}/whatsapp_api_1.php';
    try {
      final responseNotifikasiWA = await http.post(
        Uri.parse(urlNotifikasiWA),
        body: {
        'msg':
              'Halo, transaksi iuran "${namaIuran}" dengan nominal sebesar Rp${nominalIuran} anda telah berhasil, terima kasih telah menggunakan layanan ini',
          'id': id,
        },
      );

      if (responseNotifikasiWA.statusCode == 200) {
        final jsonResponseNotifikasiWA = jsonDecode(responseNotifikasiWA.body);
        final status = jsonResponseNotifikasiWA['status'];
        final statusInt =
            status is int ? status : int.tryParse(status.toString()) ?? 0;

        if (statusInt == 1) {
          print('Notifikasi WhatsApp berhasil dikirim');
        } else {
          print(
              'Gagal mengirim notifikasi WhatsApp: ${jsonResponseNotifikasiWA['reason']}');
        }
      } else {
        print(
            'Gagal mengirim notifikasi WhatsApp: ${responseNotifikasiWA.statusCode}');
      }
    } catch (e) {
      print('Error: Gagal terhubung ke server WhatsApp $e');
    }
  }
  Future<void> updateStatusLunas(String id) async {
     final now = DateTime.now();
    final tanggalLunasFormatted = DateFormat('dd/MM/yyyy-HH:mm').format(now);
  try {
    final response = await http.post(
      Uri.parse("${ApiUrls.baseUrl}/sudahLunas.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
        {'id': id,
      'tanggal_lunas': tanggalLunasFormatted,
          
        }
        ),
    );
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    if (response.body.isNotEmpty) {  
      final json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        Fluttertoast.showToast(
          msg: "Status updated LUNAS",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        fetchRevisiData();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(json['message'])));
      }
    } else {
    
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update status: Empty response")));
    }
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Failed to update status: $e")));
  }
}
Future<void> sendToHistory(String noKavling, String alamatKavling, String namaPemilik, String namaPenanggung, String namaIuran, String batas, String nominalIuran, String metode) async {
    try {
      final now = DateTime.now();
      final tanggalLunasFormatted = DateFormat('dd/MM/yyyy-HH:mm').format(now);
      final response = await http.post(
        Uri.parse('${ApiUrls.baseUrl}/tambah_histori.php'),
        body: {
          'r_no_kavling': noKavling,
          'r_alamat_kavling': alamatKavling,
          'r_nama_pemilik': namaPemilik,
          'r_nama_penanggung_jawab': namaPenanggung,
          'r_nama_iuran': namaIuran,
          'r_nominal_iuran': nominalIuran ,
          'r_tanggal_lunas': tanggalLunasFormatted,
          'r_batas_pembayaran': batas ,
          'r_metode' : metode
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['result'] == 'success') {
          print('Data berhasil ditambahkan ke histori');
        } else {
          print('Gagal menambahkan ke histori: ${result['message']}');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saat mengirim data ke histori: $e');
    }
  }
  Future<void> updateStatusBelumLunas(String id) async {
  try {
    final response = await http.post(
      Uri.parse("${ApiUrls.baseUrl}/belumLunas.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'id': id}),
    );
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    if (response.body.isNotEmpty) {  
      final json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        Fluttertoast.showToast(
          msg: "Status updated BELUM LUNAS",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('buttonVisible_$id', true);
        fetchRevisiData();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(json['message'])));
      }
    } else {
    
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update status: Empty response")));
    }
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Failed to update status: $e")));
  }
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
    body: Container(
      color: Color(0xFFFDECE8),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.money, size: 40, color: Color.fromARGB(255, 0, 0, 0)),
              const SizedBox(width: 20),
              Text(
                'Validasi Pengurus Tehadap Pembayaran Tunai Warga ',
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
          SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Text(errorMessage,
                            style: GoogleFonts.lato(color: Colors.black)))
                    : ListView.builder(
                        itemCount: _revisiData.length,
                        itemBuilder: (context, index) {
                          final revisi = _revisiData[index];
                          // Pastikan revisi memiliki data yang benar
                          return _buildCard(revisi);
                        },
                      ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildCard(Map revisi) {
  // Mengambil data revisi
  String namaIuran = revisi['nama_iuran'] ?? 'N/A';
  String nominalIuran = revisi['nominal_iuran'] ?? 'N/A';

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16.0),
    child: Card(
      color: Color(0xFFED401C),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Color(0xFF8E2611),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Icon(Icons.money_outlined, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                '$namaIuran',
                                style: GoogleFonts.lato(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '$nominalIuran',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'No Kavling: ${revisi['no_kavling']}',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Alamat Kavling: ${revisi['alamat_kavling']}',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Nama Penanggung Jawab:${revisi['nama_penanggung_jawab']}',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'No Telpon:${revisi['no_telpon_penanggung_jawab']}',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                   
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
              ),
              onPressed: () {
              updateStatusLunas(revisi['id']); 
              kirimNotifikasiWA(revisi['id'], revisi['nama_iuran'], revisi['nominal_iuran'] );                         
              sendToHistory(revisi['no_kavling'], revisi['alamat_kavling'], revisi['nama_pemilik_rumah'], revisi['nama_penanggung_jawab'], revisi['nama_iuran'], revisi['batas_pembayaran'], revisi['nominal_iuran'], iMetode.toString() );
              },
              child: Text('Klik Bila Sudah Lunas', style: GoogleFonts.lato(color: Colors.black)),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}
}

void main() {
  runApp(MaterialApp(
    home: BuktiTransaksiPage(),
  ));
}
