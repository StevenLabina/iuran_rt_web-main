import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:iuran_rt_web/url.dart';
import 'package:iuran_rt_web/drawer.dart';

class LaporanRevisiDataPage extends StatefulWidget {
  @override
  _LaporanRevisiDataPageState createState() => _LaporanRevisiDataPageState();
}

class _LaporanRevisiDataPageState extends State<LaporanRevisiDataPage> {
  List<dynamic> _revisiData = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchRevisiData();
  }

  Future<void> fetchRevisiData() async {
    try {
      final response =
          await http.get(Uri.parse("${ApiUrls.baseUrl}/listRevisiData.php"));
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
  Future<void> kirimNotifikasiWA(String id) async {
    final urlNotifikasiWA = '${ApiUrls.baseUrl}/whatsapp_api_1.php';
    try {
      final responseNotifikasiWA = await http.post(
        Uri.parse(urlNotifikasiWA),
        body: {
        'msg':
              'Halo, data warga anda telah diperbarui ',
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
  Future<void> deleteRevisiData(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("${ApiUrls.baseUrl}/deleteLaporan.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'id': id}),
      );
      final json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        setState(() {
          _revisiData.removeWhere((item) => item['id_user'] == id);
        });
        Fluttertoast.showToast(
            msg: "Saran perubahan data warga terhapus",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black38,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(json['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to delete record: $e")));
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFDECE8),
        elevation: 0,
      ),
      drawer: MyDrawer(currentPage: 'LaporanRevisiDataPage'),
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
              Icon(Icons.person_3, size: 40, color: Color.fromARGB(255, 0, 0, 0)),
              const SizedBox(width: 20),
                Text(
                  MediaQuery.of(context).size.width > 700
                      ? 'Laporan Revisi Data Warga' // Untuk laptop/desktop, satu baris
                      : 'Laporan Revisi\nData Warga', // Untuk tablet/iPad dan HP, dua atau tiga baris
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF181C14),
                    fontSize: MediaQuery.of(context).size.width > 600
                        ? 40 // Ukuran besar untuk laptop/desktop
                        : (MediaQuery.of(context).size.width > 400
                            ? 30 // Ukuran medium untuk tablet/iPad
                            : 24), // Ukuran kecil untuk ponsel
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w600,
                    height: 1.2, // Mengatur tinggi baris agar lebih rapi
                  ),
                )
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
  String penanggungJawab = revisi['nama_penanggung_jawab'] ?? 'N/A';
  String noKavling = revisi['no_kavling'] ?? 'N/A';
  String noTelponPenanggungJawab = revisi['no_telpon_penanggung_jawab'] ?? 'N/A';

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
                              Icon(Icons.home, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Revisi:',
                                style: GoogleFonts.lato(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${revisi['revisi']}',
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
                // Tampilkan No Kavling, Nama Penanggung Jawab, dan Nomor Telepon hanya jika lebar layar cukup besar (laptop)
                if (MediaQuery.of(context).size.width > 900) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'No Kavling: $noKavling',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Nama Penanggung Jawab: $penanggungJawab',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Telpon Penanggung Jawab: $noTelponPenanggungJawab',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
            // Jika lebar layar lebih kecil (tablet/iPad), tampilkan No Kavling, Nama Penanggung Jawab, dan Nomor Telepon di bawah Card
            if (MediaQuery.of(context).size.width <= 900) ...[
              SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'No Kavling: $noKavling',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Nama Penanggung Jawab: $penanggungJawab',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Telpon Penanggung Jawab: $noTelponPenanggungJawab',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ],
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
              ),
              onPressed: () {
                deleteRevisiData(revisi['id_user'].toString());
                kirimNotifikasiWA(revisi['id_user'].toString());
              },
              child: Text('Delete', style: GoogleFonts.lato(color: Colors.black)),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  runApp(MaterialApp(
    home: LaporanRevisiDataPage(),
  ));
}
}