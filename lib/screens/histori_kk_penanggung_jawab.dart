import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:iuran_rt_web/main.dart';
import 'package:iuran_rt_web/screens/histori_kk_pemilik.dart';
import 'package:iuran_rt_web/url.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:universal_html/html.dart' as html;

class HistoriKkPenanggungJawabPage extends StatefulWidget {
  @override
  _HistoriKkPenanggungJawabPageState createState() => _HistoriKkPenanggungJawabPageState();
}

class _HistoriKkPenanggungJawabPageState extends State<HistoriKkPenanggungJawabPage> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> historiKk = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchIuranData();
  }

 Future<void> fetchIuranData([String query = ""]) async {
  setState(() {
    isLoading = true;
  });

  final response = await http.post(
    Uri.parse('${ApiUrls.baseUrl}/historiKkPenanggungJawab.php'),
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'searchQuery': query,  
    },
  );

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);
    if (result['result'] == 'success') {
      setState(() {
        historiKk = result['data'];
      });
    } else {
      setState(() {
        historiKk = [];
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
    setState(() {
      historiKk = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal mengambil data dari server')),
    );
  }

  setState(() {
    isLoading = false;
  });
}


  Future<void> exportToExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Data Iuran Warga'];

    // Menambahkan header
    List<String> headers = [
      'No KK',
      'Nama Lengkap',
      'NIK',
      'Jenis Kelamin',
      'Tempat Lahir',
      'Tanggal Lahir',
      'Agama',
      'Pendidikan',
      'Jenis Pekerjaan'
      
    ];
    sheetObject.appendRow(headers);

    // Menambahkan data
    for (var item in historiKk) {
      List<String> row = [
        item['no_kk'] ?? '-',
        item['nama_lengkap'] ?? '-',
        item['nik'] ?? '-',
        item['jenis_kelamin'] ?? '-',
        item['tempat_lahir'] ?? '-',
        item['tanggal_lahir'] ?? '-',
        item['agama'] ?? '-',
        item['pendidikan'] ?? '-',
        item['jenis_pekerjaan'] ?? '-',
      ];
      sheetObject.appendRow(row);
    }

    // Menyimpan file Excel untuk Web atau Mobile/Desktop
    if (kIsWeb) {
      // Convert Excel ke Uint8List dan trigger download file
      final bytes = excel.encode();
      final blob = html.Blob([bytes],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "Histori KK Pemilik Rumah.xlsx")
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = "${directory.path}/Histori KK Pemilik Rumah.xlsx";
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data berhasil diexport ke $filePath')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDECE8),
      appBar: AppBar(
        backgroundColor: Color(0xFFFDECE8),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
         onPressed: () {
              Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/Receipt.svg',
                  color: Colors.black,
                  width: 40,
                  height: 40,
                ),
                // Icon(Icons.bar_chart, size: 40, color: Color.fromARGB(255, 0, 0, 0)),
                const SizedBox(width: 20),
                Text(
                  'Kumpulan KK Warga',
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
                        Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // TextField di sebelah kiri
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Pencarian Berdasarkan No Kartu Keluarga...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      fetchIuranData(value);
                    },
                  ),
                ),
                SizedBox(width: 8), // Spasi antara TextField dan Container

                // Container di sebelah kanan
                Container(
                  width: 567,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Tombol pertama
                      ElevatedButton(
                        onPressed: () {
                           Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HistoriKkPemilikPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          'KK Pemilik Rumah',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(width: 16), // Spasi antar tombol
                      // Tombol kedua
                      ElevatedButton(
                        onPressed: () {
                       
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          'KK Penanggung Jawab',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        bool isWideScreen = constraints.maxWidth > 800;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: MediaQuery.of(context).size.width,
                              ),
                              child: DataTable(
                                columnSpacing: isWideScreen ? 10 : 20,
                                columns: [
                                  DataColumn(label: Text('No KK')),
                                  DataColumn(label: Text('Nama Lengkap')),
                                  DataColumn(label: Text('NIK')),
                                  DataColumn(label: Text('Jenis Kelamin')),
                                  DataColumn(label: Text('Tempat Lahir')),
                                  DataColumn(label: Text('Tanggal Lahir')),
                                  DataColumn(label: Text('Agama')),
                                  DataColumn(label: Text('Pendidikan')),
                                  DataColumn(label: Text('Jenis Pekerjaan')),
                                ],
                                rows: historiKk.map((item) {
                                  return DataRow(cells: [
                                    DataCell(Text(item['no_kk'] ?? '-')),
                                    DataCell(
                                        Text(item['nama_lengkap'] ?? '-')),
                                    DataCell(Text(
                                        item['nik'] ?? '-')),
                                    DataCell(Text(
                                        item['jenis_kelamin'] ?? '-')),
                                    DataCell(Text(item['tempat_lahir'] ?? '-')),
                                    DataCell(
                                        Text(item['tanggal_lahir'] ?? '-')),
                                     DataCell(
                                        Text(item['agama'] ?? '-')),
                                     DataCell(
                                        Text(item['pendidikan'] ?? '-')),
                                     DataCell(
                                        Text(item['jenis_pekerjaan'] ?? '-')),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: exportToExcel,
        child: SvgPicture.asset(
          'assets/images/MicrosoftExcelLogo.svg',
          color: Colors.white,
          width: 30,
          height: 30,
        ),
        tooltip: 'Export to Excel',
      ),
     
    );
  }
}
