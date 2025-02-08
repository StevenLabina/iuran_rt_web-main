import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:iuran_rt_web/drawer.dart';
import 'package:iuran_rt_web/screens/buat_iuran.dart';
import 'package:iuran_rt_web/url.dart';
import 'package:iuran_rt_web/main.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';
class TambahIuranPLPage extends StatefulWidget {
  @override
  _TambahIuranPLPageState createState() => _TambahIuranPLPageState();
}

class _TambahIuranPLPageState extends State<TambahIuranPLPage> {
  
  final TextEditingController _nominalIuranController = TextEditingController();
  final TextEditingController _namaIuranController = TextEditingController();
  final TextEditingController _batasTransaksiController =
      TextEditingController();

 
  

  DateTime? _selectedDate, now;
  String month = DateFormat('MMMM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
   
      
  }


 
 Future<void> simpanIuran() async {
  final urlIuran = '${ApiUrls.baseUrl}/buatIuranIpl.php';

  final bodyIuran = {
    'nama_iuran': _namaIuranController.text,
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
        final data = jsonResponseIuran['data'];
        final idIuran1 = data[0]['id'];
        final idIuran2 = data[1]['id'];
        final idIuran3 = data[2]['id'];
        final idIuran4 = data[3]['id'];
        final idIuran5 = data[4]['id'];
        final idIuran6 = data[5]['id'];


        await simpanRekap(idIuran1, idIuran2, idIuran3, idIuran4, idIuran5, idIuran6);

        Fluttertoast.showToast(
          msg: "Iuran berhasil",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${jsonResponseIuran['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Gagal menyimpan data. Kode: ${responseIuran.statusCode}'),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: Gagal terhubung ke server')),
    );
  }
}

//  Future<void> kirimNotifikasiWA() async {
//   final urlNotifikasiWA = '${ApiUrls.baseUrl}/whatsapp_api.php';
//   try {
//     final responseNotifikasiWA = await http.post(
//       Uri.parse(urlNotifikasiWA),
//       body: {
//         'msg': 'Haloo, ada iuran pengelolaan lahan "${month.toString()}" dengan nominal Rp${_nominalIuranController.text}',
//       },
//     );

//     if (responseNotifikasiWA.statusCode == 200) {
//       final jsonResponseNotifikasiWA = jsonDecode(responseNotifikasiWA.body);
//       if (jsonResponseNotifikasiWA['status'] == true) {
//         print('Notifikasi WhatsApp berhasil dikirim.');
//       } else {
//         print('Gagal mengirim notifikasi WhatsApp: ${jsonResponseNotifikasiWA['error'] ?? 'Kesalahan tidak diketahui'}');
//       }
//     } else {
//       print('Gagal mengirim notifikasi WhatsApp: Status Code ${responseNotifikasiWA.statusCode}');
//     }
//   } catch (e) {
//     print('Error: Gagal terhubung ke server WhatsApp $e');
//   }
// }



  Future<void> simpanRekap(int idIuran1, int idIuran2, int idIuran3, int idIuran4, int idIuran5, int idIuran6) async {
    final urlRekap = '${ApiUrls.baseUrl}/tambahRekap.php';
    final bodyRekap = {
      'id_iuran1': idIuran1.toString(),
      'id_iuran2': idIuran2.toString(),
      'id_iuran3': idIuran3.toString(),
      'id_iuran4': idIuran4.toString(),
      'id_iuran5': idIuran5.toString(),
      'id_iuran6': idIuran6.toString(),
      
    };

    try {
      final responseRekap = await http.post(
        Uri.parse(urlRekap),
        body: bodyRekap,
      );

      if (responseRekap.statusCode == 200) {
        final jsonResponseRekap = jsonDecode(responseRekap.body);
        if (jsonResponseRekap['result'] == 'success') {
         
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
          msg: "Nama iuran tidak boleh kosong",
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
                //kirimNotifikasiWA();
              },
            ),
          ],
        );
      },
    );
  }
  void _ketentuanDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Kategori IPL Kavling "),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Kategori 1 (Kavling tidak dihuni): Rp 120.000\n'
                  '2. Kategori 2 (Blok N/O/P): Rp 145.000\n'
                  '3. Kategori 3 (Blok C/D/E/F/G/H/I/J/K/L dan M(1 lantai)): Rp 170.000\n'
                  '4. Kategoti 4 (Blok B/H/G dan M(2 lantai)): Rp 195.000\n'
                  '5. Kategori 5 (Blok A(ruko) Usaha skala UMKM dan kantor): Rp 220.000\n'
                  '6. Kategori 6 (Blok A(ruko) Usaha skala perseroan): Rp 250.000\n',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Ya"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  @override
  void dispose() {
    
    _nominalIuranController.dispose();
    _batasTransaksiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFFDECE8),
        elevation: 0,
      ),
      drawer: MyDrawer(currentPage: 'TambahIuranPage',),
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
            padding: EdgeInsets.all(isMobile ? 16 : 80),
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
                                fontSize: isMobile ? 24 : 40, 
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
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => TambahIuranPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              'Iuran Khusus',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: isMobile ? 14 : 18, 
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              'Iuran Pengelolaan Lingkungan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 14 : 18, 
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Kategori IPL Kavling"),
                        SizedBox(width: 3),
                        InkWell(
                          onTap: _ketentuanDialog,
                          child: Text(
                            'Klik Disini',
                            style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1000,
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
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      hintText: 'Ketik nama iuran...',
                                      enabled: true,
                                    ),
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
                      width: 1000,
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
                              decoration: InputDecoration.collapsed(
                                  hintText: 'Pilih Tanggal Batas Transaksi'),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            onPressed: () => _selectDate(context),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
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
                              fontSize: 20,
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
