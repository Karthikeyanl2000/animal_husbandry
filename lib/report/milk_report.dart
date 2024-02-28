import 'package:animal_husbandry/objectbox/production_Box.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:animal_husbandry/widget/pdfGenerator.dart';
import 'package:flutter/material.dart';
import 'package:hyper_object_box/model/production.dart';
import 'package:intl/intl.dart';

class MilkReport extends StatefulWidget {
  const MilkReport({Key? key}) : super(key: key);

  @override
  State<MilkReport> createState() => _MilkReportState();
}

class _MilkReportState extends State<MilkReport> {
  final ProductionBox productionBox = ProductionBox();
  List<Production> listProduction = [];

  String pdfName = "Milk Report";
  final List<String> columnNames = [
    'Milking Date',
    'Total Milk',
    'No of Animals',
    'Average'
  ];

  late List<List<String>> tableRows = [];

  @override
  Widget build(BuildContext context) {
    listProduction = (productionBox
        .list()
        .where((element) => element.productionType == "Milk")
        .toList()
      ..sort((a, b) {
        DateFormat formatter = DateFormat("yyyy-MM-dd");
        DateTime aTime = formatter.parse(a.dateOfEntry!);
        DateTime bTime = formatter.parse(b.dateOfEntry!);
        return bTime.compareTo(aTime);
      }));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Milk Report"),
        leading: AppTheme.buildBackIconButton(context, "/reportHomeScreen"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () async{
            await GeneratePDF.generateAndSavePdf('Animal Husbandry', columnNames, tableRows, pdfName, context);
          }, icon: const Icon(Icons.picture_as_pdf)),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  AppTheme.rowExpanded(
                      "Milking Date", TextAlign.start, Colors.black, context),
                  AppTheme.rowExpanded(
                      "Total Milk", TextAlign.start, Colors.black, context),
                  AppTheme.rowExpanded(
                      "No of Animals", TextAlign.start, Colors.black, context),
                  AppTheme.rowExpanded(
                      "Average", TextAlign.center, Colors.black, context),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: listProduction.length,
                itemBuilder: (context, index) {
                  final production = listProduction[index];
                  bool totalCow =
                      (production.milkType == "Bulk Milk" ? true : false);

                  bool averageMilk =
                      (production.milkType == "Individual Milk" ? true : false);
                  tableRows.add([
                    production.dateOfEntry.toString(),
                    production.totalMilk.toString(),
                    totalCow
                        ? production.cowsCount.toString()
                        : "[${production.cowTagNo.toString()}]",
                    averageMilk
                        ? production.totalMilk.toString()
                        : production.averageMilk.toString()
                  ]);
                  // Format the DateTime object
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          AppTheme.rowExpanded(
                              production.dateOfEntry.toString(),
                              TextAlign.start,
                              Colors.green,
                              context),
                          AppTheme.rowExpanded(production.totalMilk.toString(),
                              TextAlign.start, Colors.lightBlue, context),
                          AppTheme.rowExpanded(
                              totalCow
                                  ? production.cowsCount.toString()
                                  : "[${production.cowTagNo.toString()}]",
                              TextAlign.center,
                              Colors.blueGrey,
                              context),
                          AppTheme.rowExpanded(
                              averageMilk
                                  ? production.totalMilk.toString()
                                  : production.averageMilk.toString(),
                              TextAlign.center,
                              Colors.blueGrey,
                              context),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
