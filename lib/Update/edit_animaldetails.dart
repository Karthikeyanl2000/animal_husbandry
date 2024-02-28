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

class EditAnimalDetails extends StatefulWidget {
  final Animal animal;
  const EditAnimalDetails({Key? key, required this.animal}) : super(key: key);
  @override
  State<EditAnimalDetails> createState() => _EditAnimalDetailsState();
}

class _EditAnimalDetailsState extends State<EditAnimalDetails> {
  late final Animal animal;

  TextEditingController updateTagInput = TextEditingController();
  TextEditingController updateName = TextEditingController();
  TextEditingController updateWeight = TextEditingController();
  TextEditingController updateDateOfBirth = TextEditingController();
  TextEditingController updateDateOfEntry = TextEditingController();
  String? updateCattleGrp;
  TextEditingController updateMotherTagNo = TextEditingController();
  TextEditingController updateFatherTagNo = TextEditingController();
  TextEditingController updateNotes = TextEditingController();
  String? updateCattleStage = "";
  String? updateBreed;
  String? updateGender;
  String? updateSource;
  String? imageString;
  // get obid Value
  int showobid = 0;
  final AnimalBox animalBox = AnimalBox();
  bool showSuggestions = false;
  List<String> breedItems = [];
  String? updateAnimalCategory;

  @override
  void initState() {
    super.initState();
    updateTagInput.text = widget.animal.tagNo.toString();
    updateName.text = widget.animal.name.toString();
    updateWeight.text = widget.animal.weight.toString();
    updateDateOfBirth.text = widget.animal.dob.toString();
    updateDateOfEntry.text = widget.animal.doe.toString();
    updateCattleGrp = widget.animal.group.toString();
    updateMotherTagNo.text = widget.animal.motherTagNo.toString();
    updateFatherTagNo.text = widget.animal.fatherTagNo.toString();
    updateNotes.text = widget.animal.notes.toString();
    //DropdownButtonFormField Values
    updateBreed = widget.animal.animalBread;
    updateGender = widget.animal.gender;
    updateSource = widget.animal.soa;
    showobid = widget.animal.obid;
    //update cattle stage based on male or female
    if (updateGender == "Male") {
      updateCattleStage = widget.animal.cattlestage.toString();
    } else if (updateGender == "Female") {
      updateCattleStage = widget.animal.cattlestage.toString();
    }
    imageString = widget.animal.image.toString();

    updateAnimalCategory = widget.animal.animalCategory.toString();
    updateCategory(updateAnimalCategory);
  }

