import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:animal_husbandry/import_export_data/import_export.dart';
import 'package:animal_husbandry/objectbox/animal_box.dart';
import 'package:animal_husbandry/objectbox/production_Box.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:animal_husbandry/widget/dateTimePicker.dart';
import 'package:animal_husbandry/widget/dropdown_ListItems.dart';
import 'package:animal_husbandry/widget/search_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hyper_object_box/model/animal.dart';
import 'package:hyper_object_box/model/production.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AnimalNewEntry extends StatefulWidget {
  const AnimalNewEntry({
    Key? key,
  }) : super(key: key);

  @override
  State<AnimalNewEntry> createState() => _AnimalNewEntryState();
}

class _AnimalNewEntryState extends State<AnimalNewEntry> {
  late final Animal? animal;

  TextEditingController nameInput = TextEditingController();
  TextEditingController tagInput = TextEditingController();
  TextEditingController weightInput = TextEditingController();
  TextEditingController dateOfBirthInput = TextEditingController();
  TextEditingController dateOfEntryInput = TextEditingController();
  TextEditingController motherInput = TextEditingController();
  TextEditingController fatherInput = TextEditingController();
  TextEditingController wsnInput = TextEditingController();
  TextEditingController motherTagNoInput = TextEditingController();

  final AnimalBox animalBox = AnimalBox();
  String? animalCategory;
  String? breedValue;
  String? genderValue;
  String? sourceValue;
  String? cattleStage;
  String? selectedMotherTag;
  bool showSuggestions = false;
  String? cattleGrpCtrl;
  String? imageString;
  List<String> breedItems = [];

