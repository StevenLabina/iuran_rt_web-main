import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:iuran_rt_web/screens/edit_warga.dart';
import 'package:iuran_rt_web/screens/kk_pemilik_rumah.dart';
import 'package:iuran_rt_web/screens/kk_penanggung_jawab.dart';
import 'package:iuran_rt_web/screens/laporan_revisi.dart';
import 'package:iuran_rt_web/screens/login.dart';
import 'package:iuran_rt_web/url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iuran_rt_web/drawer.dart';

class DataPendudukPage extends StatefulWidget {
  @override
  _DataPendudukPageState createState() => _DataPendudukPageState();
}

class _DataPendudukPageState extends State<DataPendudukPage> {
  List<dynamic> dataPenduduk = [];
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPendudukData();
  }

  @override
  void dispose() {
    super.dispose();
    // Tambahkan logika jika perlu
  }

  Future<void> fetchPendudukData([String query = ""]) async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('${ApiUrls.baseUrl}/listWarga_android.php'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'searchQuery': query,
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['result'] == 'success' && result['data'] != null) {
        setState(() {
          dataPenduduk = result['data'];
        });
      } else {
        setState(() {
          dataPenduduk = [];
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

  Future<void> kirimNotifikasiWA() async {
    final urlNotifikasiWA = '${ApiUrls.baseUrl}/send_whatsapp_iuran_3.php';
    try {
      final responseNotifikasiWA = await http.post(
        Uri.parse(urlNotifikasiWA),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'no': '085934282367'}),
      );

      print('Response Status: ${responseNotifikasiWA.statusCode}');
      print('Response Body: ${responseNotifikasiWA.body}');

      if (responseNotifikasiWA.statusCode == 200) {
        final jsonResponseNotifikasiWA = jsonDecode(responseNotifikasiWA.body);
        if (jsonResponseNotifikasiWA['status'] == 1) {
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

  Future<void> updatePengurusRt(int newId) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiUrls.baseUrl}/newRt.php"),
        body: {
          'id': newId.toString(),
        },
      );

      final json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        fetchPendudukData();
        Fluttertoast.showToast(
          msg: "Berhasil",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyLogin()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(json['message'],
                  style: GoogleFonts.lato(color: Colors.white))),
        );
      }
    } catch (e) {
      print('Error updating pengurus RT: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed to update Pengurus RT",
                style: GoogleFonts.lato(color: Colors.white))),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  // Mengambil lebar layar saat ini
  double screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color(0xFFFDECE8),
      elevation: 0,
    ),
    drawer: MyDrawer(currentPage: 'DataPendudukPage',),
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
              const SizedBox(width: 20),
              Text(
                'Data Warga',
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
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Cari Berdasarkan No Kavling/Nama Penanggung Jawab/Nama Pemilik Rumah ',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              fetchPendudukData(value);
            },
          ),
          SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : dataPenduduk.isEmpty
                    ? Center(
                        child: Text(
                          'Data tidak ditemukan',
                          style: GoogleFonts.lato(color: Colors.black),
                        ),
                      )
                    : ListView.builder(
                        itemCount: dataPenduduk.length,
                        itemBuilder: (context, index) {
                          final penduduk = dataPenduduk[index];
                          return _buildCard(
                            penduduk['no_kavling'] ?? 'N/A',
                            penduduk['alamat_kavling'] ?? 'N/A',
                            penduduk['nama_pemilik_rumah'] ?? 'N/A',
                            penduduk['nama_penanggung_jawab'] ?? 'N/A',
                            penduduk['no_telpon_pemilik_rumah'] ?? 'N/A',
                            penduduk['no_telpon_penanggung_jawab'] ?? 'N/A',
                            penduduk['no_kk_pemilik_rumah'] ?? 'N/A',
                            penduduk['no_kk_penanggung_jawab'] ?? 'N/A',
                            penduduk['id'] ?? 0,
                            penduduk['pengurus_rt'] ?? 0,
                            screenWidth,  // Menambahkan parameter lebar layar untuk menentukan tampilan
                          );
                        },
                      ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildCard(
  String noKavling,
  String alamatKavling,
  String pemilik,
  String penanggungJawab,
  String noTelponPemilik,
  String noTelponPenanggungJawab,
  String noKkPemilikRumah,
  String noKkPenanggungJawab,
  dynamic id,
  int pengurusRt,
  double screenWidth,  // Menambahkan parameter lebar layar untuk menentukan tampilan
) {
  int parsedId = int.tryParse(id.toString()) ?? 0;
  String no_kk_pemilik = noKkPemilikRumah.toString();
  String no_kk_penanggung_jawab = noKkPenanggungJawab.toString();

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16.0),
    child: Card(
      color: Color(0xFFED401C),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // No. Kavling dan Alamat Kavling
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
                                'No. Kavling: $noKavling',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '$alamatKavling',
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF9C4B9),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditDataWargaPage(id: parsedId),
                      ),
                    );
                  },
                  child: Text(
                    screenWidth > 600 ? 'Ubah Data' : 'Ubah\nData', // Menggunakan \n jika lebar layar kecil
                    style: GoogleFonts.lato(color: Colors.black),
                    textAlign: TextAlign.center,  // Memastikan teks terpusat
                    softWrap: true,  // Membungkus teks jika diperlukan
                    maxLines: 2,  // Maksimum dua baris
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Pemilik Rumah
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Pemilik Rumah:',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Menampilkan Nama, No KK, No Telpon di bawah atau samping tergantung lebar layar
            (screenWidth > 800)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _buildInfoColumn(Icons.person, 'Nama: $pemilik'),
                      _buildInfoColumn(Icons.person, 'No KK: $noKkPemilikRumah'),
                      _buildInfoColumn(Icons.phone, 'No. Telepon: $noTelponPemilik'),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.person, 'Nama: $pemilik'),
                      _buildInfoRow(Icons.person, 'No KK: $noKkPemilikRumah'),
                      _buildInfoRow(Icons.phone, 'No. Telepon: $noTelponPemilik'),
                    ],
                  ),
            SizedBox(height: 16),
            
            // Menempatkan tombol "Kartu Keluarga Pemilik Rumah" di atas bagian "Penanggung Jawab"
            Row(
              mainAxisAlignment: MainAxisAlignment.start,  // Mengatur tombol di sebelah kiri
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF9C4B9),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KkPemilikRumahPage(no_kk: no_kk_pemilik),
                      ),
                    );
                  },
                  child: Text(
                    'Kartu Keluarga Pemilik Rumah',
                    style: GoogleFonts.lato(color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Penanggung Jawab
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Penanggung Jawab:',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Menampilkan Nama, No KK, No Telpon di bawah atau samping tergantung lebar layar
            (screenWidth > 800)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _buildInfoColumn(Icons.person, 'Nama: $penanggungJawab'),
                      _buildInfoColumn(Icons.person, 'No KK: $noKkPenanggungJawab'),
                      _buildInfoColumn(Icons.phone, 'No. Telepon: $noTelponPenanggungJawab'),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.person, 'Nama: $penanggungJawab'),
                      _buildInfoRow(Icons.person, 'No KK: $noKkPenanggungJawab'),
                      _buildInfoRow(Icons.phone, 'No. Telepon: $noTelponPenanggungJawab'),
                    ],
                  ),
            SizedBox(height: 16),
            
            // Button "Kartu Keluarga Penanggung Jawab"
            Row(
              mainAxisAlignment: MainAxisAlignment.start,  // Mengatur tombol di sebelah kiri
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
                            KkPenanggungJawabPage(no_kk: no_kk_penanggung_jawab),
                      ),
                    );
                  },
                  child: Text(
                    'Kartu Keluarga Penanggung Jawab',
                    style: GoogleFonts.lato(color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Button "Jadi Pengurus RT"
            if (pengurusRt != 1)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF9C4B9),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Color(0xFFFDECE8),
                        title: Text(
                          'Konfirmasi',
                          style: GoogleFonts.lato(color: Colors.black),
                        ),
                        content: Text(
                          'Apakah Anda yakin ingin menjadikan warga ini sebagai Pengurus RT? \n\nJika iya, Anda akan diarahkan untuk melakukan login ulang, dan status Anda akan berubah menjadi warga.',
                          style: GoogleFonts.lato(color: Colors.black),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Batal',
                              style: GoogleFonts.lato(color: Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              updatePengurusRt(parsedId);
                              kirimNotifikasiWA();
                            },
                            child: Text(
                              'Ya',
                              style: GoogleFonts.lato(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  'Jadi Pengurus RT',
                  style: GoogleFonts.lato(color: Colors.black),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

// Membuat kolom info (untuk tampilan horizontal)
Widget _buildInfoColumn(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, color: Colors.white),
      SizedBox(width: 8),
      Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    ],
  );
}

// Membuat baris info (untuk tampilan vertikal)
Widget _buildInfoRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, color: Colors.white),
      SizedBox(width: 8),
      Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    ],
  );
}

}

void main() {
  runApp(MaterialApp(
    home: DataPendudukPage(),
  ));
}
