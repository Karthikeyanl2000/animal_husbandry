import 'package:animal_husbandry/import_export_data/import_export.dart';
import 'package:animal_husbandry/objectbox/dateCycle_Box.dart';
import 'package:animal_husbandry/objectbox/event_box.dart';
import 'package:animal_husbandry/objectbox/animal_box.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:animal_husbandry/widget/dateTimePicker.dart';
import 'package:animal_husbandry/widget/dropdown_ListItems.dart';
import 'package:animal_husbandry/widget/search_container.dart';
import 'package:flutter/material.dart';
import 'package:hyper_object_box/model/ai.dart';
import 'package:hyper_object_box/model/cycle.dart';
import 'package:intl/intl.dart';

class EditEventDetails extends StatefulWidget {
  final AI event;

  // final Animal animal;
  const EditEventDetails({Key? key, required this.event}) : super(key: key);

  @override
  State<EditEventDetails> createState() => _EditEventDetailsState();
}

class _EditEventDetailsState extends State<EditEventDetails> {

  late bool isIndividualEvents;
  final AnimalBox animalBox = AnimalBox();
  final EventBox eventBox = EventBox();
  String? typeOfEvent;
  TextEditingController selectEvent = TextEditingController();
  TextEditingController tagInput = TextEditingController();
  TextEditingController dateInput = TextEditingController();
  TextEditingController eventTypeInput = TextEditingController();
  TextEditingController noteInput = TextEditingController();
  TextEditingController medicineNameInput = TextEditingController();
  TextEditingController otherEventNameInput = TextEditingController();
  TextEditingController symptomsInput = TextEditingController();
  TextEditingController diagnosisInput = TextEditingController();
  TextEditingController technicianNameInput = TextEditingController();
  TextEditingController estimatedReturnHeatDateInput = TextEditingController();
  TextEditingController semenInput = TextEditingController();
  TextEditingController selectTagNo = TextEditingController();
  TextEditingController matingDateInput = TextEditingController();
  TextEditingController deliveryDateInput = TextEditingController();
  TextEditingController paymentInput = TextEditingController();
  TextEditingController numberOfCows = TextEditingController();
  TextEditingController calfTagNoInput = TextEditingController();
  TextEditingController animalNameInput = TextEditingController();
  int showObId = 0;
  String selectedGender = "";
  String selectCattleGrp = '';
  bool showSuggestions = false;
  final dataCycle = Cycle();

  @override
  void initState() {
    super.initState();
    getCycleData();

    showObId = widget.event.obid;
    typeOfEvent = widget.event.typeOfEvent;

    if (typeOfEvent != "MassEvents") {
      tagInput.text = widget.event.tagNo.toString();
      animalNameInput.text =
          animalBox.getPropertyForTagNo(tagInput.text, 'name') ?? '';
      selectedGender =
          animalBox.getPropertyForTagNo(tagInput.text, 'gender') ?? '';
    }

    dateInput.text = widget.event.dateOfEvent.toString();
    symptomsInput.text = widget.event.symptomsOfSickness.toString();
    diagnosisInput.text = widget.event.diagnosis.toString();
    technicianNameInput.text = widget.event.technicianName.toString();
    noteInput.text = widget.event.desc.toString();
    typeOfEvent = widget.event.typeOfEvent;

    if (typeOfEvent == "Mass Events") {
      selectEvent.text = widget.event.eventType.toString();
      selectCattleGrp = widget.event.group.toString();
    } else if (typeOfEvent == "Individual Events") {
      if (selectedGender == "Male") {
        selectEvent.text = widget.event.eventType.toString();
      } else if (selectedGender == "Female") {
        selectEvent.text = widget.event.eventType.toString();
      }
    }
    medicineNameInput.text = widget.event.medicineName.toString();
    semenInput.text = widget.event.semen.toString();
    estimatedReturnHeatDateInput.text =
        widget.event.estimatedHeatDate.toString();
    matingDateInput.text = widget.event.matingDate.toString();
    deliveryDateInput.text = widget.event.deliveryDate.toString();
    calfTagNoInput.text = widget.event.calfTagNo.toString();
    paymentInput.text = widget.event.paymentType.toString();
  }

