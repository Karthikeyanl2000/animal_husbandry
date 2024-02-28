import 'package:animal_husbandry/objectbox/animal_box.dart';
import 'package:animal_husbandry/objectbox/event_box.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:animal_husbandry/widget/pdfGenerator.dart';
import 'package:flutter/material.dart';

class AIReport extends StatefulWidget {
  const AIReport({Key? key}) : super(key: key);
  @override
  State<AIReport> createState() => _AIReportState();
}

class _AIReportState extends State<AIReport> {
  final EventBox aiBox = EventBox();
  final AnimalBox animalBox = AnimalBox();
  List<String> tagNos = [];

  String pdfName = "Pregnancy Report";
  final List<String> columnNames = [
    'Cow Tag No',
    'Cow Name',
    'Cattle status',
    'IsConfirmed'
  ];
  late List<List<String>> tableRows = [];

  @override
  void initState() {
    super.initState();
    tagNos = animalBox.getCowTagNoNumbers().whereType<String>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Pregnancy Report'),
        leading: AppTheme.buildBackIconButton(context, "/reportHomeScreen"),
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
            // Box around the heading (labels)
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
                      "Tag No", TextAlign.start, Colors.black, context),
                  AppTheme.rowExpanded(
                      "Name", TextAlign.start, Colors.black, context),
                  AppTheme.rowExpanded(
                      "Status", TextAlign.start, Colors.black, context),
                  AppTheme.rowExpanded(
                      "IsConfirmed", TextAlign.start, Colors.black, context),
                ],
              ),
            ),
            // List of boxes for each tagNo
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: tagNos.length,
                itemBuilder: (context, index) {
                  String tagNo = tagNos[index];
                  String animalName =
                      animalBox.getPropertyForTagNo(tagNo, "name") ?? '';
                  String statusValue =
                      animalBox.getPropertyForTagNo(tagNo, "cattleStatus") ??
                          '';
                  bool isConfirmedValue = (statusValue == "Pregnant" ||
                          statusValue == "Lactating&Pregnant"
                      ? true
                      : false);
                  tableRows.add ([
                    tagNo,
                    animalName,
                    statusValue,
                    isConfirmedValue ? "Yes" : "No",
                  ]);

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          AppTheme.rowExpanded(
                              tagNo!, TextAlign.justify, Colors.green, context),
                          AppTheme.rowExpanded(animalName.toString(),
                              TextAlign.justify, Colors.lightBlue, context),
                          AppTheme.rowExpanded(statusValue!, TextAlign.justify,
                              Colors.blueGrey, context),
                          AppTheme.rowExpanded(
                              isConfirmedValue ? "Yes" : "No",
                              TextAlign.center,
                              isConfirmedValue ? Colors.green : Colors.red,
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
