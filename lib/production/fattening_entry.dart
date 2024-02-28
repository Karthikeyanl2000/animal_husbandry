import 'package:animal_husbandry/objectbox/animal_box.dart';
import 'package:animal_husbandry/objectbox/event_box.dart';
import 'package:animal_husbandry/objectbox/production_Box.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:animal_husbandry/widget/dateTimePicker.dart';
import 'package:animal_husbandry/widget/search_container.dart';
import 'package:flutter/material.dart';
import 'package:hyper_object_box/model/animal.dart';
import 'package:hyper_object_box/model/production.dart';
import 'package:intl/intl.dart';


class FatteningEntry extends StatefulWidget {
  final Animal animal;
  const FatteningEntry({Key? key, required this.animal}) : super(key: key);

  @override
  State<FatteningEntry> createState() => _FatteningState();
}

class _FatteningState extends State<FatteningEntry> {
  TextEditingController selectCattle = TextEditingController();
  String? productionType;
  final EventBox aiBox = EventBox();
  final AnimalBox animalBox = AnimalBox();
  final ProductionBox productionBox = ProductionBox();
  TextEditingController fatteningInput = TextEditingController();
  TextEditingController wsnInput = TextEditingController();
  TextEditingController dateOfEntryInput = TextEditingController();
  TextEditingController currentWeightInput = TextEditingController();
  TextEditingController updateFatteningInput = TextEditingController();
  bool showSuggestions = false;

  void toggleSuggestions() {
    setState(() {
      showSuggestions = !showSuggestions;
    });
  }


  @override
  void initState() {
    super.initState();
    DateTime dateTime = DateTime.now();
    dateOfEntryInput.text = DateFormat("yyyy-MM-dd").format(dateTime);
  }

  @override
  Widget build(BuildContext context) {

    String actualTagNo = selectCattle.text.split('[').first.trim();

    List<Production> lastWeightResult = (productionBox
            .list()
            .where((element) =>
                element.productionType == "Fattening" &&
                element.tagNo == actualTagNo.toString())
            .toList()
          ..sort((a, b) {
            DateFormat formatter = DateFormat("yyyy-MM-dd");
            DateTime aTime = formatter.parse(a.weightDate!);
            DateTime bTime = formatter.parse(b.weightDate!);
            return aTime.compareTo(bTime);
          }))
        .cast<Production>();

    List<String> animalList = animalBox
        .getFilterTagNumbersFromObjectBox()
        .whereType<String>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Fattening Entry"),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              if(actualTagNo.isEmpty ){
                AppTheme.showSnackBar(context, "Select Tag No");
              }
              else if(updateFatteningInput.text.isEmpty){
                AppTheme.showSnackBar(context, "Enter Weight");
              }
              else {
                try {
                  ProductionBox productionBox = ProductionBox();
                  var productionList = ProductionBox().list();
                  int tmp = productionList.length;
                  print("Count ==> $tmp");
                  if (actualTagNo.isNotEmpty) {
                    Animal? existingAnimal =
                    AppTheme.getAnimalByTagNo(actualTagNo.toString());
                    if (existingAnimal != null &&
                        updateFatteningInput.text.isNotEmpty) {
                      existingAnimal.weight =
                          double.tryParse(updateFatteningInput.text);
                      animalBox.create(existingAnimal.toJson());
                    }
                  }
                  Production production = Production(
                    productionType: "Fattening",
                    tagNo: actualTagNo.toString(),
                    weightDate: dateOfEntryInput.text,
                    fattening: updateFatteningInput.text,
                    notes: wsnInput.text,
                  );
                  productionBox.create(production.toJson());
                  print("Count ==> ${productionBox
                      .list()
                      .length}");
                } catch (e) {
                  print(e.toString());
                } finally {
                  Navigator.of(context).popAndPushNamed("/displayMilk");
                  AppTheme.showSnackBar(context, "Successfully Registered");
                }
              }
            },

            child: const Icon(
              Icons.save_as_outlined,
              size: 30,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            //Search And Select Cattle
            SearchContainer(
              controller: selectCattle,
              suggestionList: animalList,
              onSuggestionSelected: (suggestion) {
                if (lastWeightResult.length >= 2) {
                  List<Production> lastTwoWeightRecords =
                  lastWeightResult.sublist(lastWeightResult.length - 2);
                  fatteningInput.text = lastTwoWeightRecords.last.fattening!;
                } else if (lastWeightResult.length == 1) {
                  fatteningInput.text = (lastWeightResult.last.fattening) ??
                      double.tryParse(
                          animalBox.getPropertyForTagNo(selectCattle.text, "weight") ?? '')?.toString() ?? '';
                } else {
                  fatteningInput.text =
                      double.tryParse(animalBox.getPropertyForTagNo(selectCattle.text, "weight") ?? '')?.toString() ?? '';
                }
                updateFatteningInput.text = fatteningInput.text;
              },
               decoration: AppTheme.textFieldInputDecoration('Select Animal',),
              // onPressedCallback: toggleSuggestions,
              showSuggestions: showSuggestions,
            ),


            //Weight Checking Date
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
                decoration:
                    AppTheme.textFieldInputDecoration("Weight Checking Date"),
              ),
            ),


            //Current Weight
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                  controller: fatteningInput,
                  readOnly: true,
                  style: AppTheme.textStyleContainer(),
                  onChanged: null,
                  decoration:
                      AppTheme.textFieldInputDecoration("Current Weight")),
            ),

            //  Change Weight
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                  controller: updateFatteningInput,
                  style: AppTheme.textStyleContainer(),
                  onChanged: (value) {
                    setState(() {
                      updateFatteningInput.text = value.toString();
                    });
                    final textSelection = TextSelection.collapsed(
                        offset: updateFatteningInput.text.length);
                    updateFatteningInput.selection = textSelection;
                  },
                  keyboardType:
                      TextInputType.number, // Set the keyboardType to number
                  decoration:
                      AppTheme.textFieldInputDecoration("Weight Result")),
            ),

            //Write Some Notes
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                controller: wsnInput,
                style: AppTheme.textStyleContainer(),
                decoration:
                    AppTheme.textFieldInputDecoration("Write some notes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
