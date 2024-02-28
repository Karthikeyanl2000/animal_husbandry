import 'dart:core';
import 'package:animal_husbandry/import_export_data/import_export.dart';
import 'package:animal_husbandry/objectbox/dateCycle_Box.dart';
import 'package:animal_husbandry/objectbox/event_box.dart';
import 'package:animal_husbandry/objectbox/animal_box.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:animal_husbandry/widget/dateTimePicker.dart';
import 'package:animal_husbandry/widget/dropdown_ListItems.dart';
import 'package:animal_husbandry/widget/filter_event.dart';
import 'package:animal_husbandry/widget/search_container.dart';
import 'package:flutter/material.dart';
import 'package:hyper_object_box/model/ai.dart';
import 'package:hyper_object_box/model/animal.dart';
import 'package:hyper_object_box/model/cycle.dart';
import 'package:intl/intl.dart';

class EventEntry extends StatefulWidget {
  final Function(AI) onEventAdded;
  final Animal animal;
  final AI event;
  final String typeOfEvent;

  const EventEntry({
    Key? key,
    required this.onEventAdded,
    required this.animal,
    required this.event,
    required this.typeOfEvent,
  }) : super(key: key);

  @override
  State<EventEntry> createState() => _EventEntryState();
}

class _EventEntryState extends State<EventEntry> {
  final EventBox aiBox = EventBox();
  final AnimalBox animalBox = AnimalBox();
  final CycleBox dateCycleBox = CycleBox();
  List<AI> listInseminationEvent = [];
  final dateCycle = Cycle();

  late bool isIndividualEvents;
  TextEditingController dateInput = TextEditingController();
  TextEditingController eventTypeInput = TextEditingController();
  TextEditingController noteInput = TextEditingController();
  TextEditingController medicineNameInput = TextEditingController();
  TextEditingController symptomsInput = TextEditingController();
  TextEditingController diagnosisInput = TextEditingController();
  TextEditingController technicianNameInput = TextEditingController();
  TextEditingController estimatedReturnHeatDateInput = TextEditingController();
  TextEditingController semenInput = TextEditingController();
  TextEditingController matingDateInput = TextEditingController();
  TextEditingController deliveryDateInput = TextEditingController();
  TextEditingController showName = TextEditingController();
  TextEditingController paymentInput = TextEditingController();
  TextEditingController numberOfAnimalInput = TextEditingController();
  TextEditingController calfTagNoInput = TextEditingController();
  String actualTagNo = "";

  List<String> getAvailableCattle() {
    return animalBox
        .getFilterTagNumbersFromObjectBox()
        .whereType<String>()
        .toList();
  }

  String? selectEvent;
  String? typeOfEvent;
  String? selectMassEvent;
  String? selectCattleGrp;
  String selectedGender = '';
  String? calfGender;
  bool showSuggestions = false;
  TextEditingController selectCattle = TextEditingController();

