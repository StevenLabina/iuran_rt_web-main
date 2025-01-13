import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:iuran_rt_web/screens/buat_informasi.dart';
import 'package:iuran_rt_web/screens/bukti_transaksi.dart';
import 'package:iuran_rt_web/screens/histori_kk_pemilik.dart';
import 'package:iuran_rt_web/screens/histori_transaksi.dart';
import 'package:iuran_rt_web/screens/laporan_revisi.dart';
import 'package:iuran_rt_web/screens/rekap_iuran_warga.dart';
import 'package:iuran_rt_web/url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iuran_rt_web/screens/login.dart';
import 'package:iuran_rt_web/screens/buat_warga.dart';
import 'package:iuran_rt_web/screens/data_warga.dart';
import 'package:iuran_rt_web/screens/buat_iuran.dart';
import 'package:iuran_rt_web/screens/petunjuk.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iuran RT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CheckLogin(),
    );
  }
}

class CheckLogin extends StatefulWidget {
  @override
  _CheckLoginState createState() => _CheckLoginState();
}

class _CheckLoginState extends State<CheckLogin> {
  String? username;
  bool? isAdmin;
  String? total;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
      isAdmin = prefs.getBool('isAdmin');
      int? idUser = prefs.getInt('idUser');
      print("User ID: $idUser");

      if (isAdmin == null || isAdmin == false) {
        print("You do not have admin access.");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyLogin()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (username == null) {
      return MyLogin();
    } else {
      if (isAdmin == true) {
        return MainScreen();
      } else {
        return MainScreen();
      }
    }
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String alamatKavling = '';
  String total = '';
  String username = '';
  List<dynamic> iuranList = [];
  TextEditingController totalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAlamatKavling();
    // _fetchIuranData();
    _jumlahKavling();
  }