  @override
  Widget build(BuildContext context) {
    List<String> cowNames = animalBox.getCowName().whereType<String>().toList();
    DateTime? dateTime = DateTime.now();
    String formattedDate = DateFormat("yyyy-MM-dd").format(dateTime);

    Animal? existingAnimal = AppTheme.getAnimalByTagNo(tagInput.text);
    bool existTagNo = existingAnimal?.tagNo! == tagInput.text;
    void handleImagePick(ImageSource source) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final pickedImage = File(pickedFile.path);
        final compressedImage = await FlutterImageCompress.compressWithFile(
          pickedImage.path,
          minWidth:
              250, // Adjust the width,height and quality as needed for compression.
          minHeight: 250,
          quality: 60,
        );
        Uint8List? imageBytes = compressedImage;
        imageString = base64.encode(
            imageBytes!); // Assign the base64 encoded image data to the imageString variable
      }
    }

    void updateBreedItems(String? animalCategory) {
      if (animalCategory == "Indigenous") {
        breedItems = DropdownListItems.indigenousBreedItems;
      } else if (animalCategory == "Exotic Cross") {
        breedItems = DropdownListItems.exoticBreedItems;
      } else if (animalCategory == "Buffaloes"){
        breedItems =  DropdownListItems.buffaloBreedItems; // Reset breed items if category is not selected
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Animal New Entry'),
        centerTitle: true,
        leading: AppTheme.buildBackIconButton(context, "/viewAnimalEntry"),
        actions: [
          GestureDetector(
            onTap: () async {
              if (tagInput.text.isEmpty) {
                AppTheme.showSnackBar(context, "Enter Tag No");
              } else if (genderValue == null) {
                AppTheme.showSnackBar(context, "Select Gender");
              } else if (cattleGrpCtrl == null) {
                AppTheme.showSnackBar(context, "Select Cattle Group");
              } else if(animalCategory == "Select Category" || animalCategory == null){
                AppTheme.showSnackBar(context, "Select Category");
              }
              else if(breedValue == "Select Breed" || breedValue == null){
                AppTheme.showSnackBar(context, "Select Breed");
              }
              else {
                if (!existTagNo) {
                  try {
                    if (weightInput.text.isNotEmpty) {
                      ProductionBox productionBox = ProductionBox();
                      Production production = Production(
                        weightDate: formattedDate,
                        fattening: weightInput.text,
                        productionType: 'Fattening',
                        tagNo: tagInput.text,
                      );
                      productionBox.create(production.toJson());
                    }
                    AnimalBox animalBox = AnimalBox();
                    var animalList = AnimalBox().list();
                    int tmp = animalList.length;
                    print("Count ==> $tmp");
                    String motherTagNo =
                        motherTagNoInput.text.split('[').first.trim();
                    Animal animal = Animal(
                      tagNo: tagInput.text,
                      animalBread: breedValue,
                      name: nameInput.text,
                      gender: genderValue,
                      cattlestage: cattleStage,
                      weight: double.tryParse(
                        (weightInput.text.trim().isEmpty)
                            ? "0"
                            : weightInput.text,
                      ),
                      dob: dateOfBirthInput.text,
                      doe: dateOfEntryInput.text,
                      group: cattleGrpCtrl,
                      soa: sourceValue,
                      motherTagNo: motherTagNo.toString(),
                      fatherTagNo: fatherInput.text,
                      notes: wsnInput.text,
                      image: imageString ?? "",
                      animalCategory: animalCategory.toString()
                    );
                    animalBox.create(animal.toJson());

                    print("Count ==> ${animalBox.list().length}");
                  } catch (e) {
                  } finally {
                    Navigator.of(context).popAndPushNamed("/viewAnimalEntry");
                    AppTheme.showSnackBar(context, "Successfully Registered");
                    final jsonData =
                        await ImportAndExport.exportDataToJson(context);
                    await ImportAndExport.writeJsonToFile(jsonData);
                  }
                } else {
                  AppTheme.showSnackBar(context, "Tag number already exists.");
                }
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

            //Animal Category
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: DropdownButtonFormField<String>(
                value: animalCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    animalCategory = newValue as String;
                    updateBreedItems(animalCategory);
                  });
                },
                decoration: AppTheme.textFieldInputDecoration("Select Category"),
                items:
                DropdownListItems.animalCategoryItems
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            //Animal Breed TextFormField

            Visibility(
              visible: animalCategory != null && animalCategory != "Select Category",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: DropdownButtonFormField<String>(
                  value: breedValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      breedValue = newValue as String;
                    });
                  },
                  decoration: AppTheme.textFieldInputDecoration("Select Breed"),
                  items:breedItems.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
              );
              }).toList(), // Use appropriate list for other categories
                ),
              ),
            ),
            // Animal Name TextFormField //
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                controller: nameInput,
                style: AppTheme.textStyleContainer(),
                decoration: AppTheme.textFieldInputDecoration("Name"),
              ),
            ),
            //Animal TagNo  TextForm Field //
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: tagInput,
                    style: AppTheme.textStyleContainer(),
                    onChanged: (String? newValue) {
                      setState(() {
                        tagInput.text = newValue as String;
                      });
                      final textSelection =
                          TextSelection.collapsed(offset: tagInput.text.length);
                      tagInput.selection = textSelection;
                    },
                    decoration: AppTheme.textFieldInputDecoration("Tag No."),
                  ),
                  if (existTagNo)
                    const Text(
                      "Tag No. already exists.Please enter a unique tag number.!",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),

            //select Gender Dropdown-list //
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: DropdownButtonFormField<String>(
                value: genderValue,
                onChanged: (String? newValue) {
                  setState(() {
                    genderValue = newValue as String;
                  });
                },
                decoration: AppTheme.textFieldInputDecoration("Gender"),
                items: DropdownListItems.genderItems
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            //If you select Male Value in Gender show the DropdownButtonFormField
            Visibility(
              visible: genderValue == "Male" || genderValue == "Female",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: DropdownButtonFormField<String>(
                  value: cattleStage,
                  onChanged: (String? newValue) {
                    setState(() {
                      cattleStage = newValue as String;
                    });
                  },
                  decoration: AppTheme.textFieldInputDecoration(
                      "Select Cattle Stage ${genderValue.toString()}"),
                  items: (genderValue == "Male"
                          ? DropdownListItems.maleItems
                          : DropdownListItems.femaleItems)
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                controller: weightInput,
                style: AppTheme.textStyleContainer(),
                onChanged: (value) {
                  setState(() {
                    weightInput.text = value.toString();
                  });
                  final textSelection =
                      TextSelection.collapsed(offset: weightInput.text.length);
                  weightInput.selection = textSelection;
                },
                keyboardType: TextInputType.number,
                // Set the keyboardType to number
                decoration: AppTheme.textFieldInputDecoration("Weight"),
              ),
            ),

            //Date Of Birth TextField
            Container(
              margin: const EdgeInsets.all(15),
              child: TextFormField(
                readOnly: true,
                onTap: () async {
                  DateTime? dateTime =
                      await OmniDateTimePickerUtil.showDateTimePicker(context);
                  if (dateTime != null) {
                    dateOfBirthInput.text =
                        DateFormat('yyyy-MM-dd').format(dateTime);
                  }
                },
                controller: dateOfBirthInput,
                style: AppTheme.textStyleContainer(),
                decoration: AppTheme.textFieldInputDecoration("Date Of Birth"),
              ),
            ),

            //Date Of Entry on the farm //
            Container(
              margin: const EdgeInsets.all(15),
              child: TextFormField(
                readOnly: true,
                onTap: () async {
                  DateTime? dateTime =
                      await OmniDateTimePickerUtil.showDateTimePicker(context);
                  if (dateTime != null) {
                    dateOfEntryInput.text =
                        DateFormat('yyyy-MM-dd').format(dateTime);
                  }
                },
                controller: dateOfEntryInput,
                style: AppTheme.textStyleContainer(),
                decoration: AppTheme.textFieldInputDecoration("Date Of Entry"),
              ),
            ),

            //Cattle group
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: DropdownButtonFormField<String>(
                value: cattleGrpCtrl,
                onChanged: (String? newValue) {
                  setState(() {
                    cattleGrpCtrl = newValue;
                  });
                },
                decoration:
                    AppTheme.textFieldInputDecoration("Select Cattle Group"),
                items: DropdownListItems.cattleGroupItems
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            //Select how cattle was obtained //
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: DropdownButtonFormField<String>(
                value: sourceValue,
                onChanged: (String? newValue) {
                  setState(() {
                    sourceValue = newValue as String;
                  });
                },
                decoration: AppTheme.textFieldInputDecoration(
                    "Select how cattle was obtained.*"),
                items: DropdownListItems.sourceOfCattle
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            // Mother Tag No TextFormField
            SearchContainer(
              controller: motherTagNoInput,
              suggestionList: cowNames,
              onSuggestionSelected: (suggestion) {
                setState(() {
                  motherTagNoInput.text = suggestion;
                  selectedMotherTag = suggestion;
                  showSuggestions = false;
                });
              },
              decoration: AppTheme.textFieldInputDecoration('Mother Tag No'),
              // onPressedCallback: toggleSuggestions,
              showSuggestions: showSuggestions,
            ),

            // Fathers Tag No TextField
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                controller: fatherInput,
                style: AppTheme.textStyleContainer(),
                decoration: AppTheme.textFieldInputDecoration("Father Tag No."),
              ),
            ),

            //Write some notes TextFormField
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                controller: wsnInput,
                style: AppTheme.textStyleContainer(),
                decoration:
                    AppTheme.textFieldInputDecoration("Write some notes"),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: Center(
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the icons horizontally
                  children: [
                    Tooltip(
                      message: 'Take a Photo', // Tooltip for the camera icon
                      child: InkWell(
                        onTap: () {
                          handleImagePick(ImageSource
                              .camera); // Open the camera to capture an image
                        },
                        child: const Icon(
                          Icons.camera_alt,
                          size: 40, // Adjust the icon size as needed
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20), // Add spacing between the icons
                    Tooltip(
                      message:
                          'Choose Image from Gallery', // Tooltip for the gallery icon
                      child: InkWell(
                        onTap: () {
                          handleImagePick(ImageSource
                              .gallery); // Open the image picker when tapped
                        },
                        child: const Icon(
                          Icons.photo_library,
                          size: 40, // Adjust the icon size as needed
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