  Future<void> getCycleData() async {
    try {
      final CycleBox cycleBox = CycleBox();
      final List<Cycle> cycles = cycleBox.list();

      if (cycles.isNotEmpty) {
        setState(() {
          // Assuming you only need the first cycle in the list
          dataCycle.heatCycle = cycles[0].heatCycle;
          dataCycle.deliveryCycle = cycles[0].deliveryCycle;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    DateTime? dateTime = DateTime.now();

    List<String> techName = eventBox.getTecName().whereType<String>().toList();

    int heatCycle = dataCycle.heatCycle;
    int deliveryCycle = dataCycle.deliveryCycle;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Edit Event Details'),
        centerTitle: true,
        leading: AppTheme.buildBackIconButton(context, "/viewEventEntry"),
        actions: [
          GestureDetector(
            onTap: () async {
              try {
                EventBox aiBox = EventBox();
                var eventList = aiBox.list();
                int tmp = eventList.length;
                print("Count ==> $tmp");
                String animalTagNo = tagInput.text.split('[').first.trim();

                AI ai = AI(
                  obid: showObId,
                  tagNo: animalTagNo.toString(),
                  name: animalNameInput.text,
                  dateOfEvent: dateInput.text,
                  desc: noteInput.text,
                  typeOfEvent: typeOfEvent,
                  semen: semenInput.text,
                  symptomsOfSickness: symptomsInput.text,
                  diagnosis: diagnosisInput.text,
                  technicianName: technicianNameInput.text,
                  estimatedHeatDate: estimatedReturnHeatDateInput.text,
                  medicineName: medicineNameInput.text,
                  matingDate: matingDateInput.text,
                  deliveryDate: deliveryDateInput.text,
                  paymentType: paymentInput.text,
                  calfTagNo: calfTagNoInput.text,
                );

                if (typeOfEvent == "Mass Events") {
                  ai.eventType = selectEvent.text;
                  ai.numberOfAnimal = numberOfCows.text;
                  ai.group = selectCattleGrp;
                } else if (typeOfEvent == "Individual Events") {
                  if (selectedGender == "Male") {
                    ai.eventType = selectEvent.text;
                  } else if (selectedGender == "Female") {
                    ai.eventType = selectEvent.text;
                  }
                }
                aiBox.create(ai.toJson());

                print("Count ==> ${aiBox.list().length}");
              } catch (ex) {
                print(ex.toString());
              } finally {
                Navigator.of(context).popAndPushNamed("/viewEventEntry");
                AppTheme.showSnackBar(
                    context, "$typeOfEvent Updated Successfully");
                final jsonData =
                    await ImportAndExport.exportDataToJson(context);
                await ImportAndExport.writeJsonToFile(jsonData);
              }
            },
            child: const Icon(
              Icons.save_as_outlined,
              size: 30,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Event Date TextFormField
            Container(
              margin: const EdgeInsets.all(15),
              child: TextFormField(
                readOnly: true,
                onTap: () async {
                  DateTime? dateTime =
                      await OmniDateTimePickerUtil.showDateTimePicker(context);
                  if (dateTime != null) {
                    dateInput.text = DateFormat('yyyy-MM-dd').format(dateTime);
                    // Calculate the estimated return heat date (20 days ahead)
                    DateTime estimatedDate =
                        dateTime!.add(Duration(days: heatCycle));
                    estimatedReturnHeatDateInput.text =
                        DateFormat('yyyy-MM-dd').format(estimatedDate);
                  }
                },
                controller: dateInput,
                style: AppTheme.textStyleContainer(),
                onChanged: (value) {
                  setState(() {
                    dateInput.text = value.toString();
                  });
                },
                decoration: AppTheme.textFieldInputDecoration("Event Date"),
              ),
            ),

            Visibility(
              visible: typeOfEvent == "Individual Events",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: tagInput,
                  style: AppTheme.textStyleContainer(),
                  readOnly: true,
                  onChanged: null,
                  decoration: AppTheme.textFieldInputDecoration("Tag No"),
                ),
              ),
            ),

            Visibility(
              visible: typeOfEvent == "Individual Events" &&
                  tagInput.text.isNotEmpty,
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: animalNameInput,
                  style: AppTheme.textStyleContainer(),
                  readOnly: true,
                  onChanged: null,
                  decoration: AppTheme.textFieldInputDecoration("Animal Name"),
                ),
              ),
            ),
            Visibility(
              visible: typeOfEvent == "Mass Events",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: DropdownButtonFormField<String>(
                  value: selectCattleGrp,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectCattleGrp = newValue as String;
                    });
                  },
                  decoration:
                      AppTheme.textFieldInputDecoration("Select Cattle Group"),
                  items: DropdownListItems.massEventItems
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),

            //Show Event Type
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                controller: selectEvent,
                style: AppTheme.textStyleContainer(),
                onChanged: null,
                readOnly: true,
                decoration: AppTheme.textFieldInputDecoration('Event Type'),
              ),
            ),

