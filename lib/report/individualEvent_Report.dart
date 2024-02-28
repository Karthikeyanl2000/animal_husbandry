import 'package:animal_husbandry/app/bovine.dart';
import 'package:animal_husbandry/objectbox/animal_box.dart';
import 'package:animal_husbandry/objectbox/event_box.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:animal_husbandry/widget/filter_event.dart';
import 'package:animal_husbandry/widget/pdfGenerator.dart';
import 'package:animal_husbandry/widget/search_container.dart';
import 'package:flutter/material.dart';
import 'package:hyper_object_box/model/ai.dart';

class IndividualReports extends StatefulWidget {
  const IndividualReports({
    Key? key,
  }) : super(key: key);
  @override
  State<IndividualReports> createState() => _IndividualReportState();
}

class _IndividualReportState extends State<IndividualReports> {
  final EventBox aiBox = EventBox();
  final eventBox = objectBox.store.box<AI>();

  final AnimalBox animalBox = AnimalBox();
  TextEditingController animalTagNoInput = TextEditingController();
  List<AI> listEventType = [];
  TextEditingController listDate = TextEditingController();
  bool showSuggestions = false;
   late List<String> columns = [];
 late List<List<String>> tableRows = [];

  @override
  Widget build(BuildContext context) {
    List<String> animalList = animalBox
        .getFilterTagNumbersFromObjectBox()
        .whereType<String>()
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Individual Reports"),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
              onPressed: () async {
               generateIndividualReportPDF(context);
              },
              icon: const Icon(Icons.picture_as_pdf))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SearchContainer(
              controller: animalTagNoInput,
              suggestionList: animalList,
              onSuggestionSelected: (suggestion) {
                setState(() {
                  animalTagNoInput.text = suggestion;
                  String actualTagNo =
                      animalTagNoInput.text.split('[').first.trim();

                  listEventType = FilterEvents.getEventList(
                      aiBox.list(), actualTagNo.toString());

                  listDate.text = listEventType.isNotEmpty
                      ? listEventType.reversed.toList().first.dateOfEvent!
                      : '';
                });
              },
              decoration: AppTheme.textFieldInputDecoration(
                "Select Animal",
              ),
              showSuggestions: showSuggestions,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (listEventType.isNotEmpty)
                  Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    elevation: 7,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "Events History",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            var ai = listEventType.reversed.toList()[index];

                            // ListTile
                            List<Widget> eventWidgets = [];

                            if (ai.eventType == "Inseminated/Mated") {
                              eventWidgets.add(
                                Text(
                                  'Heat Date: ${ai.estimatedHeatDate ?? ''}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black45,
                                  ),
                                ),
                              );
                            } else if (ai.eventType == "Pregnant") {
                              eventWidgets.add(
                                Text(
                                  'Delivery Date: ${ai.deliveryDate ?? ''}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black45,
                                  ),
                                ),
                              );
                            } else if (ai.eventType == "Vaccinated" ||
                                ai.eventType == "Inseminated/Mated") {
                              eventWidgets.add(
                                Text(
                                  'Technician Name: ${ai.technicianName ?? ''}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black45,
                                  ),
                                ),
                              );
                            } else if (ai.eventType == "Treated/Medicated") {
                              eventWidgets.add(
                                Text(
                                  'Symptoms: ${ai.symptomsOfSickness ?? ''}\n'
                                  'Diagnosis:${ai.diagnosis ?? ''}\n'
                                      'Technician Name: ${ai.technicianName ?? ''}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black45,
                                  ),
                                ),
                              );
                            }



                            return ListTile(
                              title: Text(
                                "Event Type: ${ai.eventType ?? ''}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Name: ${ai.name ?? ''}\n'
                                    'Tag No: ${ai.tagNo ?? ''}\n'
                                    'Event Date: ${ai.dateOfEvent ?? ''}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  ...eventWidgets,
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const Divider(
                              color: Colors.grey,
                              thickness: 2,
                              indent: 2,
                              endIndent: 2,
                            );
                          },
                          itemCount: listEventType.length,
                        )
                      ],
                    ),
                  )
                else
                  AppTheme.staticCard("Event History", "No Event History Found")
              ],
            ),
          ],
        ),
      ),
    );
  }


  Future<void> generateIndividualReportPDF(BuildContext context) async {
    if (listEventType.isNotEmpty) {
      columns = ['Event Type', 'Event Date'];
      tableRows = [];
      String title = "";

      for (var ai in listEventType.reversed.toList()) {
        List<String> eventRow = [
          ai.eventType ?? '',
          ai.dateOfEvent ?? '',
        ];

        if (ai.eventType == "Inseminated/Mated") {
          eventRow.add('Heat Date: ${ai.estimatedHeatDate ?? ''}');
          eventRow.add('Semen: ${ai.semen ?? ''}');
        } else if (ai.eventType == "Pregnant") {
          eventRow.add('Delivery Date: ${ai.deliveryDate ?? ''}');
        } else if (ai.eventType == "Vaccinated" ||
            ai.eventType == "Inseminated/Mated" || ai.eventType == "Treated/Medicated") {
          eventRow.add('Technician Name: ${ai.technicianName ?? ''}');
        } else if (ai.eventType == "Treated/Medicated") {
          eventRow.add('Symptoms: ${ai.symptomsOfSickness ?? ''}');
          eventRow.add('Diagnosis: ${ai.diagnosis ?? ''}');
        } else if (ai.eventType == "Vaccinated"){
          eventRow.add('Medicine Name: ${ai.medicineName ?? ''}');
        }

        tableRows.add(eventRow);
        title = "${ai.tagNo}_${ai.name}";
      }
      await GeneratePDF.generateAndSavePdf(title, columns, tableRows, title, context);
    } else {
      AppTheme.showSnackBar(context, 'PDF Not Generated');
    }
  }
}
