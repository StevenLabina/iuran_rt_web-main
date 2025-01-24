import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iuran_rt_web/main.dart';

import 'package:iuran_rt_web/screens/buat_informasi.dart';
import 'package:iuran_rt_web/screens/bukti_transaksi.dart';
import 'package:iuran_rt_web/screens/histori_kk_pemilik.dart';
import 'package:iuran_rt_web/screens/histori_transaksi.dart';
import 'package:iuran_rt_web/screens/histori_transaksi_belum_lunas.dart';
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

class MyDrawer extends StatefulWidget {
  final String currentPage; // Parameter halaman aktif

  MyDrawer({required this.currentPage});

    @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
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
    return Drawer(
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
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
              color: widget.currentPage == 'TambahInformasiPage'
                  ? Colors.red.withOpacity(0.1)
                  : Colors.white,
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
                    color: widget.currentPage == 'TambahInformasiPage'
                        ? Colors.red
                        : Color(0xFF8B8B8B),
                    size: 30,
                  ),
                  // Icon(Icons.monetization_on,
                  //     size: 24, color: Color(0xFF8B8B8B)),
                  const SizedBox(width: 14),
                  Text(
                    'Buat Pengumuman atau \n'
                    'Informasi Untuk Warga',
                    style: TextStyle(
                      color: widget.currentPage == 'TambahInformasiPage'
                          ? Colors.red
                          : Color(0xFF8B8B8B),
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
              color: widget.currentPage == 'TambahIuranPage'
                  ? Colors.red.withOpacity(0.1)
                  : Colors.white,
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
                  SvgPicture.asset(
                    'assets/images/HandCoins.svg',
                    width: 30,
                    height: 31,
                    color: widget.currentPage == 'TambahIuranPage'
                        ? Colors.red // Warna saat selected
                        : Color(0xFF8B8B8B), // Warna default
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Buat Tagihan Iuran Untuk\n'
                    'Warga',
                    style: TextStyle(
                      color: widget.currentPage == 'TambahIuranPage'
                          ? Colors.red
                          : Color(0xFF8B8B8B),
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
              color: widget.currentPage == 'BuatWargaPage'
                  ? Colors.red.withOpacity(0.1)
                  : Colors.white,
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
                  SvgPicture.asset(
                    'assets/images/UserPlus.svg',
                    width: 30,
                    height: 31,
                    color: widget.currentPage == 'BuatWargaPage'
                        ? Colors.red // Warna saat selected
                        : Color(0xFF8B8B8B), // Warna default
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Buat Rincian Isi Data\nWarga',
                    style: TextStyle(
                      color: widget.currentPage == 'BuatWargaPage'
                          ? Colors.red
                          : Color(0xFF8B8B8B),
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
              color: widget.currentPage == 'DataPendudukPage'
                  ? Colors.red.withOpacity(0.1)
                  : Colors.white,
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
                  SvgPicture.asset(
                    'assets/images/UsersFour.svg',
                    width: 30,
                    height: 31,
                    color: widget.currentPage == 'DataPendudukPage'
                        ? Colors.red // Warna saat selected
                        : Color(0xFF8B8B8B), // Warna default
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Data Warga',
                    style: TextStyle(
                      color: widget.currentPage == 'DataPendudukPage'
                          ? Colors.red
                          : Color(0xFF8B8B8B),
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
              color: widget.currentPage == 'BuktiTransaksiPage'
                  ? Colors.red.withOpacity(0.1)
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BuktiTransaksiPage()),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/ChartDonut.svg',
                    width: 30,
                    height: 31,
                    color: widget.currentPage == 'BuktiTransaksiPage'
                        ? Colors.red // Warna saat selected
                        : Color(0xFF8B8B8B), // Warna default
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Laporan Iuran Tunai Warga',
                    style: TextStyle(
                      color: widget.currentPage == 'BuktiTransaksiPage'
                          ? Colors.red
                          : Color(0xFF8B8B8B),
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
              color: widget.currentPage == 'RekapIuranWargaPage'
                  ? Colors.red.withOpacity(0.1)
                  : Colors.white,
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
                  SvgPicture.asset(
                    'assets/images/ChartDonut.svg',
                    width: 30,
                    height: 31,
                    color: widget.currentPage == 'RekapIuranWargaPage'
                        ? Colors.red // Warna saat selected
                        : Color(0xFF8B8B8B), // Warna default
                  ),
                  const SizedBox(width :14),
                  Text(
                    'Laporan Transaksi Iuran\n'
                    'Warga',
                    style: TextStyle(
                      color: widget.currentPage == 'RekapIuranWargaPage'
                          ? Colors.red
                          : Color(0xFF8B8B8B),
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
              color: widget.currentPage == 'LaporanRevisiDataPage'
                  ? Colors.red.withOpacity(0.1)
                  : Colors.white,
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
                  SvgPicture.asset(
                    'assets/images/ChartDonut.svg',
                    width: 30,
                    height: 31,
                    color: widget.currentPage == 'LaporanRevisiDataPage'
                        ? Colors.red // Warna saat selected
                        : Color(0xFF8B8B8B), // Warna default
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Laporan Revisi Perubahan\n'
                    'Data Warga',
                    style: TextStyle(
                      color: widget.currentPage == 'LaporanRevisiDataPage'
                          ? Colors.red
                          : Color(0xFF8B8B8B),
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
              color: widget.currentPage == 'HistoriTransaksiBelumPage'
                  ? Colors.red.withOpacity(0.1)
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HistoriTransaksiBelumPage()),
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
                    color: widget.currentPage == 'HistoriTransaksiBelumPage'
                        ? Colors.red // Warna saat selected
                        : Color(0xFF8B8B8B), // Warna default
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Rekap Iuran Warga Yang\n'
                    'Belum Lunas',
                    style: TextStyle(
                      color: widget.currentPage == 'HistoriTransaksiBelumPage'
                          ? Colors.red
                          : Color(0xFF8B8B8B),
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
              color: widget.currentPage == 'HistoriTransaksiPage'
                  ? Colors.red.withOpacity(0.1)
                  : Colors.white,
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
                    color: widget.currentPage == 'HistoriTransaksiPage'
                        ? Colors.red // Warna saat selected
                        : Color(0xFF8B8B8B), // Warna default
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Rekap Iuran Warga Yang\n'
                    'Sudah Lunas',
                    style: TextStyle(
                      color: widget.currentPage == 'HistoriTransaksiPage'
                          ? Colors.red
                          : Color(0xFF8B8B8B),
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
              color: widget.currentPage == 'HistoriKkPemilikPage'
                  ? Colors.red.withOpacity(0.1)
                  : Colors.white,
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
                    color: widget.currentPage == 'HistoriKkPemilikPage'
                        ? Colors.red // Warna saat selected
                        : Color(0xFF8B8B8B), // Warna default
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Rekap Kumpulan KK Warga',
                    style: TextStyle(
                      color: widget.currentPage == 'HistoriKkPemilikPage'
                          ? Colors.red
                          : Color(0xFF8B8B8B),
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
            width: 261,
            height: 65,
            padding: const EdgeInsets.only(
              top: 10,
              left: 20,
              right: 30,
              bottom: 10,
            ),
            decoration: ShapeDecoration(
              color: widget.currentPage == 'PetunjukPage'
                  ? Colors.red.withOpacity(0.1)
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PetunjukPage()),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/SealQuestion.svg',
                    width: 30,
                    height: 31,
                    color: widget.currentPage == 'PetunjukPage'
                        ? Colors.red // Warna saat selected
                        : Color(0xFF8B8B8B), // Warna default
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Petunjuk',
                    style: TextStyle(
                      color: widget.currentPage == 'PetunjukPage'
                          ? Colors.red
                          : Color(0xFF8B8B8B),
                      fontSize: 16,
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Container(
          //   color: Color.fromARGB(255, 255, 255, 255),
          //   child: ListTile(
          //     leading: SvgPicture.asset('assets/images/SealQuestion.svg'),
          //     // leading: Icon(Icons.help, color: Color(0xFF8B8B8B)),
          //     title: Text(
          //       'Petunjuk',
          //       style: TextStyle(
          //                 color: widget.currentPage == 'PetunjukPage'
          //                 ? Colors.red
          //                 : Color(0xFF8B8B8B),
          //             fontSize: 16,
          //             fontFamily: 'Figtree',
          //             fontWeight: FontWeight.w500,
          //           ),
          //     ),
          //     onTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => PetunjukPage()),
          //       );
          //     },
          //   ),
          // ),

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
              color: widget.currentPage == 'MainScreen'
                  ? Colors.red.withOpacity(0.1)
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainScreen()),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home,
                    color: widget.currentPage == 'MainScreen'
                        ? Colors.red
                        : Color(0xFF8B8B8B),
                    size: 30,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Halaman Utama',
                    style: TextStyle(
                      color: widget.currentPage == 'MainScreen'
                          ? Colors.red
                          : Color(0xFF8B8B8B),
                      fontSize: 16,
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Container(
          //   color: Color.fromARGB(255, 255, 255, 255),
          //   child: ListTile(
          //     leading: Icon(
          //       Icons.home,
          //       size: 30.0,
          //       color: Color(0xFF8B8B8B),
          //     ),
          //     title: Text(
          //       'Halaman Utama',
          //       style: TextStyle(
          //                 color: widget.currentPage == 'MainScreen'
          //                 ? Colors.red
          //                 : Color(0xFF8B8B8B),
          //             fontSize: 16,
          //             fontFamily: 'Figtree',
          //             fontWeight: FontWeight.w500,
          //           ),
          //     ),
          //     onTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => MainScreen()),
          //       );
          //     },
          //   ),
          // ),

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
    );
  }
}
