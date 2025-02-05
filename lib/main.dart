import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      total = totalController.text.isNotEmpty
          ? totalController.text
          : '0';

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
            total = data['total_data'].toString();
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
  title: Row(
    children: [
      Text(
        "Menu Layanan Pengurus RT",
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
),
drawer: MyDrawer(currentPage: 'MainScreen',),

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
            Positioned(
              bottom: 0, 
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Selamat Datang Di\n',
                            style: TextStyle(
                              color: Color(0xFF181C14),
                              fontSize: MediaQuery.of(context).size.width > 600
                                  ? 50  // Ukuran lebih besar untuk tablet/laptop
                                  : (MediaQuery.of(context).size.width > 400
                                      ? 40  // Ukuran medium untuk tablet/ipad
                                      : 30), // Ukuran kecil untuk ponsel
                              fontFamily: 'Figtree',
                              fontWeight: FontWeight.w400,
                              height: 1.2, 
                            ),
                          ),
                          TextSpan(
                            text: alamatKavling,
                            style: TextStyle(
                              color: Color(0xFF181C14),
                              fontSize: MediaQuery.of(context).size.width > 600
                                  ? 50 
                                  : (MediaQuery.of(context).size.width > 400
                                      ? 40
                                      : 30), 
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
                        height: 1.5, 
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
