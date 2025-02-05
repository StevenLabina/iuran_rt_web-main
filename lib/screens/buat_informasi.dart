import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:iuran_rt_web/url.dart';
import 'package:iuran_rt_web/main.dart';
import 'package:iuran_rt_web/drawer.dart';


//import 'package:firebase_messaging/firebase_messaging.dart';
class TambahInformasiPage extends StatefulWidget {
  @override
  _TambahInformasiPageState createState() => _TambahInformasiPageState();
}

class _TambahInformasiPageState extends State<TambahInformasiPage> {
  final TextEditingController _InformasiController = TextEditingController();
  final TextEditingController _1tanggalController = TextEditingController();
  final TextEditingController _2tanggalController = TextEditingController();
  DateTime? _selectedDate;


  @override
  void initState() {
    super.initState();
  }

  Future<void> simpanIuran() async {
    if (_InformasiController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Informasi Tidak Boleh Kosong",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    if (_1tanggalController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Tanggal Tidak Boleh Kosong",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if (_2tanggalController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Tanggal Tidak Boleh Kosong",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    Fluttertoast.showToast(
        msg:
            "Informasi: ${_InformasiController.text}\nTanggal: ${_1tanggalController.text} sampai ${_2tanggalController.text} ",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.black38,
        textColor: Colors.white,
        fontSize: 16.0);
  }
//   Future<void> kirimNotifikasiWA() async {
//   final urlNotifikasiWA = '${ApiUrls.baseUrl}/whatsapp_api.php';
//   try {
//     final responseNotifikasiWA = await http.post(
//       Uri.parse(urlNotifikasiWA),
//       body: {
//         'msg': 'Haloo, ada pengumuman bahwa adanya kegiatan ${_InformasiController.text} dari ${_1tanggalController.text} sampai ${_2tanggalController.text}  ',
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
  // Future<void> kirimNotifikasiWA() async {
  //   final urlNotifikasiWA = '${ApiUrls.baseUrl}/send_whatsapp_iuran.php';
  //   try {
  //     final responseNotifikasiWA = await http.post(
  //       Uri.parse(urlNotifikasiWA),
  //       body: {
  //         'msg':
  //             'PENGUMUMAN IURAN RT ONLINE\nIuran Baru: ${_namaIuranController.text}.\nNominal: ${_nominalIuranController.text}\nAyo buruan bayar pakai iuran rt online',
  //       },
  //     );

  //     if (responseNotifikasiWA.statusCode == 200) {
  //       final jsonResponseNotifikasiWA = jsonDecode(responseNotifikasiWA.body);
  //       if (jsonResponseNotifikasiWA['status'] == true) {
  //         print('Notifikasi WhatsApp berhasil dikirim: ');
  //       } else {
  //         print(
  //             'Gagal mengirim notifikasi WhatsApp: ${jsonResponseNotifikasiWA['reason']}');
  //       }
  //     } else {
  //       print(
  //           'Gagal mengirim notifikasi WhatsApp: ${responseNotifikasiWA.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error: Gagal terhubung ke server WhatsApp $e');
  //   }
  // }
  // Future<void> kirimNotifikasiWA() async {
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
  //       print(
  //           'Gagal mengirim notifikasi WhatsApp: ${responseNotifikasiWA.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error: Gagal terhubung ke server WhatsApp $e');
  //   }
  // }
  Future<void> _selectDate1(BuildContext context) async {
    // Pilih Tanggal
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // Pilih Waktu
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 11, minute: 59),
      );

      if (pickedTime != null) {
        setState(() {
          // Gabungkan tanggal dan waktu
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour, // Jam
            pickedTime.minute,
          );

          // Formatkan tanggal dan waktu

          _1tanggalController.text =
              DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate!);
        });
      }
    }
  }

  Future<void> _selectDate2(BuildContext context) async {
    // Pilih Tanggal
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // Pilih Waktu
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 11, minute: 59), // Waktu default
      );

      if (pickedTime != null) {
        setState(() {
          // Gabungkan tanggal dan waktu
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour, // Jam
            pickedTime.minute, // Menit
          );

          // Formatkan tanggal dan waktu
          _2tanggalController.text =
              DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate!);
        });
      }
    }
  }

  void _showConfirmationDialog() {
    if (_InformasiController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Informasi tidak boleh kosong",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    if (_1tanggalController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Tanggal tidak boleh kosong",
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

  @override
  void dispose() {
    _InformasiController.dispose();
    _1tanggalController.dispose();
    _2tanggalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFFDECE8),
        elevation: 0,
      ),
      drawer: MyDrawer(currentPage: 'TambahInformasiPage'), // Parameter halaman aktif
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
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 700,
                      height: 102,
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info,
                            color: Colors.black,
                            size: 40,
                          ),
                          const SizedBox(width: 8), // Mengurangi jarak dari 20 menjadi 8
                          Flexible(
                            child: Text(
                              'Informasi Dari Pengurus RT Kepada Warga',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF181C14),
                                fontSize: 24,
                                fontFamily: 'Figtree',
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildInputField(
                      context,
                      _InformasiController,
                      'Ketik informasi yang akan disampaikan...',
                      Icons.info_outline,
                    ),
                    SizedBox(height: 16),
                    
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 800) {
                          
                          return _buildDateRangeField(context);
                        } else {
                          
                          return Column(
                            children: [
                              _buildSingleDateField(context, _1tanggalController, _selectDate1, 'Berlaku dari'),
                              SizedBox(height: 16),
                              _buildSingleDateField(context, _2tanggalController, _selectDate2, 'Sampai dengan'),
                            ],
                          );
                        }
                      },
                    ),
                    SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(BuildContext context, TextEditingController controller, String hintText, IconData icon) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
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
          Icon(icon, color: Color(0xFF909090)),
          SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: hintText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeField(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
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
                SizedBox(width: 12),
                // Menambahkan ikon kalender di sini
                Icon(Icons.calendar_today, color: Color(0xFF909090)),
                SizedBox(width: 12),
                Text('Berlaku dari'),
                SizedBox(width: 16),
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate1(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _1tanggalController,
                        textAlign: TextAlign.center,
                        readOnly: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: 'Tanggal',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          // Menambahkan ikon kalender di sini
          Icon(Icons.calendar_today, color: Color(0xFF909090)),
          SizedBox(width: 16),
          Text('sampai dengan'),
          SizedBox(width: 16),
          Expanded(
            child: TextButton(
              onPressed: () => _selectDate2(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _2tanggalController,
                  textAlign: TextAlign.center,
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Tanggal',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleDateField(BuildContext context, TextEditingController controller, Function onTap, String label) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
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
          SizedBox(width: 12),
          // Menambahkan ikon kalender di sini
          Icon(Icons.calendar_today, color: Color(0xFF909090)),
          SizedBox(width: 12),
          Text(label),
          SizedBox(width: 16),
          Expanded(
            child: TextButton(
              onPressed: () => onTap(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Tanggal',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
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
    );
  }
}
