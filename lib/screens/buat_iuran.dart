import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:iuran_rt_web/screens/buat_iuran_ipl.dart';
import 'package:iuran_rt_web/url.dart';
import 'package:iuran_rt_web/main.dart';
import 'package:iuran_rt_web/drawer.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';
class TambahIuranPage extends StatefulWidget {
  @override
  _TambahIuranPageState createState() => _TambahIuranPageState();
}

class _TambahIuranPageState extends State<TambahIuranPage> {
  final TextEditingController _namaIuranController = TextEditingController();
  final TextEditingController _nominalIuranController = TextEditingController();
  final TextEditingController _batasTransaksiController =
      TextEditingController();
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // _firebaseMessaging.requestPermission();
    // _firebaseMessaging.getToken().then((token) {
    //   print("Firebase Token: $token");
    // });
      
  }

// Future<void> kirimNotifikasi(String idIuran) async {
//   final urlNotifikasi = '${ApiUrls.baseUrl}/kirimNotifikasi.php';

//   final bodyNotifikasi = {
//     'id_iuran': idIuran,
//     'judul': 'Iuran Baru Ditambahkan',
//     'pesan': 'Iuran ${_namaIuranController.text} telah ditambahkan.'
//   };

//   try {
//     final responseNotifikasi = await http.post(
//       Uri.parse(urlNotifikasi),
//       body: bodyNotifikasi,
//     );