            //if you selected Vaccination/ Injection. show this textformfield
            Visibility(
              visible: selectEvent.text == "Vaccination/Injection" ||
                  selectEvent.text == "Deworming" ||
                  selectEvent.text == "Treatment/Medication" ||
                  selectEvent.text == "Vaccinated" ||
                  selectEvent.text == "Vaccinated",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: medicineNameInput,
                  style: AppTheme.textStyleContainer(),
                  onChanged: (value) {
                    setState(() {
                      medicineNameInput.text = value.toString();
                    });
                    final textSelection = TextSelection.collapsed(
                        offset: medicineNameInput.text.length);
                    medicineNameInput.selection = textSelection;
                  },
                  decoration:
                      AppTheme.textFieldInputDecoration("Name of the Medicine"),
                ),
              ),
            ),

            //Semen / tag.no. of Bull Responsible
            Visibility(
              visible: selectEvent.text == "Inseminated/Mated" ||
                  selectEvent.text == "Gives Birth" ||
                  selectEvent.text == "Pregnant",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: semenInput,
                  style: AppTheme.textStyleContainer(),
                  onChanged: (value) {
                    setState(() {
                      semenInput.text = value.toString();
                    });
                    final textSelection =
                        TextSelection.collapsed(offset: semenInput.text.length);
                    semenInput.selection = textSelection;
                  },
                  decoration: AppTheme.textFieldInputDecoration(
                      "Semen/tag.No of Responsible"),
                ),
              ),
            ),


            //This is for only Treated/Medicated from Individual Events//
            Visibility(
              visible: selectEvent.text == "Treated/Medicated" ||
                  selectEvent.text == "Treated/Medicated",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: symptomsInput,
                  style: AppTheme.textStyleContainer(),
                  onChanged: (value) {
                    setState(() {
                      symptomsInput.text = value.toString();
                    });
                    final textSelection = TextSelection.collapsed(
                        offset: symptomsInput.text.length);
                    symptomsInput.selection = textSelection;
                  },
                  decoration:
                      AppTheme.textFieldInputDecoration("Symptoms of sickness"),
                ),
              ),
            ),

            //This is for only Treated/Medicated from Individual Events (diagnosis)//
            Visibility(
              visible: selectEvent.text == "Treated/Medicated" ||
                  selectEvent.text == "Treated/Medicated",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: diagnosisInput,
                  style: AppTheme.textStyleContainer(),
                  onChanged: (value) {
                    setState(() {
                      diagnosisInput.text = value.toString();
                    });
                    final textSelection = TextSelection.collapsed(
                        offset: diagnosisInput.text.length);
                    diagnosisInput.selection = textSelection;
                  },
                  decoration: AppTheme.textFieldInputDecoration("Diagnosis"),
                ),
              ),
            ),

            //This is for only Treated/Medicated from Individual Events//
            Visibility(
              visible: selectEvent.text == "Treated/Medicated" ||
                  selectEvent.text == "Treated/Medicated" ||
                  selectEvent.text == "Inseminated/Mated"||
                  selectEvent.text == "Deworming",
              child: SearchContainer(
                controller: technicianNameInput,
                suggestionList: techName,
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    technicianNameInput.text = suggestion;
                    showSuggestions = false;
                  });
                },
                decoration: AppTheme.textFieldInputDecoration(
                  "Select Technician Name",
                ),
                // onPressedCallback: toggleSuggestions,
                showSuggestions: showSuggestions,
              ),
            ),

            //Estimated return to heat date for Inseminated/Mated
            Visibility(
              visible: selectEvent.text == "Inseminated/Mated",
              child: Container(
                margin: const EdgeInsets.all(15),
                child: TextFormField(
                  readOnly: true,
                  onTap: () async {
                    DateTime? dateTime =
                        await OmniDateTimePickerUtil.showDateTimePicker(
                            context);
                    if (dateTime != null) {
                      estimatedReturnHeatDateInput.text =
                          DateFormat('yyyy-MM-dd').format(dateTime);
                    }
                  },
                  controller: estimatedReturnHeatDateInput,
                  style: AppTheme.textStyleContainer(),
                  onChanged: (value) {
                    setState(() {
                      estimatedReturnHeatDateInput.text = value.toString();
                    });
                  },
                  decoration: AppTheme.textFieldInputDecoration(
                      "Estimated return to heat date"),
                ),
              ),
            ),

            //Mating Date Input Calender
            Visibility(
              visible: selectEvent.text == "Pregnant",
              child: Container(
                margin: const EdgeInsets.all(15),
                child: TextFormField(
                  readOnly: true,
                  onTap: () async {
                    DateTime? dateTime =
                        await OmniDateTimePickerUtil.showDateTimePicker(
                            context);
                    if (dateTime != null) {
                      matingDateInput.text =
                          DateFormat('yyyy-MM-dd').format(dateTime);
                    }
                    // Calculate the expected delivery  date (9 Months or 283 days)
                    if (matingDateInput.text.isNotEmpty) {
                      DateTime expectedDeliveryDate =
                          dateTime!.add( Duration(days:deliveryCycle ));
                      deliveryDateInput.text =
                          DateFormat('yyyy-MM-dd').format(expectedDeliveryDate);
                    }
                  },
                  controller: matingDateInput,
                  style: AppTheme.textStyleContainer(),
                  onChanged: (String newValue) {
                    matingDateInput.text = newValue;
                    setState(() {
                      DateTime expectedDeliveryDate =
                          dateTime!.add(const Duration(days: 283));
                      deliveryDateInput.text =
                          DateFormat('yyyy-MM-dd').format(expectedDeliveryDate);
                    });
                  },
                  decoration: AppTheme.textFieldInputDecoration(
                      "Insemination/Mating Date"),
                ),
              ),
            ),

            //Expected Delivery Date Calender
            Visibility(
              visible: selectEvent.text == "Pregnant",
              child: Container(
                margin: const EdgeInsets.all(15),
                child: TextFormField(
                  readOnly: true,
                  onTap: () async {
                    DateTime? dateTime =
                        await OmniDateTimePickerUtil.showDateTimePicker(
                            context);
                    if (dateTime != null) {
                      deliveryDateInput.text =
                          DateFormat('yyyy-MM-dd').format(dateTime);
                    }
                  },
                  controller: deliveryDateInput,
                  style: AppTheme.textStyleContainer(),
                  decoration: AppTheme.textFieldInputDecoration(
                      "Expected Delivery Date"),
                ),
              ),
            ),

            Visibility(
              visible: selectEvent.text == "Vaccinated" ||
                  selectEvent.text == "Treated/Medicated" ||
                  selectEvent.text == "Inseminated/Mated",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: paymentInput,
                  style: AppTheme.textStyleContainer(),
                  keyboardType: TextInputType.number,
                  decoration: AppTheme.textFieldInputDecoration(
                      "How much did you spend"),
                ),
              ),
            ),

            //Number of cows Count
            Visibility(
              visible: typeOfEvent == "Mass Events" &&
                  selectEvent.text != "Select Event Type Mass",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: numberOfCows,
                  style: AppTheme.textStyleContainer(),
                  onChanged: (value) {
                    setState(() {
                      numberOfCows.text = value.toString();
                    });
                    final textSelection = TextSelection.collapsed(
                        offset: numberOfCows.text.length);
                    numberOfCows.selection = textSelection;
                  },
                  keyboardType: TextInputType.number,
                  decoration:
                      AppTheme.textFieldInputDecoration("Number Of Animals"),
                ),
              ),
            ),

            Visibility(
              visible: selectEvent.text == "Gives Birth",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: calfTagNoInput,
                  style: AppTheme.textStyleContainer(),
                  onChanged: (value) {
                    setState(() {
                      calfTagNoInput.text = value.toString();
                    });
                    final textSelection = TextSelection.collapsed(
                        offset: calfTagNoInput.text.length);
                    calfTagNoInput.selection = textSelection;
                  },
                  decoration: AppTheme.textFieldInputDecoration("Calf Tag No"),
                ),
              ),
            ),

            //Write Some Notes TextFormField
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                controller: noteInput,
                style: AppTheme.textStyleContainer(),
                onChanged: (value) {
                  setState(() {
                    noteInput.text = value.toString();
                  });
                  final textSelection =
                      TextSelection.collapsed(offset: noteInput.text.length);
                  noteInput.selection = textSelection;
                },
                decoration:
                    AppTheme.textFieldInputDecoration("Write Some Notes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