  Future<void> getCycleData() async {
    try {
      final CycleBox cycleBox = CycleBox();
      final List<Cycle> cycles = cycleBox.list();

      if (cycles.isNotEmpty) {
        setState(() {
          dateCycle.heatCycle = cycles[0].heatCycle;
          dateCycle.deliveryCycle = cycles[0].deliveryCycle;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getCycleData();
    typeOfEvent = widget.typeOfEvent;
    DateTime dateTime = DateTime.now();
    dateInput.text = DateFormat("yyyy-MM-dd").format(dateTime);

    DateTime estimatedDate = dateTime.add(Duration(days: dateCycle.heatCycle));
    estimatedReturnHeatDateInput.text =
        DateFormat("yyyy-MM-dd").format(estimatedDate);
  }

  @override
  Widget build(BuildContext context) {
    List<String> animalsList = animalBox
        .getFilterTagNumbersFromObjectBox()
        .whereType<String>()
        .toList();

    List<String> techName = aiBox.getTecName().whereType<String>().toList();
    DateTime dateTime = DateTime.now();
    String animalTagNo = selectCattle.text.split('[').first.trim();
    Animal? existingAnimal = AppTheme.getAnimalByTagNo(calfTagNoInput.text);
    bool existTagNo = existingAnimal?.tagNo! == calfTagNoInput.text;

    int heatCycle = dateCycle.heatCycle;
    int deliveryCycle = dateCycle.deliveryCycle;

    actualTagNo = selectCattle.text.split('[').first.trim();

    bool canExecuteOnTap() {
      if (typeOfEvent == "Individual Events") {
        return (actualTagNo == "" || actualTagNo.isEmpty) ||
            (selectEvent == "Select Event Type" || selectEvent == null);
      } else if (typeOfEvent == "Mass Events") {
        return (selectMassEvent == "Select Event Type Mass" ||
                selectMassEvent == null) ||
            (selectCattleGrp == null ||
                selectCattleGrp == "Select Cattle Group");
      }
      return false;
    }

    bool isButtonEnabled = !canExecuteOnTap();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('New Event Entry'),
        centerTitle: true,
        leading: AppTheme.buildBackIconButton(context, "/viewEventEntry"),
        actions: [
          GestureDetector(
            onTap: () async {
              if (isButtonEnabled) {
                try {
                  EventBox aiBox = EventBox();
                  AnimalBox animalBox = AnimalBox();
                  var eventList = aiBox.list();
                  int tmp = eventList.length;
                  print("Count ==> $tmp");

                  if (actualTagNo.toString().isNotEmpty) {
                    Animal? existingAnimal =
                        AppTheme.getAnimalByTagNo(actualTagNo.toString());
                    if (existingAnimal != null) {
                      if (selectEvent == "Pregnant") {
                        existingAnimal.cattleStatus = "Pregnant";
                      } else if (selectEvent == "Gives Birth") {
                        existingAnimal.cattleStatus = "Lactating";
                      }
                      animalBox.create(existingAnimal.toJson());
                    }
                  }

                  // Calf Registered into Animals List
                  if (calfTagNoInput.text.isNotEmpty &&
                      selectEvent == "Gives Birth") {
                    Animal animal = Animal();
                    animal.tagNo = calfTagNoInput.text;
                    animal.motherTagNo = actualTagNo.toString();
                    animal.gender = calfGender;
                    animal.cattlestage = "Calf";
                    animal.dob = dateInput.text;
                    animal.soa = "Born on Farm";
                    animal.group = "Babies";
                    animal.fatherTagNo = semenInput.text;
                    animalBox.create(animal.toJson());
                  }

                  //New Event Entry
                  AI ai = AI(
                    tagNo: actualTagNo.toString(),
                    name: showName.text,
                    dateOfEvent: dateInput.text,
                    desc: noteInput.text,
                    typeOfEvent: typeOfEvent,
                    semen: semenInput.text,
                    technicianName: technicianNameInput.text,
                    symptomsOfSickness: symptomsInput.text,
                    diagnosis: diagnosisInput.text,
                    medicineName: medicineNameInput.text,
                    estimatedHeatDate: estimatedReturnHeatDateInput.text,
                    matingDate: matingDateInput.text,
                    deliveryDate: deliveryDateInput.text,
                    paymentType: paymentInput.text,
                    calfTagNo: calfTagNoInput.text,
                  );
                  if (typeOfEvent == "Mass Events") {
                    ai.eventType = selectMassEvent;
                    ai.numberOfAnimal = numberOfAnimalInput.text;
                    ai.group = selectCattleGrp;
                  } else if (typeOfEvent == "Individual Events") {
                    if (selectedGender == "Male" ||
                        selectedGender == "Female") {
                      ai.eventType = selectEvent;
                    }
                  }
                  aiBox.create(ai.toJson());
                  print("Count ==> ${aiBox.list().length}");
                } finally {
                  Navigator.of(context).popAndPushNamed("/viewEventEntry");
                  AppTheme.showSnackBar(
                      context, "$typeOfEvent has been created successfully!");
                  final jsonData =
                      await ImportAndExport.exportDataToJson(context);
                  await ImportAndExport.writeJsonToFile(jsonData);
                }
              } else {
                AppTheme.showSnackBar(context, "Select Valid Details!");
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
            //New Event Date Calender
            Container(
              margin: const EdgeInsets.all(15),
              child: TextFormField(
                readOnly: true,
                onTap: () async {
                  DateTime? dateTime =
                      await OmniDateTimePickerUtil.showDateTimePicker(context);
                  if (dateTime != null) {
                    dateInput.text = DateFormat("yyyy-MM-dd").format(dateTime!);
                    // Calculate the estimated return heat date (20 days ahead)
                    DateTime estimatedDate =
                        dateTime!.add(Duration(days: heatCycle));
                    estimatedReturnHeatDateInput.text =
                        DateFormat("yyyy-MM-dd").format(estimatedDate);
                  }
                },
                controller: dateInput,
                style: AppTheme.textStyleContainer(),
                decoration: AppTheme.textFieldInputDecoration("Event Date"),
              ),
            ),

            //Select type of event (Individual / Mass)
            Container(
              margin: const EdgeInsets.all(15),
              child: DropdownButtonFormField<String>(
                value: typeOfEvent,
                onChanged: (String? newValue) {
                  setState(() {
                    typeOfEvent = newValue as String;
                    selectEvent = 'Select Event Type';
                    selectMassEvent = 'Select Event Type Mass';
                    selectCattle.text;
                  });
                },
                decoration:
                    AppTheme.textFieldInputDecoration("Select Type Of Event"),
                items: DropdownListItems.typeOfEventItems
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            //Select Cattle for Individual Events //
            Visibility(
              visible: typeOfEvent == "Individual Events",
              child: SearchContainer(
                controller: selectCattle,
                suggestionList: animalsList,
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    selectCattle.text = suggestion;
                    String animalTagNo =
                        selectCattle.text.split('[').first.trim();
                    showName.text = animalBox.getPropertyForTagNo(
                        animalTagNo.toString(), 'name')!;
                    selectedGender = animalBox.getPropertyForTagNo(
                        animalTagNo.toString(), 'gender')!;
                    selectEvent = "Select Event Type";
                  });
                },
                decoration: AppTheme.textFieldInputDecoration('Select Animal'),
                // onPressedCallback: toggleSuggestions,
                showSuggestions: showSuggestions,
              ),
            ),

            //Animal Name
            Visibility(
              visible: typeOfEvent == "Individual Events" &&
                  selectCattle.text.isNotEmpty,
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: showName,
                  style: AppTheme.textStyleContainer(),
                  enabled: false,
                  onChanged: null,
                  decoration: AppTheme.textFieldInputDecoration("Animal Name"),
                ),
              ),
            ),

            // Select Individual Events For Male and Female
            Visibility(
              visible: typeOfEvent == "Individual Events" &&
                  getAvailableCattle().contains(selectCattle.text) &&
                  selectedGender.isNotEmpty,
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: DropdownButtonFormField<String>(
                  value: selectEvent,
                  onChanged: (String? newValue) {
                    if (selectCattle.text.isNotEmpty) {
                      listInseminationEvent = FilterEvents.getLastFilterDate(
                          aiBox.list(),
                          "Inseminated/Mated",
                          animalTagNo.toString());
                    }
                    if (listInseminationEvent.isNotEmpty &&
                        selectEvent != "Inseminated/Mated") {
                      semenInput.text =
                          listInseminationEvent.reversed.toList().first.semen!;

                      matingDateInput.text = listInseminationEvent.reversed
                          .toList()
                          .first
                          .dateOfEvent!;
                    }
                    if (matingDateInput.text.isNotEmpty) {
                      DateTime matedDateTime =
                          DateFormat("yyyy-MM-dd").parse(matingDateInput.text);

                      // Add 283 days to the matedDateTime
                      DateTime expectedDeliveryDate =
                          matedDateTime.add(Duration(days: deliveryCycle));

                      // Format the expectedDeliveryDate and set it as the text for deliveryDateInput
                      deliveryDateInput.text =
                          DateFormat("yyyy-MM-dd").format(expectedDeliveryDate);
                    }
                    setState(() {
                      selectEvent = newValue as String;
                    });
                  },
                  decoration: AppTheme.textFieldInputDecoration(
                      "Select Individual Event Type For : $selectedGender"),
                  items: (selectedGender == "Male"
                          ? DropdownListItems.eventTypeMaleItems
                          : DropdownListItems.eventTypeFemaleItems)
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),

            //select Cattle Group for Mass Events
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

            //Select Event Type for Mass Events
            Visibility(
              visible: typeOfEvent == "Mass Events",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: DropdownButtonFormField<String>(
                  value: selectMassEvent,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectMassEvent = newValue as String;
                    });
                  },
                  decoration: AppTheme.textFieldInputDecoration(
                      "Select Event Type Mass"),
                  items: DropdownListItems.eventTypeMassItems
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),

            //if you selected Vaccination/ Injection. show this textformfield
            Visibility(
              visible: selectMassEvent == "Vaccination/Injection" ||
                  selectMassEvent == "Deworming" ||
                  selectMassEvent == "Treatment/Medication" ||
                  selectEvent == "Vaccinated" ||
                  selectEvent == 'Deworming',
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: medicineNameInput,
                  style: AppTheme.textStyleContainer(),
                  decoration: AppTheme.textFieldInputDecoration(
                      "Name Of The Medicine Given"),
                ),
              ),
            ),

            //Semen / tag.no. of Bull Responsible
            Visibility(
              visible: selectEvent == "Inseminated/Mated" ||
                  selectEvent == "Gives Birth" ||
                  selectEvent == "Pregnant",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: semenInput,
                  style: AppTheme.textStyleContainer(),
                  decoration: AppTheme.textFieldInputDecoration(
                      "Semen/Tag.no of Responsible"),
                ),
              ),
            ),

            //This is for only Treated/Medicated from Individual Events//
            Visibility(
              visible: selectEvent == "Treated/Medicated",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: symptomsInput,
                  style: AppTheme.textStyleContainer(),
                  decoration:
                      AppTheme.textFieldInputDecoration("Symptoms of sickness"),
                ),
              ),
            ),

            //This is for only Treated/Medicated from Individual Events (diagnosis)//
            Visibility(
              visible: selectEvent == "Treated/Medicated",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: diagnosisInput,
                  style: AppTheme.textStyleContainer(),
                  decoration: AppTheme.textFieldInputDecoration("Diagnosis"),
                ),
              ),
            ),

            //This is for only Treated/Medicated from Individual Events//
            Visibility(
              visible: selectEvent == "Treated/Medicated" ||
                  selectEvent == "Inseminated/Mated" ||
                  selectEvent == "Vaccinated" ||
                  selectEvent == "Deworming",
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

            //This is for how much do you spend
            Visibility(
              visible: selectEvent == "Vaccinated" ||
                  selectEvent == "Treated/Medicated" ||
                  selectEvent == "Inseminated/Mated" ||
                  typeOfEvent == "Mass Events" &&
                      selectMassEvent != "Select Event Type Mass",
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

            //Estimated return to heat date for Inseminated/Mated
            Visibility(
              visible: selectEvent == "Inseminated/Mated",
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
                          DateFormat("yyyy-MM-dd").format(dateTime);
                    }
                  },
                  controller: estimatedReturnHeatDateInput,
                  style: AppTheme.textStyleContainer(),
                  decoration: AppTheme.textFieldInputDecoration(
                      "Estimated return to heat date"),
                ),
              ),
            ),

            //Insemination/Mating Date for Event Type Pregnant
            Visibility(
              visible: selectEvent == "Pregnant",
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
                          DateFormat("yyyy-MM-dd").format(dateTime);
                    }
                    // Calculate the expected delivery  date (9 Months or 283 days)
                    if (matingDateInput.text.isNotEmpty) {
                      DateTime expectedDeliveryDate =
                          dateTime!.add(Duration(days: deliveryCycle));
                      deliveryDateInput.text =
                          DateFormat("yyyy-MM-dd").format(expectedDeliveryDate);
                    }
                  },
                  controller: matingDateInput,
                  style: AppTheme.textStyleContainer(),
                  onChanged: (String newvalue) {
                    matingDateInput.text = newvalue;
                    setState(() {
                      DateTime expectedDeliveryDate =
                          dateTime!.add(Duration(days: deliveryCycle));
                      deliveryDateInput.text =
                          DateFormat("yyyy-MM-dd").format(expectedDeliveryDate);
                    });
                  },
                  decoration: AppTheme.textFieldInputDecoration(
                      "Insemination/Mating Date"),
                ),
              ),
            ),

            //Expected Delivery Date
            Visibility(
              visible: selectEvent == "Pregnant",
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
                          DateFormat("yyyy-MM-dd").format(dateTime);
                    }
                  },
                  controller: deliveryDateInput,
                  style: AppTheme.textStyleContainer(),
                  decoration: AppTheme.textFieldInputDecoration(
                      "Expected Delivery Date"),
                ),
              ),
            ),

            //Count Number Of Cows for Mass Events
            Visibility(
              visible: typeOfEvent == "Mass Events" &&
                  selectMassEvent != "Select Event Type Mass",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: numberOfAnimalInput,
                  style: AppTheme.textStyleContainer(),
                  keyboardType: TextInputType.number,
                  decoration:
                      AppTheme.textFieldInputDecoration("Number Of Animals"),
                ),
              ),
            ),

            //Calf Tag No
            Visibility(
              visible: selectEvent == "Gives Birth",
              child: Container(
                  margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: calfTagNoInput,
                        style: AppTheme.textStyleContainer(),
                        onChanged: (String? newValue) {
                          setState(() {
                            calfTagNoInput.text = newValue as String;
                          });
                          final textSelection = TextSelection.collapsed(
                              offset: calfTagNoInput.text.length);
                          calfTagNoInput.selection = textSelection;
                        },
                        decoration:
                            AppTheme.textFieldInputDecoration("Calf Tag No."),
                      ),
                      if (existTagNo)
                        const Text(
                          "Already Existed TagNo!",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  )),
            ),

            //Select Calf Gender
            Visibility(
              visible: selectEvent == "Gives Birth",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: DropdownButtonFormField<String>(
                  value: calfGender,
                  onChanged: (String? newValue) {
                    setState(() {
                      calfGender = newValue as String;
                    });
                  },
                  decoration:
                      AppTheme.textFieldInputDecoration("Select Calf Gender"),
                  items: DropdownListItems.genderItems
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),

            //Write Some Notes TextFormField
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                controller: noteInput,
                style: AppTheme.textStyleContainer(),
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
