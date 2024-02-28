import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class GeneratePDF {
  static Future<void> generateAndSavePdf(
      String title, List<String> columnValues, List<List<String>> tableRows, String pdfName, BuildContext context) async {
    try {
      final pdf = pw.Document();

      final columns = columnValues.map((column) {
        return pw.Container(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          child: pw.Text(
            column,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );
      }).toList();

      final rowWidgets = tableRows.map((rowItems) {
        return pw.TableRow(
          children: rowItems.map((cell) {
            return pw.Container(
              child: pw.Text(
                cell,
              ),
            );
          }).toList(),
        );
      }).toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(16.0),
          header: (pw.Context context) {
            return pw.Container();
          },
          footer: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('@FarmGateTechnologySolutions\n'
                        'Contact No: +91 97890 36947',
                      style: const pw.TextStyle(
                        fontSize: 10.0,
                      ),
                    ),
                    // pw.SizedBox(width: 20),
                    // pw.Text('Contact No: +91 97890 36947',
                    //   style: const pw.TextStyle(
                    //     fontSize: 10.0,
                    //   ),
                    // ),
                  ],
                ),
              ],
            );
          },
          build: (pw.Context context) {
            return <pw.Widget>[
              pw.Text(title,
                  style: pw.TextStyle(
                      fontSize: 20.0, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table(
                columnWidths: {
                  for (int i = 0; i < columns.length; i++)
                    i: const pw.FixedColumnWidth(100),
                },
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: columns,
                  ),
                  ...rowWidgets,
                ],
              ),
            ];
          },
        ),
      );

      String formattedDate = DateFormat('yyyy_MM_dd_hh_mm').format(DateTime.now());

      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/${pdfName}_$formattedDate.pdf';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      AppTheme.showPdfOptions(context, filePath,"Animal Details");

    }
    catch(e){
      // ignore: use_build_context_synchronously
      AppTheme.showSnackBar(context, "Error Generating PDF$e");
    }
    // You can display options or handle the file as needed
  }
}

