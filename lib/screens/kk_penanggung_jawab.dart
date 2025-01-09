import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:iuran_rt_web/screens/buat_kk_penanggung_jawab.dart';
import 'package:iuran_rt_web/screens/pdf_kk_penanggung_jawab.dart';
import 'package:iuran_rt_web/screens/ubah_kk_penanggung_jawab.dart';
import 'package:iuran_rt_web/url.dart';

class KkPenanggungJawabPage extends StatefulWidget {
  final String no_kk;

  KkPenanggungJawabPage({required this.no_kk});
  @override
  _KkPenanggungJawabPageState createState() =>  _KkPenanggungJawabPageState();
}

class _KkPenanggungJawabPageState extends State<KkPenanggungJawabPage> {
 List<dynamic> dataKkPenduduk = [];
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchKkData();
  }

  Future<void> fetchKkData() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('${ApiUrls.baseUrl}list_kk_penanggung_jawab.php'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'no_kk': widget.no_kk.toString(),
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['result'] == 'success') {
        setState(() {
          dataKkPenduduk = result['data'];
        });
      } else {
        setState(() {
          dataKkPenduduk = [];
        });
        Fluttertoast.showToast(
            msg: "Data Tidak Ditemukan",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black38,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data dari server')),
      );
    }

    setState(() {
      isLoading = false;
    });
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
                SvgPicture.asset(
                  'assets/images/UsersFour.svg',
                  color: Colors.black,
                  width: 40,
                  height: 40,
                ),
                // Icon(Icons.person_3, size: 40, color: Color.fromARGB(255, 0, 0, 0)),
                const SizedBox(width: 20),
                Text(
                  "Data Kartu Keluarga",
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
                              style: GoogleFonts.lato(color: Colors.white)))
                      : ListView.builder(
                          itemCount: dataKkPenduduk.length,
                          itemBuilder: (context, index) {
                            final penduduk = dataKkPenduduk[index];
                            return _buildCard(
                              penduduk['id'] ?? 0,
                              penduduk['no_kk'] ?? 'N/A',
                              penduduk['nama_lengkap'] ?? 'N/A',
                              penduduk['nik'] ?? 'N/A',
                              penduduk['jenis_kelamin'] ?? 'N/A',
                              penduduk['tempat_lahir'] ?? 'N/A',
                              penduduk['tanggal_lahir'] ?? 'N/A',
                              penduduk['agama'] ?? 'N/A',
                              penduduk['pendidikan'] ?? 'N/A',
                              penduduk['jenis_pekerjaan'] ?? 'N/A',
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 89, 19, 252),
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => buatKkPenanggungJawabPage(no_kk: widget.no_kk.toString()),
                  ),
                );
              },
              child: Icon(Icons.add),
              tooltip: 'Tambah Data KK',
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 207, 212, 78),
              onPressed: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BuatWargaPagePdfPenanggung(no_kk: widget.no_kk.toString()),
                  ),
                );
              },
              child: SvgPicture.asset(
                'assets/images/pdf.svg',
                color: Colors.white,
                width: 30,
                height: 30,
              ),
              tooltip: 'PDF File KK ',
            ),
          ),
        ],
      ),
           
    );
  }

  Widget _buildCard(
      dynamic id,
      String noKk,
      String namaLengkap,
      String nik,
      String jenisKelamin,
      String tempatLahir,
      String tanggalLahir,
      String agama,
      String pendidikan,
      String jenisPekerjaan) {
    int parsedId = int.tryParse(id.toString()) ?? 0;
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
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Nama Lengkap: $namaLengkap',
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'NIK: $nik',
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      Text(
                        'Jenis Kelamin: $jenisKelamin',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Agama: $agama',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      Text(
                        'Tempat Lahir: $tempatLahir',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Pendidikan: $pendidikan',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      Text(
                        'Tanggal Lahir: $tanggalLahir',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Jenis Pekerjaan: $jenisPekerjaan',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF9C4B9),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ubahKkPenanggungJawabPage(id: parsedId),
                            ),
                          );
                        },
                        child: Text('Ubah Data KK',
                            style: GoogleFonts.lato(color: Colors.black)),
                      ),
                    ],
                  ),
                 
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