//     if (responseNotifikasi.statusCode == 200) {
//       print('Notifikasi berhasil dikirim');
//       SnackBar(content: Text('Notifikasi dirikirim'));
//        print(' notifikasi: ${responseNotifikasi.body}');
//     } else {
//       print('Gagal mengirim notifikasi: ${responseNotifikasi.statusCode}');
//       print('Gagal mengirim notifikasi: ${responseNotifikasi.body}');
//       SnackBar(content: Text('Gagal mengirim notifikasi!'));
//     }
//   } catch (e) {
//     print('Error: Gagal terhubung ke server notifikasi $e');
//     SnackBar(content: Text('Gagal terhubung ke server!'));
//   }
// }
 
  Future<void> simpanIuran() async {
    if (_namaIuranController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nama Iuran tidak boleh kosong!')),
      );
      return;
    }

    if (_nominalIuranController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nominal Iuran tidak boleh kosong!')),
      );
      return;
    }

    if (_batasTransaksiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Batas Transaksi tidak boleh kosong!')),
      );
      return;
    }

    final urlIuran = '${ApiUrls.baseUrl}/buatIuran.php';

    final bodyIuran = {
      'nama_iuran': _namaIuranController.text,
      'nominal_iuran': _nominalIuranController.text,
      'batas_pembayaran': _selectedDate != null
          ? (_selectedDate!.millisecondsSinceEpoch ~/ 1000).toString()
          : '',
    };

    try {
      final responseIuran = await http.post(
        Uri.parse(urlIuran),
        body: bodyIuran,
      );

      if (responseIuran.statusCode == 200) {
        final jsonResponseIuran = jsonDecode(responseIuran.body);
        if (jsonResponseIuran['result'] == 'success') {
          final idIuran = jsonResponseIuran['id'];
          await simpanRekap(idIuran);

          Fluttertoast.showToast(
              msg: "Iuran berhasil",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black38,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${jsonResponseIuran['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Gagal menyimpan data. Kode: ${responseIuran.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Gagal terhubung ke server')),
      );
    }
  }
  Future<void> ipl() async {
    DateTime now = DateTime.now();
    String month = DateFormat('MMMM').format(now);
    final urlIuran = '${ApiUrls.baseUrl}/buatIuran.php';

    final bodyIuran = {
      'nama_iuran': "Iuran ${now.toString()}",
      'nominal_iuran': _nominalIuranController.text,
      'batas_pembayaran': _selectedDate != null
          ? (_selectedDate!.millisecondsSinceEpoch ~/ 1000).toString()
          : '',
    };

    try {
      final responseIuran = await http.post(
        Uri.parse(urlIuran),
        body: bodyIuran,
      );

      if (responseIuran.statusCode == 200) {
        final jsonResponseIuran = jsonDecode(responseIuran.body);
        if (jsonResponseIuran['result'] == 'success') {
          final idIuran = jsonResponseIuran['id'];
          await simpanRekap(idIuran);

          Fluttertoast.showToast(
              msg: "Iuran berhasil",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black38,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${jsonResponseIuran['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Gagal menyimpan data. Kode: ${responseIuran.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Gagal terhubung ke server')),
      );
    }
  }

 Future<void> kirimNotifikasiWA() async {
  final urlNotifikasiWA = '${ApiUrls.baseUrl}/whatsapp_api.php';
  try {
    final responseNotifikasiWA = await http.post(
      Uri.parse(urlNotifikasiWA),
      body: {
        'msg': 'Haloo, ada iuran "${_namaIuranController.text}" dengan nominal Rp${_nominalIuranController.text}',
      },
    );

    if (responseNotifikasiWA.statusCode == 200) {
      final jsonResponseNotifikasiWA = jsonDecode(responseNotifikasiWA.body);
      if (jsonResponseNotifikasiWA['status'] == true) {
        print('Notifikasi WhatsApp berhasil dikirim.');
      } else {
        print('Gagal mengirim notifikasi WhatsApp: ${jsonResponseNotifikasiWA['error'] ?? 'Kesalahan tidak diketahui'}');
      }
    } else {
      print('Gagal mengirim notifikasi WhatsApp: Status Code ${responseNotifikasiWA.statusCode}');
    }
  } catch (e) {
    print('Error: Gagal terhubung ke server WhatsApp $e');
  }
}


//   Future<void> kirimNotifikasiWA() async {
//   final urlNotifikasiWA = '${ApiUrls.baseUrl}/send_whatsapp_iuran_2.php';
//   try {
//     final responseNotifikasiWA = await http.post(
//       Uri.parse(urlNotifikasiWA),
//       body: {
//         'msg':
//             'PENGUMUMAN IURAN RT ONLINE\nIuran Baru: ${_namaIuranController.text}.\nNominal: ${_nominalIuranController.text}\nAyo buruan bayar pakai iuran rt online',
//         'test_mode': 'true', // Aktifkan mode pengujian
//       },
//     );

//     if (responseNotifikasiWA.statusCode == 200) {
//       final jsonResponseNotifikasiWA = jsonDecode(responseNotifikasiWA.body);

   
//       String hasilTestApi = jsonEncode(jsonResponseNotifikasiWA);
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Hasil Test API'),
//             content: SingleChildScrollView(
//               child: Text(hasilTestApi),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//     } else {
//       print('Gagal mengirim notifikasi WhatsApp: ${responseNotifikasiWA.statusCode}');
//     }
//   } catch (e) {
//     print('Error: Gagal terhubung ke server WhatsApp $e');
//   }
// }

  Future<void> simpanRekap(int idIuran) async {
    final urlRekap = '${ApiUrls.baseUrl}/tambahRekapKhusus.php';
    final bodyRekap = {
      'id_iuran': idIuran.toString(),
    };

    try {
      final responseRekap = await http.post(
        Uri.parse(urlRekap),
        body: bodyRekap,
      );

      if (responseRekap.statusCode == 200) {
        final jsonResponseRekap = jsonDecode(responseRekap.body);
        if (jsonResponseRekap['result'] == 'success') {
          // await kirimNotifikasi(idIuran.toString());
          await kirimNotifikasiWA();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${jsonResponseRekap['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan rekap.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Gagal terhubung ke server')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        _batasTransaksiController.text =
            DateFormat('dd/MM/yyyy-11:59').format(_selectedDate!);
      });
  }

  void _showConfirmationDialog() {
    if (_namaIuranController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Nama Iuran tidak boleh kosong",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    if (_nominalIuranController.text.isEmpty || _nominalIuranController.text == "0" ) {
      Fluttertoast.showToast(
          msg: "Nominal iuran tidak boleh kosong",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    if (_batasTransaksiController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Batas transaksi tidak boleh kosong",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFFDECE8),
          title:
              Text('Konfirmasi', style: GoogleFonts.lato(color: Colors.black)),
          content: Text('Apakah Anda yakin ingin menyimpan data ini?',
              style: GoogleFonts.lato(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              child: Text('Batal', style: GoogleFonts.lato(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Simpan', style: GoogleFonts.lato(color: Colors.red)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
                simpanIuran();
                kirimNotifikasiWA();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _namaIuranController.dispose();
    _nominalIuranController.dispose();
    _batasTransaksiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600; // Misalkan 600px sebagai batas untuk mobile

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFFDECE8),
        elevation: 0,
      ),
      drawer: MyDrawer(),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/pexels-thelazyartist-1642125.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Color(0xFFFDECE8),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 80), // Padding lebih kecil untuk mobile
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: isMobile ? screenSize.width * 0.9 : 567,
                      height: 80,
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/HandCoins.svg',
                            color: Colors.black,
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(width: 20),
                          Flexible(
                            child: Text(
                              'Buat Tagihan Iuran',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color(0xFF181C14),
                                fontSize: isMobile ? 24 : 40, // Ukuran font lebih kecil untuk mobile
                                fontFamily: 'Figtree',
                                fontWeight: FontWeight.w600,
                                height: 1.2, // Tinggi baris untuk menghindari tumpang tindih
                              ),
                              maxLines: 2, // Maksimal 2 baris
                              overflow: TextOverflow.ellipsis, // Menghindari overflow
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: isMobile ? screenSize.width * 0.9 : 567,
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              'Iuran Khusus',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 14 : 18, // Ukuran font lebih kecil untuk mobile
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => TambahIuranPLPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              'Iuran Pengelolaan Lingkungan',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: isMobile ? 14 : 18, // Ukuran font lebih kecil untuk mobile
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: isMobile ? screenSize.width * 0.9 : 1000,
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
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.money, color: Color(0xFF909090)),
                                SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _namaIuranController,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      hintText: 'Ketik Nama Iuran...',
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
                                Text("Rp"),
                                SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _nominalIuranController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      hintText: 'Ketik Nominal Iuran... (Jika sukarela tuliskan 0)',
                                    ),
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        String numericValue = value.replaceAll(RegExp(r'\D'), '');
                                        String formattedValue = NumberFormat.decimalPattern('id').format(
                                          int.parse(numericValue.isEmpty ? '0' : numericValue),
                                        );
                                        _nominalIuranController.value = TextEditingValue(
                                          text: formattedValue,
                                          selection: TextSelection.collapsed(
                                            offset: formattedValue.length,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: isMobile ? screenSize.width * 0.9 : 1000,
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
                        children: [
                          Icon(Icons.calendar_today, color: Color(0xFF909090)),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _batasTransaksiController,
                              readOnly: true,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                hintText: 'Pilih Tanggal Batas Transaksi',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            onPressed: () => _selectDate(context),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
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
                              fontSize: isMobile ? 16 : 20, // Ukuran font lebih kecil untuk mobile
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
}
