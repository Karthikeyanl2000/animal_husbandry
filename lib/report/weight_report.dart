import 'package:animal_husbandry/objectbox/animal_box.dart';
import 'package:animal_husbandry/objectbox/production_Box.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:animal_husbandry/widget/filter_event.dart';
import 'package:animal_husbandry/widget/pdfGenerator.dart';
import 'package:flutter/material.dart';
import 'package:hyper_object_box/model/production.dart';

class WeightReport extends StatefulWidget {
  const WeightReport({Key? key}) : super(key: key);

  @override
  State<WeightReport> createState() => _WeightReportState();
}

class _WeightReportState extends State<WeightReport> {
  final AnimalBox animalBox = AnimalBox();
  final ProductionBox productionBox = ProductionBox();
  List<String> tagNos = [];
  List<Production> lastWeightResult = [];
  TextEditingController currentWeight = TextEditingController();
  TextEditingController previousWeight = TextEditingController();

  String pdfName = "Weight Report";
  final List<String> columnNames = [
    'Tag No',
    'Name',
    'Previous Weight',
    'Current Weight',
    'Gained Weight'
  ];

  late List<List<String>> tableRows = [];

  @override
  void initState() {
    super.initState();
    tagNos =
        animalBox.getTagNumbersFromObjectBox().whereType<String>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Weight Report"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                await GeneratePDF.generateAndSavePdf('Animal Husbandry',
                    columnNames, tableRows, pdfName, context);
              },
              icon: const Icon(Icons.picture_as_pdf))
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
              child:  Row(
                children: [
                  AppTheme.rowExpanded(
                      "Tag No", TextAlign.start, Colors.black, context),
                  AppTheme.rowExpanded(
                      "Name", TextAlign.start, Colors.black, context),
                  AppTheme.rowExpanded(
                      "Previous", TextAlign.start, Colors.black, context),
                  AppTheme.rowExpanded(
                      "Current", TextAlign.center, Colors.black, context),
                  AppTheme.rowExpanded("Gained", TextAlign.start, Colors.black, context),
                ],
              ),
            ),
            Expanded(
              // Wrap the ListView.builder with an Expanded widget
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: tagNos.length,
                itemBuilder: (context, index) {
                  String tagNo = tagNos[index];
                  String animalName =
                      animalBox.getPropertyForTagNo(tagNo, "name") ?? '';
                    lastWeightResult = FilterEvents.filterWeightProduction(productionBox, tagNo);
                  if (lastWeightResult.length >= 2) {
                    List<Production> lastTwoWeightRecords =
                        lastWeightResult.sublist(lastWeightResult.length - 2);
                    currentWeight.text = lastTwoWeightRecords.last.fattening!;
                    previousWeight.text = lastTwoWeightRecords.first.fattening!;
                  } else if (lastWeightResult.length == 1) {
                    currentWeight.text = lastWeightResult.last.fattening!;
                    previousWeight.text = '';
                  } else {
                    currentWeight.text = '';
                    previousWeight.text = double.tryParse(
                            animalBox.getPropertyForTagNo(tagNo, "weight") ??
                                '')
                        .toString();
                  }
                  double? gained = 0.0;
                  bool gainedValue = false;

                  if (previousWeight.text.isNotEmpty &&
                      currentWeight.text.isNotEmpty) {
                    double? lastWeight = double.tryParse(previousWeight.text);
                    double? presentWeight = double.tryParse(currentWeight.text);

                    if (lastWeight != null &&
                        presentWeight != null &&
                        presentWeight > lastWeight) {
                      gainedValue = true;
                      gained = double.parse((presentWeight - lastWeight).toStringAsFixed(3));
                    }
                  }

                  tableRows.add([
                    tagNo,
                    animalName.toString(),
                    previousWeight.text,
                    currentWeight.text,
                    gainedValue ? " ($gained kg)" : "Not gained",
                  ]);

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          AppTheme.rowExpanded(tagNo, TextAlign.start, Colors.green, context),
                          AppTheme.rowExpanded(animalName.toString(), TextAlign.start, Colors.blue, context),
                          AppTheme.rowExpanded( previousWeight.text, TextAlign.start, Colors.blueGrey, context),
                          AppTheme.rowExpanded( currentWeight.text, TextAlign.start, Colors.blueGrey, context),
                          AppTheme.rowExpanded(gainedValue ? " ($gained kg)" : "Not gained", TextAlign.start,gainedValue ? Colors.green : Colors.red , context),
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
