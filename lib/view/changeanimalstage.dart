import 'package:animal_husbandry/objectbox/animal_box.dart';
import 'package:animal_husbandry/objectbox/event_box.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:animal_husbandry/widget/dateTimePicker.dart';
import 'package:animal_husbandry/widget/dropdown_ListItems.dart';
import 'package:animal_husbandry/widget/search_container.dart';
import 'package:flutter/material.dart';
import 'package:hyper_object_box/model/ai.dart';
import 'package:hyper_object_box/model/animal.dart';
import 'package:intl/intl.dart';

enum RadioButton { changeStage, changeStatus, archiving }

class ChangeAnimalStage extends StatefulWidget {
  final Animal animal;
  final AI event;
  const ChangeAnimalStage({Key? key, required this.animal, required this.event})
      : super(key: key);

  @override
  State<ChangeAnimalStage> createState() => _ChangeAnimalStageState();
}

class _ChangeAnimalStageState extends State<ChangeAnimalStage> {
  RadioButton button = RadioButton.changeStage;
  final EventBox aiBox = EventBox();
  final AnimalBox animalBox = AnimalBox();

  TextEditingController tagNoInput = TextEditingController();
  TextEditingController animalNameInput = TextEditingController();
  TextEditingController cattleStageInput = TextEditingController();
  TextEditingController cattleStatusInput = TextEditingController();
  TextEditingController genderInput = TextEditingController();
  TextEditingController archivedDateInput = TextEditingController();
  TextEditingController archivedNoteInput = TextEditingController();
  String? updateCattleStage = "";
  String? updateCattleStatus = "";
  String? updateArchivedStatus = '';
  TextEditingController searchController = TextEditingController();
  TextEditingController animalTagNoInput = TextEditingController();
  bool showSuggestions = false;
  int showObId = 0;
  String actualTagNo = "";