  Future<void> _loadAlamatKavling() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      alamatKavling = prefs.getString("alamatKavling") ?? '';
      username = prefs.getString("username") ?? '';
    });
  }

  // Future<void> _fetchIuranData() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     int? idUser = prefs.getInt("idUser");

  //     if (idUser == null) {
  //       throw Exception("User ID is null");
  //     }

  //     print("Fetched ID User: $idUser");

  //     final response = await http.post(
  //       Uri.parse('${ApiUrls.baseUrl}/iuran_terdekat.php'),
  //       body: {
  //         "id_warga": idUser.toString(),
  //       },
  //     );
  //     print("Response status: ${response.statusCode}");
  //     print("Response body: ${response.body}");

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);

  //       if (data['result'] == 'success' && data.containsKey('data')) {
  //         setState(() {
  //           iuranList = List.from(data['data']);
  //         });
  //       } else if (data['result'] == 'error' && data.containsKey('message')) {
  //         throw Exception('Server Error: ${data['message']}');
  //       } else {
  //         throw Exception('Unexpected server response');
  //       }
  //     } else {
  //       throw Exception(
  //           'Failed to connect to server with status code ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print("Error fetching iuran data: $e");
  //   }
  // }

  Future<void> _jumlahKavling() async {
    try {
      // Ambil nilai dari TextField atau set langsung ke variabel total
      total = totalController.text.isNotEmpty
          ? totalController.text
          : '0'; // Default ke '0' jika kosong

      final response = await http.post(
        Uri.parse('${ApiUrls.baseUrl}/jumlahKavling.php'),
        body: {
          "total": total,
        },
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['result'] == 'success' && data.containsKey('total_data')) {
          setState(() {
            total = data['total_data'].toString(); // Perbaikan di sini
          });
        } else if (data['result'] == 'error' && data.containsKey('message')) {
          throw Exception('Server Error: ${data['message']}');
        } else {
          throw Exception('Unexpected server response');
        }
      } else {
        throw Exception(
            'Failed to connect to server with status code ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching iuran data: $e");
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyLogin()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFDECE8),
        elevation: 0,
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 250,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Nama Pengurus RT : ${username} ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Warna teks
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.home,
                      size: 40.0,
                      color: Colors.red,
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$alamatKavling',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Total Kavling: $total unit',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Menu Utama',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            //BUAT IURAN
            Container(
              width: 470,
              height: 90,
              padding: const EdgeInsets.only(
                top: 10,
                left: 20,
                right: 30,
                bottom: 10,
              ),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TambahInformasiPage()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info,
                      color: Color(0xFF8B8B8B),
                      size: 30,
                    ),
                    // Icon(Icons.monetization_on,
                    //     size: 24, color: Color(0xFF8B8B8B)),
                    const SizedBox(width: 14),
                    Text(
                      'Buat Pengumuman atau \n'
                      'Informasi Untuk Warga',
                      style: TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 16,
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 261,
              height: 65,
              padding: const EdgeInsets.only(
                top: 10,
                left: 20,
                right: 30,
                bottom: 10,
              ),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TambahIuranPage()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/images/HandCoins.svg'),
                    // Icon(Icons.monetization_on,
                    //     size: 24, color: Color(0xFF8B8B8B)),
                    const SizedBox(width: 14),
                    Text(
                      'Buat Tagihan Iuran Untuk\n'
                      'Warga',
                      style: TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 16,
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //BUAT WARGA
            Container(
              width: 261,
              height: 80,
              padding: const EdgeInsets.only(
                top: 10,
                left: 20,
                right: 30,
                bottom: 10,
              ),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BuatWargaPage()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/images/UserPlus.svg'),
                    const SizedBox(width: 14),
                    Text(
                      'Buat Rincian Isi Data\nWarga',
                      style: TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 16,
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 261,
              height: 50,
              padding: const EdgeInsets.only(
                top: 10,
                left: 20,
                right: 30,
                bottom: 10,
              ),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DataPendudukPage()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/images/UsersFour.svg'),
                    // Icon(Icons.person_3, size: 24, color: Color(0xFF8B8B8B)),
                    const SizedBox(width: 14),
                    Text(
                      'Data Warga',
                      style: TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 16,
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //REKAP IURAN WARGA
            Container(
              width: 261,
              height: 65,
              padding: const EdgeInsets.only(
                top: 10,
                left: 20,
                right: 30,
                bottom: 10,
              ),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BuktiTransaksiPage()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/images/ChartDonut.svg'),
                    const SizedBox(width: 14),
                    Text(
                      'Laporan Iuran Tunai Warga',
                      style: TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 16,
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 261,
              height: 65,
              padding: const EdgeInsets.only(
                top: 10,
                left: 20,
                right: 30,
                bottom: 10,
              ),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RekapIuranWargaPage()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/images/ChartDonut.svg'),
                    const SizedBox(width: 14),
                    Text(
                      'Laporan Kewajiban Iuran\n'
                      'Warga',
                      style: TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 16,
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 261,
              height: 90,
              padding: const EdgeInsets.only(
                top: 10,
                left: 20,
                right: 30,
                bottom: 10,
              ),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LaporanRevisiDataPage()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/images/ChartDonut.svg'),
                    const SizedBox(width: 14),
                    Text(
                      'Laporan Revisi Perubahan\n'
                      'Data Warga',
                      style: TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 16,
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 261,
              height: 65,
              padding: const EdgeInsets.only(
                top: 10,
                left: 20,
                right: 30,
                bottom: 10,
              ),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HistoriTransaksiPage()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/Receipt.svg',
                      width: 30,
                      height: 31,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Rekap Pelunasan Iuran\n'
                      'Warga',
                      style: TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 16,
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 261,
              height: 65,
              padding: const EdgeInsets.only(
                top: 10,
                left: 20,
                right: 30,
                bottom: 10,
              ),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HistoriKkPemilikPage()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/Receipt.svg',
                      width: 30,
                      height: 31,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Rekap Kumpulan KK Warga',
                      style: TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 16,
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //DATA WARGA

            Divider(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Lainnya',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),

            Container(
              color: Color.fromARGB(255, 255, 255, 255),
              child: ListTile(
                leading: SvgPicture.asset('assets/images/SealQuestion.svg'),
                // leading: Icon(Icons.help, color: Color(0xFF8B8B8B)),
                title: Text(
                  'Petunjuk',
                  style: TextStyle(color: Color(0xFF8B8B8B)),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PetunjukPage()),
                  );
                },
              ),
            ),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                onPressed: logout,
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'Keluar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/trr.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              color: Colors.white.withOpacity(0.8),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 40.0), 
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Selamat Datang Di\n',
                            style: TextStyle(
                              color: Color(0xFF181C14),
                              fontSize: 60,
                              fontFamily: 'Figtree',
                              fontWeight: FontWeight.w400,
                              height: 1.2, // Sesuaikan jarak antar teks
                            ),
                          ),
                          TextSpan(
                            text: alamatKavling,
                            style: const TextStyle(
                              color: Color(0xFF181C14),
                              fontSize: 60,
                              fontFamily: 'Figtree',
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Layanan Digital Terpadu Untuk Warga RT 8-RW 1-Kelurahan Medokan Ayu Rungkut',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF181C14),
                        fontSize: 18,
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w400,
                        height: 1.5, // Sesuaikan jarak antar baris
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
