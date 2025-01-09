import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:iuran_rt_web/screens/bukti_transaksi.dart';
import 'package:iuran_rt_web/url.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class RekapIuranWargaPage extends StatefulWidget {
  @override
  _RekapIuranWargaPageState createState() => _RekapIuranWargaPageState();
}

class _RekapIuranWargaPageState extends State<RekapIuranWargaPage> {
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
      Uri.parse('${ApiUrls.baseUrl}/listWarga.php'),
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
      'Alamat Kavling',
      'Nama Pemilik',
      'Penanggung Jawab',
      'No. Telp Pemilik Rumah',
      'No. Telp Penanggung Jawab',
      'Nama Iuran',
      'Nominal Iuran',
      'Tanggal Jatuh Tempo'
    ];
    sheetObject.appendRow(headers);

    // Menambahkan data
    for (var item in dataIuran) {
      List<String> row = [
        item['no_kavling'] ?? '-',
        item['alamat_kavling'] ?? '-',
        item['nama_pemilik_rumah'] ?? '-',
        item['nama_penanggung_jawab'] ?? '-',
        item['no_telpon_pemilik'] ?? '-',
        item['no_telpon_penanggung_jawab'] ?? '-',
        item['nama_iuran'] ?? '-',
        item['nominal_iuran'] ?? '-',
        item['batas_pembayaran'] ?? '-',
      ];
      sheetObject.appendRow(row);
    }

    
    if (kIsWeb) {
      
      final bytes = excel.encode();
      final blob = html.Blob([bytes],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "DataIuranWarga.xlsx")
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = "${directory.path}/DataIuranWarga.xlsx";
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
        onPressed: () => Navigator.of(context).pop(),
      ),
      
    ),
    body: Center( 
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                SvgPicture.asset(
                  'assets/images/ChartDonut.svg',
                  color: Colors.black,
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 20),
                Text(
                  'Rekap Warga Yang Belum Bayar Iuran',
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
            SizedBox(height: 16),
            TextField(
              inputFormatters: [LengthLimitingTextInputFormatter(10)], 
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
                              child: Card(
                                elevation: 4,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: DataTable(
                                    columnSpacing: isWideScreen ? 10 : 20,
                                    columns: [
                                      DataColumn(label: Text('No Kavling')),
                                      DataColumn(label: Text('Alamat Kavling')),
                                      DataColumn(label: Text( 'Pemilik Rumah')),
                                      DataColumn(label: Text('Penanggung Jawab')),
                                      DataColumn(
                                          label: Text('No. Telepon Pemilik Rumah')),
                                      DataColumn(
                                          label: Text('No. Telepon Penanggung Jawab')),
                                      DataColumn(label: Text('Nama Iuran')),
                                      DataColumn(label: Text('Nominal Iuran')),
                                      DataColumn(label: Text('Tanggal Jatuh Tempo')),
                                    ],
                                    rows: dataIuran.map((item) {
                                      return DataRow(cells: [
                                        DataCell(Align(
                                          alignment: Alignment.center,
                                          child: Text(item['no_kavling'] ?? '-'),
                                        )),
                                        DataCell(Align(
                                          alignment: Alignment.center,
                                          child: Text(item['alamat_kavling'] ?? '-'),
                                        )),
                                        DataCell(Align(
                                          alignment: Alignment.center,
                                          child: Text(item['nama_pemilik_rumah'] ?? '-'),
                                        )),
                                        DataCell(Align(
                                          alignment: Alignment.center,
                                          child: Text(item['nama_penanggung_jawab'] ?? '-'),
                                        )),
                                        DataCell(Align(
                                          alignment: Alignment.center,
                                          child: Text(item['no_telpon_pemilik'] ?? '-'),
                                        )),
                                        DataCell(Align(
                                          alignment: Alignment.center,
                                          child: Text(item['no_telpon_penanggung_jawab'] ?? '-'),
                                        )),
                                        DataCell(Align(
                                          alignment: Alignment.center,
                                          child: Text(item['nama_iuran'] ?? '-'),
                                        )),
                                        DataCell(Align(
                                          alignment: Alignment.center,
                                          child: Text(item['nominal_iuran'] ?? '-'),
                                        )),
                                        DataCell(Align(
                                          alignment: Alignment.center,
                                          child: Text(item['batas_pembayaran'] ?? '-'),
                                        )),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
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
