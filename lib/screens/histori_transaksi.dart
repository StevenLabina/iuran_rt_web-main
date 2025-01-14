import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:iuran_rt_web/url.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:universal_html/html.dart' as html;
import 'package:iuran_rt_web/drawer.dart';

class HistoriTransaksiPage extends StatefulWidget {
  @override
  _HistoriTransaksiPageState createState() => _HistoriTransaksiPageState();
}

class _HistoriTransaksiPageState extends State<HistoriTransaksiPage> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> dataIuran = [];
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
    Uri.parse('${ApiUrls.baseUrl}/histori_all.php'),
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
        dataIuran = result['data'];
      });
    } else {
      setState(() {
        dataIuran = [];
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
      dataIuran = [];
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
      'No Kavling',
      'Nama Pemilik',
      'Penanggung Jawab',
      'Nama Iuran',
      'Nominal Iuran',
      'Tanggal Jatuh Tempo',
      'Tanggal Lunas',
      'Status',
      'Metode'
      
    ];
    sheetObject.appendRow(headers);

    // Menambahkan data
    for (var item in dataIuran) {
      List<String> row = [
        item['r_no_kavling'] ?? '-',
        item['r_nama_pemilik'] ?? '-',
        item['r_nama_penanggung_jawab'] ?? '-',
        item['r_nama_iuran'] ?? '-',
        item['r_nominal_iuran'] ?? '-',
        item['r_batas_pembayaran'] ?? '-',
        item['r_tanggal_lunas'] ?? '-',
        item['r_status'] ?? '-',
        item['r_metode'] ?? '-',

      ];
      sheetObject.appendRow(row);
    }

    
    if (kIsWeb) {
      // Convert Excel ke Uint8List dan trigger download file
      final bytes = excel.encode();
      final blob = html.Blob([bytes],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "Histori Transaksi.xlsx")
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = "${directory.path}/HistoyTransaksi.xlsx";
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
        elevation: 0,
      ),
      drawer: MyDrawer(),
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
                  'Histori Pelunasan Transaksi Iuran Warga',
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
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Cari Berdasarkan No Kavling',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                fetchIuranData(value);
              },
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
                                  DataColumn(label: Text('No Kavling')),
                                
                                  DataColumn(label: Text('Nama Pemilik')),
                                  DataColumn(label: Text('Nama Penanggung Jawab')),
                                  DataColumn(label: Text('Nama Iuran')),
                                  DataColumn(label: Text('Nominal Iuran')),
                                  DataColumn(label: Text('Tanggal Jatuh Tempo')),
                                  DataColumn(label: Text('Tanggal Lunas')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Metode')),
                                ],
                                rows: dataIuran.map((item) {
                                  return DataRow(cells: [
                                    DataCell(Text(item['r_no_kavling'] ?? '-')),
                                    DataCell(Text(
                                        item['r_nama_pemilik'] ?? '-')),
                                    DataCell(Text(
                                        item['r_nama_penanggung_jawab'] ?? '-')),
                                    DataCell(Text(item['r_nama_iuran'] ?? '-')),
                                    DataCell(
                                        Text(item['r_nominal_iuran'] ?? '-')),
                                    DataCell(
                                        Text(item['r_batas_pembayaran'] ?? '-')),
                                    DataCell(
                                        Text(item['r_tanggal_lunas'] ?? '-')),
                                    DataCell(
                                        Text(item['r_status'] ?? '-')),
                                    DataCell(
                                        Text(item['r_metode'] ?? '-')),
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
