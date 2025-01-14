import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iuran_rt_web/drawer.dart';

class PetunjukPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDECE8),
      appBar: AppBar(
        backgroundColor: Color(0xFFFDECE8),
        elevation: 0,
      ),
      drawer: MyDrawer(),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Container(
            width: 567,
            height: 102,
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/images/SealQuestion.svg'),
                const SizedBox(width: 20),
                Text(
                  'Petunjuk',
                  textAlign: TextAlign.left,
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
          ),
          _buildStepCard(
            'Buat Iuran',
            'Digunakan untuk membuat iuran baru. Anda dapat mengatur kategori iuran, nominal, dan periode pembayaran yang dibutuhkan.',
            SvgPicture.asset('assets/images/HandCoins.svg',
            color: Colors.red,
            width: 40,
            height: 40,),
          ),
          _buildStepCard(
            'Buat Data Warga',
            'Digunakan untuk mendaftarkan data warga baru. Pastikan mengisi informasi warga dengan lengkap dan akurat.',
             SvgPicture.asset('assets/images/UserPlus.svg',
            color: Colors.red,
            width: 40,
            height: 40,),
          ),
          _buildStepCard(
            'Rekap Iuran Warga',
            'Digunakan untuk melihat dan memantau rekap pembayaran iuran warga secara online, termasuk riwayat dan status pembayaran.',
             SvgPicture.asset('assets/images/ChartDonut.svg',
            color: Colors.red,
            width: 40,
            height: 40,),
          ),
          _buildStepCard(
            'Data Warga',
            'Digunakan untuk melihat dan mengelola seluruh data warga yang telah terdaftar dalam sistem.',
           SvgPicture.asset('assets/images/UsersFour.svg',
            color: Colors.red,
            width: 40,
            height: 40,),
          ),
          _buildStepCard(
            'Histori Transaksi',
            'Digunakan untuk melihat riwayat bayar iuran berdasarkan tanggal bayar dan penanggung jawab\n',
            SvgPicture.asset( 'assets/images/Receipt.svg',
            color: Colors.red,
            width: 40,
            height: 40,),
          ),
          _buildStepCard(
            'Butuh Bantuan?',
            'Jika merasa kesulitan dalam pengoperasian aplikasi iuran RT online ini bisa menghubungi:\n'
            'Whatsapp: 085934282367\n'
            'Email: stevenlabina25@gmail.com',
            SvgPicture.asset('assets/images/Lifebuoy.svg',
            color: Colors.red,
            width: 40,
            height: 40,),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(String title, String description, Widget icon) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            icon,
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    description,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
