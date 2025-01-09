import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iuran_rt_web/url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iuran_rt_web/main.dart';
import 'package:flutter/services.dart';

class MyLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iuran RT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String username = '';
  String password = '';
  String errorLogin = '';
  bool _loading = false;

  final TextEditingController _noKavlingController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
    bool obscureText = true;

  void doLogin() async {
    setState(() {
      _loading = true;
    });

    try {
      print(
          'Attempting login with username: $username and password: $password');

      final response = await http.post(
        Uri.parse("${ApiUrls.baseUrl}/login.php"),
        body: {
          'no_kavling': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        print('Response body: ${response.body}');

        if (json['result'] == 'success') {
          final prefs = await SharedPreferences.getInstance();

          String alamatKavling = json['data']['alamat_kavling'] ?? '';
          String username = json['data']['nama_pemilik_rumah'] ?? '';
          String noTelpon = json['data']['no_telpon_pemilik'] ?? '';
          int idUser = int.tryParse(json['data']['id'] ?? '0') ?? 0;
          bool isAdmin =
              int.tryParse(json['data']['pengurus_rt'].toString()) == 1;

          prefs.setString("alamatKavling", alamatKavling);
          prefs.setString("username", username);
          prefs.setString("noTelpon", noTelpon);
          prefs.setInt("idUser", idUser);
          prefs.setBool("isAdmin", isAdmin);
          print("username: $username");
          print("noTelpon: $noTelpon");
          print("id user: $idUser");
     
          if (isAdmin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          } else {
            setState(() {
              errorLogin = "Pesan: Tidak memiliki akses untuk masuk layanan ini.";
            });
          }
        } else {
          setState(() {
            errorLogin = "Pesan: Alamat kavling atau kata sandi anda tidak sesuai";
          });
        }
      } else {
        throw Exception('Failed to read API');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        errorLogin = "Failed to connect to server";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
  Future<Map<String, dynamic>> transferMandiri() async {
    final url = Uri.parse('${ApiUrls.baseUrl}/transfer_mandiri.php');

    try {
     
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'usrapi': 'steven',
          'password': 'St3v3n*_Apikk0',
          'refnum': 'HK202411020000002',
          'account': '1400018057696',
          'amount': 10000,
          'remark': 'testing',
          'transdate': '2024-12-02',
        }),
      );

   
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == true) {
          return {
            'status': true,
            'message': 'Transfer berhasil',
            'data': responseData,
          };
        } else {
          return {
            'status': false,
            //'message': responseData['msg'] ?? 'Terjadi kesalahan',
            'message': 'Terjadi kesalahan',
          };
        }
      } else {
        return {
          'status': false,
          'message':
              'Gagal terhubung ke server. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
  
      return {
        'status': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          // Semi-transparent white overlay
          Container(
            color: Colors.white.withOpacity(0.8),
          ),

          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: 597,
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 30.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          child: Center(
                            child: Image.asset(
                              'assets/images/Logo2.png',
                              width: 200, 
                              height: 200, 
                              fit: BoxFit.fill, 
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        SizedBox(
                          width: 597,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Selamat datang di\n',
                                  style: TextStyle(
                                    color: Color(0xFF181C14),
                                    fontSize: 18,
                                    fontFamily: 'Figtree',
                                    fontWeight: FontWeight.w600,
                                    height: 0,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Iuran RT Online',
                                  style: TextStyle(
                                    color: Color(0xFF181C14),
                                    fontSize: 24,
                                    fontFamily: 'Figtree',
                                    fontWeight: FontWeight.w700,
                                    height: 0,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildTextField(
                            'Alamat Kavling', _noKavlingController, false),
                        SizedBox(height: 15),
                                             Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _buildTextField(
                                'Kata Sandi', _passwordController, obscureText),
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
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscureText = !obscureText;
                                });
                              },
                              icon: Icon(
                                obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                        SizedBox(height: 20),
                        _loading
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              )
                            : ElevatedButton(
                                onPressed: doLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFED401C),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size(double.infinity, 60),
                                ),
                                child: const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: 'Figtree',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                        if (errorLogin.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              errorLogin,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label, TextEditingController controller, bool obscureText) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 478.45,
        child: Text(
          label,
          style: TextStyle(
            color: Color(0xFF8B8B8B),
            fontSize: 18,
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      SizedBox(height: 11.86),
      TextField(
        controller: controller,
        onChanged: (value) {
          setState(() {
            if (controller == _noKavlingController) {
              username = value;
            } else if (controller == _passwordController) {
              password = value;
            }
          });
        },
        obscureText: obscureText,
        inputFormatters: [LengthLimitingTextInputFormatter(16)], 
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 16.0,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.47),
            borderSide: const BorderSide(
              width: 0.85,
              color: Color(0xFFBBBBBB),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.47),
            borderSide: const BorderSide(
              width: 0.85,
              color: Color(0xFFBBBBBB),
            ),
          ),
        ),
      ),
    ],
  );
}

}