  void updateCategory(animalCategory) {
    if (updateAnimalCategory == "Indigenous") {
      breedItems = DropdownListItems.indigenousBreedItems;
    } else if (updateAnimalCategory == "Exotic Cross") {
      breedItems = DropdownListItems.exoticBreedItems;
    } else if (updateAnimalCategory == "Buffaloes") {
      breedItems = DropdownListItems
          .buffaloBreedItems; // Reset breed items if category is not selected
    } else {
      breedItems == [];
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime? dateTime = DateTime.now();
    String formattedDate = DateFormat("yyyy-MM-dd").format(dateTime);
    List<String> cowNames = animalBox.getCowName().whereType<String>().toList();
    void handleImagePick(ImageSource source) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final pickedImage = File(pickedFile.path);
        final compressedImage = await FlutterImageCompress.compressWithFile(
          pickedImage.path,
          minWidth:
              300, // Adjust the width and height as needed for compression.
          minHeight: 300,
        );
        Uint8List? imageBytes = compressedImage;
        //  imageString = base64.encode(imageBytes!); // Assign the base64 encoded image data to the imageString variable
        // Uint8List imageBytes = await pickedImage.readAsBytes();
        imageString = base64.encode(
            imageBytes!); // Assign the base64 encoded image data to the imageString variable
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Edit Animal Details'),
        centerTitle: true,
        leading: AppTheme.buildBackIconButton(context, "/viewAnimalEntry"),
        actions: [
          GestureDetector(
            onTap: () async {
              if (updateAnimalCategory == "Select Category" ||
                  updateAnimalCategory == null) {
                AppTheme.showSnackBar(context, "Select Category");
              } else if (updateBreed == "Select Breed" || updateBreed == null) {
                AppTheme.showSnackBar(context, "Select Breed");
              } else {
                try {
                  AnimalBox animalBox = AnimalBox();
                  var animalList = AnimalBox().list();
                  int tmp = animalList.length;

                  print("Count ==> $tmp");

                  Animal animal = Animal(
                      obid: showobid,
                      tagNo: updateTagInput.text,
                      animalBread: updateBreed,
                      name: updateName.text,
                      gender: updateGender,
                      cattlestage: updateCattleStage,
                      weight: double.tryParse((updateWeight.text.trim().isEmpty)
                          ? "0"
                          : updateWeight.text),
                      dob: updateDateOfBirth.text,
                      doe: updateDateOfEntry.text,
                      group: updateCattleGrp,
                      soa: updateSource,
                      motherTagNo: updateMotherTagNo.text,
                      fatherTagNo: updateFatherTagNo.text,
                      notes: updateNotes.text,
                      image: imageString.toString(),
                      animalCategory: updateAnimalCategory.toString());

                  animalBox.create(animal.toJson());

                  print("Count ==> ${animalBox.list().length}");
                } catch (ex) {
                  print(ex.toString());
                } finally {
                  Navigator.of(context).popAndPushNamed("/viewAnimalEntry");
                  AppTheme.showSnackBar(
                      context, "Cattle Updated Successfully!");
                  final jsonData =
                      await ImportAndExport.exportDataToJson(context);
                  await ImportAndExport.writeJsonToFile(jsonData);
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
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: DropdownButtonFormField<String>(
                value: updateAnimalCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    updateAnimalCategory = newValue as String;
                    updateCategory(updateAnimalCategory);
                    updateBreed = "Select Breed";
                  });
                },
                decoration: AppTheme.textFieldInputDecoration("Select Breed"),
                items: DropdownListItems.animalCategoryItems
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            //Animal Breed TextFormField
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: DropdownButtonFormField<String>(
                value: updateBreed,
                onChanged: (String? newValue) {
                  setState(() {
                    updateBreed = newValue as String;
                  });
                },
                decoration: AppTheme.textFieldInputDecoration("Select Breed"),
                items: breedItems.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            // Animal Name TextFormField //
            Container(
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              child: TextFormField(
                controller: updateName,
                style: AppTheme.textStyleContainer(),
                onChanged: (value) {
                  setState(() {
                    updateName.text = value.toString();
                  });
                  final textSelection =
                      TextSelection.collapsed(offset: updateName.text.length);
                  updateName.selection = textSelection;
                },
                decoration: AppTheme.textFieldInputDecoration("Name"),
              ),
            ),

            //Animal TagNo  TextForm Field //
            Container(
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              child: TextFormField(
                controller: updateTagInput,
                style: AppTheme.textStyleContainer(),
                onChanged: (value) {
                  setState(() {
                    updateTagInput.text = value.toString();
                  });
                  final textSelection = TextSelection.collapsed(
                      offset: updateTagInput.text.length);
                  updateTagInput.selection = textSelection;
                },
                decoration: AppTheme.textFieldInputDecoration("Tag No"),
              ),
            ),

            //select Gender Dropdown-list //
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: DropdownButtonFormField<String>(
                value: updateGender,
                onChanged: (String? newValue) {
                  setState(() {
                    updateGender = newValue as String;
                    updateCattleStage = "Select Cattle Stage";
                  });
                },
                decoration: AppTheme.textFieldInputDecoration("Select Gender"),
                items: DropdownListItems.genderItems
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            //select Gender after show the DropdownButtonFormField
            Visibility(
              visible: updateGender == "Male" || updateGender == "Female",
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
                      AppTheme.textFieldInputDecoration("Select Cattle Stage"),
                  items: (updateGender == "Male"
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

            //Weight of the animal TextForm Field //
            Container(
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              child: TextFormField(
                  controller: updateWeight,
                  style: AppTheme.textStyleContainer(),
                  onChanged: (value) {
                    setState(() {
                      updateWeight.text = value.toString();
                    });
                    final textSelection = TextSelection.collapsed(
                        offset: updateWeight.text.length);
                    updateWeight.selection = textSelection;
                  },
                  keyboardType:
                      TextInputType.number, // Set the keyboardType to number
                  decoration: AppTheme.textFieldInputDecoration("Weight")),
            ),

            //Date Of Birth TextField//
            Container(
              margin: const EdgeInsets.all(15),
              child: TextFormField(
                readOnly: true,
                onTap: () async {
                  DateTime? dateTime =
                      await OmniDateTimePickerUtil.showDateTimePicker(context);
                  if (dateTime != null) {
                    updateDateOfBirth.text =
                        DateFormat('yyyy-MM-dd').format(dateTime);
                  }
                },
                controller: updateDateOfBirth,
                style: AppTheme.textStyleContainer(),
                onChanged: (value) {
                  setState(() {
                    updateDateOfBirth.text = value.toString();
                  });
                },
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
                    updateDateOfEntry.text =
                        DateFormat('yyyy-MM-dd').format(dateTime);
                  }
                },
                controller: updateDateOfEntry,
                style: AppTheme.textStyleContainer(),
                onChanged: (value) {
                  setState(() {
                    updateDateOfEntry.text = value.toString();
                  });
                },
                decoration: AppTheme.textFieldInputDecoration(
                    "Date of Entry On The Farm"),
              ),
            ),

            //Cattle group
            Container(
              margin: const EdgeInsets.all(15),
              child: DropdownButtonFormField<String>(
                value: updateCattleGrp,
                onChanged: (String? newValue) {
                  setState(() {
                    updateCattleGrp = newValue;
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
                value: updateSource,
                onChanged: (String? newValue) {
                  setState(() {
                    updateSource = newValue as String;
                  });
                },
                decoration: AppTheme.textFieldInputDecoration(
                    "Select How Cattle Was Obtained"),
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
              controller: updateMotherTagNo,
              suggestionList: cowNames,
              onSuggestionSelected: (suggestion) {
                setState(() {
                  updateMotherTagNo.text = suggestion;
                  updateMotherTagNo.text = suggestion;
                  showSuggestions = false;
                });
              },
              decoration: AppTheme.textFieldInputDecoration(
                'Mother Tag No',
              ),
              // onPressedCallback: toggleSuggestions,
              showSuggestions: showSuggestions,
            ),

            // Fathers Tag No TextField
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                controller: updateFatherTagNo,
                style: AppTheme.textStyleContainer(),
                onChanged: (value) {
                  setState(() {
                    updateFatherTagNo.text = value.toString();
                  });
                  final textSelection = TextSelection.collapsed(
                      offset: updateFatherTagNo.text.length);
                  updateFatherTagNo.selection = textSelection;
                },
                decoration:
                    AppTheme.textFieldInputDecoration("Father's Tag No"),
              ),
            ),

            //Write some notes Textformfield //
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                controller: updateNotes,
                style: AppTheme.textStyleContainer(),
                onChanged: (value) {
                  setState(() {
                    updateNotes.text = value.toString();
                  });
                  final textSelection =
                      TextSelection.collapsed(offset: updateNotes.text.length);
                  updateNotes.selection = textSelection;
                },
                decoration:
                    AppTheme.textFieldInputDecoration("Write Some Notes"),
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
