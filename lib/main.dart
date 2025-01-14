import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


import 'package:iuran_rt_web/url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iuran_rt_web/screens/login.dart';

import 'package:iuran_rt_web/drawer.dart';

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
      drawer: MyDrawer(),
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