  void toggleSuggestions() {
    setState(() {
      showSuggestions = !showSuggestions;
    });
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> animalsList = animalBox
        .getFilterTagNumbersFromObjectBox()
        .whereType<String>()
        .toList();
    DateTime? dateTime = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Change Animal Stage'),
        centerTitle: true,
        leading: AppTheme.buildBackIconButton(context, "/homeScreen"),
        actions: [
          GestureDetector(
            onTap: () {
              if(animalTagNoInput.text.isNotEmpty) {
                try {
                  actualTagNo = animalTagNoInput.text
                      .split('[')
                      .first
                      .trim();
                  AnimalBox animalBox = AnimalBox();
                  var animalList = AnimalBox().list();
                  int tmp = animalList.length;
                  print("Count ==> $tmp");

                  // Update the cattleStatus and Stage and archiving status Existing Animal Records
                  if (actualTagNo.isNotEmpty) {
                    Animal? existingAnimal =
                    AppTheme.getAnimalByTagNo(actualTagNo.toString());
                    if (existingAnimal != null) {
                      existingAnimal.cattleStatus = updateCattleStatus;
                      existingAnimal.cattlestage = updateCattleStage;
                      if (updateArchivedStatus!.isNotEmpty) {
                        existingAnimal.isArchived = updateArchivedStatus;
                        existingAnimal.archivedNote = archivedNoteInput.text;
                        existingAnimal.archivedDate = archivedDateInput.text;
                      }
                      animalBox.create(existingAnimal.toJson());
                    }
                  }
                } catch (e) {

                } finally {
                  Navigator.of(context).popAndPushNamed('/changeAnimalStage');
                  AppTheme.showSnackBar(
                      context, "Status Updated Successfully!");
                }
              }
              else{
                AppTheme.showSnackBar(context, "Enter Valid Details");
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
            //Select And Search Animal Tag No
            SearchContainer(
              controller: animalTagNoInput,
              suggestionList: animalsList,
              onSuggestionSelected: (suggestion) {
                setState(() {
                  animalTagNoInput.text = suggestion;
                  showSuggestions = false;
                  genderInput.text;
                  animalNameInput.text;
                  updateCattleStage = "Select Cattle Stage";
                });
                if (animalTagNoInput.text.isNotEmpty) {
                  genderInput.text = animalBox.getPropertyForTagNo(
                          animalTagNoInput.text, 'gender') ??
                      '';
                  animalNameInput.text = animalBox.getPropertyForTagNo(
                          animalTagNoInput.text, 'name') ??
                      '';
                  updateCattleStage = animalBox.getPropertyForTagNo(
                          animalTagNoInput.text, 'cattlestage') ??
                      '';
                  updateCattleStatus = animalBox.getPropertyForTagNo(
                          animalTagNoInput.text, 'cattleStatus') ??
                      '';
                  updateArchivedStatus = animalBox.getPropertyForTagNo(
                          animalTagNoInput.text, 'isArchived') ??
                      '';
                }
              },
               decoration: AppTheme.textFieldInputDecoration('Select Animal',),
              // onPressedCallback: toggleSuggestions,
              showSuggestions: showSuggestions,
            ),

            //Animal Name
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                controller: animalNameInput,
                style: AppTheme.textStyleContainer(),
                enabled: false,
                onChanged: null,
                decoration: AppTheme.textFieldInputDecoration("Animal Name"),
              ),
            ),

            //Animal Gender
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                controller: genderInput,
                style: AppTheme.textStyleContainer(),
                enabled: false,
                onChanged: null,
                decoration: AppTheme.textFieldInputDecoration("Gender"),
              ),
            ),


               Container(
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Radio(
                        value: RadioButton.changeStage,
                        groupValue: button,
                        onChanged: (RadioButton? value) {
                          setState(() {
                            button = value ?? RadioButton.changeStage;
                          });
                        },
                      ),
                      const Text("Change Stage"),
                      const SizedBox(width: 3),
                      Radio(
                        value: RadioButton.changeStatus,
                        groupValue: button,
                        onChanged: (RadioButton? value) {
                          setState(() {
                            button = value ?? RadioButton.changeStatus;
                          });
                        },
                      ),
                      const Text("Change Status"),
                      const SizedBox(width: 3),
                      Radio(
                        value: RadioButton.archiving,
                        groupValue: button,
                        onChanged: (RadioButton? value) {
                          setState(() {
                            button = value ?? RadioButton.archiving;
                          });
                        },
                      ),
                      const Text("Archive"),
                    ],
                  ),
                ),
              ),


            //Show Current Stage Of The Animal
            Visibility(
              visible: animalTagNoInput.text.isNotEmpty &&
                  button == RadioButton.changeStage,
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: DropdownButtonFormField<String>(
                  value: updateCattleStage,
                  onChanged: null,
                  decoration:
                      AppTheme.textFieldInputDecoration("Change Cattle Stage"),
                  items: (genderInput.text == "Male"
                          ? DropdownListItems.updateMaleCattleStage
                          : DropdownListItems.updateFemaleCattleStage)
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      enabled: false,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),

            //Update Male and Female Animal Cattle Stage
            Visibility(
              visible: button == RadioButton.changeStage &&
                  animalTagNoInput.text.isNotEmpty,
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: DropdownButtonFormField<String>(
                  value: updateCattleStage,
                  onChanged: (String? newValue) {
                    setState(() {
                      updateCattleStage = newValue as String;
                    });
                  },
                  decoration:
                      AppTheme.textFieldInputDecoration("Change Cattle Stage"),
                  items: (genderInput.text == "Male"
                          ? DropdownListItems.updateMaleCattleStage
                          : DropdownListItems.updateFemaleCattleStage)
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),

            //show cattle status
            Visibility(
              visible: animalTagNoInput.text.isNotEmpty &&
                  button == RadioButton.changeStatus &&
                  genderInput.text != "Male",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: DropdownButtonFormField<String>(
                  value: updateCattleStatus,
                  onChanged: null,
                  decoration:
                      AppTheme.textFieldInputDecoration("Change Cattle Stage"),
                  items: DropdownListItems.updateFemaleCattleStatus
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      enabled: false,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),

            //Update Cattle Status For Female Animal
            Visibility(
              visible: button == RadioButton.changeStatus &&
                  genderInput.text != "Male" &&
                  animalTagNoInput.text.isNotEmpty,
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: DropdownButtonFormField<String>(
                  value: updateCattleStatus,
                  onChanged: (String? newValue) {
                    setState(() {
                      updateCattleStatus = newValue as String;
                    });
                  },
                  decoration: AppTheme.textFieldInputDecoration("Change Status"),
                  items: DropdownListItems.updateFemaleCattleStatus
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),

            //Archived Status For Animal DropdownButtonFormField
            Visibility(
              visible: button == RadioButton.archiving &&
                  animalTagNoInput.text.isNotEmpty,
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: DropdownButtonFormField<String>(
                  value: updateArchivedStatus,
                  onChanged: (String? newValue) {
                    setState(() {
                      updateArchivedStatus = newValue as String;
                    });
                  },
                  decoration:
                      AppTheme.textFieldInputDecoration("Reason For Archiving"),
                  items: DropdownListItems.archivedReasonItems
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),

            //Archived Date Calender
            Visibility(
              visible: button == RadioButton.archiving &&
                  updateArchivedStatus!.isNotEmpty &&
                  updateArchivedStatus != "Reason for archived",
              child: Container(
                margin: const EdgeInsets.all(15),
                child: TextFormField(
                  readOnly: true,
                  onTap: () async {
                    DateTime? dateTime =
                        await OmniDateTimePickerUtil.showDateTimePicker(
                            context);
                    if (dateTime != null) {
                      archivedDateInput.text =
                          DateFormat('dd-MMM-yyyy').format(dateTime);
                    }
                  },
                  controller: archivedDateInput,
                  style: AppTheme.textStyleContainer(),
                  decoration:
                      AppTheme.textFieldInputDecoration("Date Of Archived"),
                ),
              ),
            ),

            //Archived Notes
            Visibility(
              visible: button == RadioButton.archiving &&
                  updateArchivedStatus!.isNotEmpty &&
                  updateArchivedStatus != "Reason for archived",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: archivedNoteInput,
                  style: AppTheme.textStyleContainer(),
                  decoration: AppTheme.textFieldInputDecoration("Notes"),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
