import 'package:animal_husbandry/objectbox/animal_box.dart';
import 'package:animal_husbandry/objectbox/event_box.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:animal_husbandry/widget/dateTimePicker.dart';
import 'package:animal_husbandry/widget/search_container.dart';
import 'package:flutter/material.dart';
import 'package:hyper_object_box/model/animal.dart';
import 'package:hyper_object_box/model/production.dart';
import 'package:intl/intl.dart';
import '../objectbox/production_Box.dart';

class EditFatDetails extends StatefulWidget {
  final Production production;
  const EditFatDetails({Key? key, required this.production}) : super(key: key);

  @override
  State<EditFatDetails> createState() => _EditFatDetailsState();
}

class _EditFatDetailsState extends State<EditFatDetails> {
  final EventBox aiBox = EventBox();
  final AnimalBox animalBox = AnimalBox();
  TextEditingController tagNoInput = TextEditingController();
  TextEditingController weightDateInput = TextEditingController();
  TextEditingController wsnInput = TextEditingController();
  TextEditingController fatteningInput = TextEditingController();
  TextEditingController productionType = TextEditingController();
  int showid = 0;
  bool showSuggestions = false;

  void toggleSuggestions() {
    setState(() {
      showSuggestions = !showSuggestions;
    });
  }

  @override
  void initState() {
    super.initState();
    productionType.text = widget.production.productionType.toString();
    tagNoInput.text = widget.production.tagNo.toString();
    weightDateInput.text = widget.production.weightDate.toString();
    wsnInput.text = widget.production.notes.toString();
    showid = int.tryParse(widget.production.id.toString())!;
    fatteningInput.text = widget.production.fattening.toString();
  }

  @override
  Widget build(BuildContext context) {
    List<String> animalList = animalBox
        .getFilterTagNumbersFromObjectBox()
        .whereType<String>()
        .toList();
    DateTime dateTime = DateTime.now();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text("Edit/View Milk Details"),
          actions: [
            GestureDetector(
              onTap: () {
                try {
                  ProductionBox productionBox = ProductionBox();
                  var productionList = ProductionBox().list();
                  int tmp = productionList.length;
                  print("Count ==> $tmp");
                  String actualTagNo = tagNoInput.text.split('[').first.trim();

                  if (actualTagNo!.isNotEmpty) {
                    Animal? existingAnimal =
                        AppTheme.getAnimalByTagNo(actualTagNo.toString());

                    if (existingAnimal != null &&
                        fatteningInput.text!.isNotEmpty) {
                      existingAnimal.weight =
                          double.tryParse(fatteningInput.text);
                      animalBox.create(existingAnimal.toJson());
                    }
                  }

                  Production production = Production(
                      id: showid,
                      tagNo: actualTagNo.toString(),
                      notes: wsnInput.text,
                      fattening: fatteningInput.text,
                      weightDate: weightDateInput.text,
                      productionType: productionType.text);
                  productionBox.create(production.toJson());
                  print("Count ==> ${productionBox.list().length}");
                } catch (e) {
                } finally {
                  Navigator.of(context).popAndPushNamed("/displayMilk");
                  AppTheme.showSnackBar(context, "Successfully Updated");
                }
              },
              child: const Icon(
                Icons.save,
                size: 30,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SearchContainer(
                controller: tagNoInput,
                suggestionList: animalList,
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    tagNoInput.text = suggestion;
                    showSuggestions = false;
                    fatteningInput.text = animalBox.getPropertyForTagNo(
                            tagNoInput.text, "weight") ??
                        '';
                  });
                },

                decoration: AppTheme.textFieldInputDecoration('Select Animal'),
                showSuggestions: showSuggestions,
              ),

              //Milking Date
              Container(
                margin: const EdgeInsets.all(15),
                child: TextFormField(
                  readOnly: true,
                  onTap: () async {
                    DateTime? dateTime =
                        await OmniDateTimePickerUtil.showDateTimePicker(
                            context);
                    if (dateTime != null) {
                      weightDateInput.text =
                          DateFormat('yyyy-MM-dd').format(dateTime);
                    }
                  },
                  controller: weightDateInput,
                  style: AppTheme.textStyleContainer(),
                  decoration:
                      AppTheme.textFieldInputDecoration("weight Checking Date"),
                ),
              ),

              Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: fatteningInput,
                  style: AppTheme.textStyleContainer(),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      fatteningInput.text = value.toString();
                    });
                    final textSelection = TextSelection.collapsed(
                        offset: fatteningInput.text.length);
                    fatteningInput.selection = textSelection;
                  },
                  decoration: AppTheme.textFieldInputDecoration("Weight"),
                ),
              ),

              Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: wsnInput,
                  style: AppTheme.textStyleContainer(),
                  onChanged: (value) {
                    setState(() {
                      wsnInput.text = value.toString();
                    });
                  },
                  decoration: AppTheme.textFieldInputDecoration("Notes"),
                ),
              ),
            ],
          ),
        ));
  }
}
