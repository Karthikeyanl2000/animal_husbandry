import 'package:animal_husbandry/widget/filter_event.dart';
import 'package:animal_husbandry/widget/pdfGenerator.dart';
import 'package:flutter/material.dart';
import 'package:animal_husbandry/objectbox/animal_box.dart';
import 'package:animal_husbandry/objectbox/event_box.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:animal_husbandry/widget/search_container.dart';
import 'package:hyper_object_box/model/ai.dart';

class BaseReport extends StatefulWidget {
  final String pageTitle;
  final String eventType;
  final String historyTitle;
  final String historyNotFoundMessage;
  final String Function(AI ai) getTitle;
  final String Function(AI ai) listTileDetails;

  const BaseReport({
    super.key,
    required this.pageTitle,
    required this.eventType,
    required this.historyTitle,
    required this.historyNotFoundMessage,
    required this.getTitle,
    required this.listTileDetails,
  });

  @override
  State<BaseReport> createState() => BaseReportState();
}

class BaseReportState extends State<BaseReport> {
  final EventBox aiBox = EventBox();
  final AnimalBox animalBox = AnimalBox();
  List<AI> listEventTypeDate = [];
  TextEditingController animalTagNoInput = TextEditingController();
  TextEditingController listDate = TextEditingController();
  bool showSuggestions = false;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> animalList = animalBox
        .getFilterTagNumbersFromObjectBox()
        .whereType<String>()
        .toList();
    List<String> femaleAnimalList =
        animalBox.getFemaleTagNoNumbers().whereType<String>().toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(widget.pageTitle),
        leading: AppTheme.buildBackIconButton(context, "/reportHomeScreen"),
        actions: [
          IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () async {
                if (listEventTypeDate.isNotEmpty) {
                  String pdfName = listEventTypeDate.map((e) => "${e.tagNo}_${e.name}").toList().join(', ');
                  List<String> columns = [];
                  List<List<String>> tableRows = [];

                  if (widget.eventType == "Inseminated/Mated") {
                    columns = [
                      "Animal Name",
                      "Event Type",
                      "Event Date",
                      "Next Heat Date",
                      "Technician Name",
                    ];

                    tableRows = listEventTypeDate.map((ai) {
                      return [
                        ai.name ?? '',
                        ai.eventType ?? '',
                        ai.dateOfEvent ?? '',
                        ai.estimatedHeatDate ?? '',
                        ai.technicianName ?? '',
                      ];
                    }).toList();
                  } else if (widget.eventType == "Vaccinated") {
                    columns = [
                      "Animal Name",
                      "Event Type",
                      "Event Date",
                      "Technician Name",
                      "Medicine Name",
                    ];
                    tableRows = listEventTypeDate.map((ai) {
                      return [
                        ai.name ?? '',
                        ai.eventType ?? '',
                        ai.dateOfEvent ?? '',
                        ai.technicianName ?? '',
                        ai.medicineName ?? '',

                      ];
                    }).toList();
                  }else if(widget.eventType == "Treated/Medicated"){
                    columns=[
                      "Animal Name",
                      "Event Type",
                      "Event Date",
                      "Symptoms",
                      "Diagnosis",
                      "Technician Name",
                    ];
                    tableRows = listEventTypeDate.map((ai){
                      return[
                        ai.name ??'',
                        ai.eventType ?? '',
                        ai.dateOfEvent ?? '',
                        ai.symptomsOfSickness ?? '',
                        ai.diagnosis ?? '',
                        ai.technicianName ?? '',
                      ];
                    }).toList();
                  }

                  // Call the function to generate and save the PDF here
                  await GeneratePDF.generateAndSavePdf(
                    "Animal Husbandry",
                    columns,
                    tableRows,
                    pdfName,
                    context,
                  );
                }
                else{
                  AppTheme.showSnackBar(context, "Error Generating PDF");
                }
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SearchContainer(
              controller: animalTagNoInput,
              suggestionList: widget.eventType == "Inseminated/Mated"
                  ? femaleAnimalList
                  : animalList,
              onSuggestionSelected: (suggestion) {
                setState(() {
                  animalTagNoInput.text = suggestion;
                  showSuggestions = false;
                  if (animalTagNoInput.text.isNotEmpty) {
                    String actualTagNo =
                        animalTagNoInput.text.split('[').first.trim();

                    listEventTypeDate = FilterEvents.getFilteredList(
                        aiBox.list(), widget.eventType, actualTagNo.toString());
                    listDate.text = listEventTypeDate.isNotEmpty
                        ? listEventTypeDate.reversed.toList().first.dateOfEvent!
                        : '';
                  }
                });
              },
              decoration: AppTheme.textFieldInputDecoration('Select Animal'),
              // onPressedCallback: toggleSuggestions,
              showSuggestions: showSuggestions,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (listEventTypeDate.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
                          child: Center(
                            child: Text(
                              widget.historyTitle,
                              style: const TextStyle(
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
                            var ai = listEventTypeDate.reversed.toList()[index];
                            //ListTile
                            return ListTile(
                              title: Text(
                                widget.getTitle(ai),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.listTileDetails(ai),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black45,
                                    ),
                                  ),
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
                          itemCount: listEventTypeDate.length,
                        ),
                      ],
                    ),
                  )
                else
                  AppTheme.staticCard(widget.historyTitle,
                      "${animalTagNoInput.text} ${widget.historyNotFoundMessage}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
