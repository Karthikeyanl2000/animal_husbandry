import 'package:animal_husbandry/objectbox/animal_box.dart';
import 'package:animal_husbandry/objectbox/event_box.dart';
import 'package:animal_husbandry/objectbox/production_Box.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:animal_husbandry/widget/dateTimePicker.dart';
import 'package:animal_husbandry/widget/search_container.dart';
import 'package:flutter/material.dart';
import 'package:hyper_object_box/model/exception.dart';
import 'package:hyper_object_box/model/production.dart';
import 'package:intl/intl.dart';

class MilkRecordEntry extends StatefulWidget {
  const MilkRecordEntry({Key? key}) : super(key: key);
  @override
  State<MilkRecordEntry> createState() => MilkRecordEntryState();
}

class MilkRecordEntryState extends State<MilkRecordEntry> {
  final EventBox aiBox = EventBox();
  final AnimalBox animalBox = AnimalBox();
  TextEditingController milkingDateInput = TextEditingController();
  late String selectMilkType = "Select Milk Type";
  int totalCow = 0;
  TextEditingController amMilkInput = TextEditingController();
  TextEditingController noonMilkInput = TextEditingController();
  TextEditingController pmMilkInput = TextEditingController();
  TextEditingController totalMilkInput = TextEditingController();
  TextEditingController numberOfCowInput = TextEditingController();
  TextEditingController consumedMilkInput = TextEditingController();
  TextEditingController wsnInput = TextEditingController();
  TextEditingController avgMilkInput = TextEditingController();
  TextEditingController selectCowTagNo = TextEditingController();
  bool showSuggestions = false;
  String actualTagNo = "";

  void toggleSuggestions() {
    setState(() {
      showSuggestions = !showSuggestions;
    });
  }

  void _updateTotalMilk() {
    try {
      double amTotal = double.tryParse(amMilkInput.text) ?? 0.0;
      double noonTotal = double.tryParse(noonMilkInput.text) ?? 0.0;
      double pmTotal = double.tryParse(pmMilkInput.text) ?? 0.0;

      if (amTotal > 0.0 || noonTotal > 0.0 || pmTotal > 0.0) {
        double totalMilk = amTotal + noonTotal + pmTotal;
        totalMilkInput.text = totalMilk.toString();
      } else {
        totalMilkInput.text = "";
      }
    } catch (e) {
      totalMilkInput.text =
          "";
    }
  }

  @override
  void initState() {
    super.initState();
    _updateTotalMilk();
    DateTime dateTime = DateTime.now();
    milkingDateInput.text = DateFormat("yyyy-MM-dd").format(dateTime);
    numberOfCowInput.text = animalBox.getCowTagNoNumbers().length.toString();
  }

  @override
  Widget build(BuildContext context) {
    List<String> cowNameAndTagNo =
        animalBox.getLactatingCow().whereType<String>().toList();
    DateTime dateTime = DateTime.now();

    actualTagNo = selectCowTagNo.text.split('[').first.trim();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("New Milk Entry"),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              if (selectMilkType == 'Select Milk Type') {
                AppTheme.showSnackBar(context, "Select Milk Type");
              } else if (actualTagNo == "" || actualTagNo.isEmpty) {
                AppTheme.showSnackBar(context, "Select Cow TagNo");
              } else {
                try {
                  ProductionBox productionBox = ProductionBox();
                  var productionList = ProductionBox().list();
                  int tmp = productionList.length;
                  double totalMilk =
                      double.tryParse(totalMilkInput.text) ?? 0.0;
                  double totalCattle =
                      double.tryParse(numberOfCowInput.text) ?? 0.0;
                  double averageMilkPerCattle = totalMilk / totalCattle;
                  String formattedAverageMilk = averageMilkPerCattle
                      .toStringAsFixed(3); // Format to decimal points
                  avgMilkInput.text = formattedAverageMilk;

                  String formattedTotalMilk = totalMilk.toStringAsFixed(2);

                  print("Count ==> $tmp");

                  Production production = Production(
                      productionType: "Milk",
                      dateOfEntry: milkingDateInput.text,
                      amTotal: amMilkInput.text,
                      noonTotal: noonMilkInput.text,
                      pmTotal: pmMilkInput.text,
                      totalMilk: formattedTotalMilk.toString(),
                      consumedMilk: consumedMilkInput.text,
                      notes: wsnInput.text);
                  if (selectMilkType == "Select Milk Type") {
                    production.milkType = "";
                  } else {
                    production.milkType = selectMilkType;
                  }

                  if (actualTagNo.toString().isNotEmpty &&
                      selectMilkType != "Bulk Milk") {
                    production.cowTagNo = actualTagNo.toString();
                  }
                  if (selectMilkType != "Individual Milk") {
                    production.cowsCount = numberOfCowInput.text;

                    production.averageMilk = avgMilkInput.text;
                  }
                  productionBox.create(production.toJson());
                  print("Count ==> ${productionBox.list().length}");
                } catch (e) {
                  print(e.toString());
                } finally {
                  Navigator.of(context).popAndPushNamed("/displayMilk");
                  AppTheme.showSnackBar(context, "Registered Successfully");
                }
              }
            },
            child: const Icon(
              Icons.save_as_outlined,
              size: 40,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Milking Date
            Container(
              margin: const EdgeInsets.all(15),
              child: TextFormField(
                readOnly: true,
                onTap: () async {
                  DateTime? dateTime =
                      await OmniDateTimePickerUtil.showDateTimePicker(context);
                  if (dateTime != null) {
                    milkingDateInput.text =
                        DateFormat('yyyy-MM-dd').format(dateTime);
                  }
                },
                controller: milkingDateInput,
                style: AppTheme.textStyleContainer(),
                decoration: AppTheme.textFieldInputDecoration("Milking Date"),
              ),
            ),

            //Select   Milk Type
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: DropdownButtonFormField<String>(
                value: selectMilkType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectCowTagNo.text;
                    _updateTotalMilk();
                    selectMilkType = newValue as String;
                    amMilkInput.text = '';
                    pmMilkInput.text = '';
                    noonMilkInput.text = '';
                    totalMilkInput.text = '';
                    consumedMilkInput.text = '';
                    wsnInput.text = '';
                  });
                },
                decoration:
                    AppTheme.textFieldInputDecoration("Select Milk Type"),
                items: <String>[
                  'Select Milk Type',
                  'Individual Milk',
                  'Bulk Milk',
                  ''
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            //Search and Select Cow
            Visibility(
              visible: selectMilkType == "Individual Milk",
              child: SearchContainer(
                controller: selectCowTagNo,
                suggestionList: cowNameAndTagNo,
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    selectCowTagNo.text = suggestion;
                    showSuggestions = false;
                    _updateTotalMilk();
                  });
                },
                decoration: AppTheme.textFieldInputDecoration(
                  'Select Cow',
                ),
                // onPressedCallback: toggleSuggestions,
                showSuggestions: showSuggestions,
              ),
            ),

            Visibility(
              visible: selectMilkType == "Individual Milk" &&
                  animalBox.getLactatingCow().whereType<String>().isEmpty,
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 15, bottom: 15),
                alignment: Alignment.centerLeft,
                child: const Text(
                  "No Cows Found in your cattle's list",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),

            //AM Milk Count
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                controller: amMilkInput,
                style: AppTheme.textStyleContainer(),
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  setState(() {
                    _updateTotalMilk();
                  });
                },
                decoration: AppTheme.textFieldInputDecoration("AM Total"),
              ),
            ),

            //Noon Milk count
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                controller: noonMilkInput,
                style: AppTheme.textStyleContainer(),
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  setState(() {
                    _updateTotalMilk();
                  });
                },
                decoration: AppTheme.textFieldInputDecoration("Noon Total"),
              ),
            ),

            //Pm milk count
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                controller: pmMilkInput,
                style: AppTheme.textStyleContainer(),
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  setState(() {
                    _updateTotalMilk();
                  });
                },
                decoration: AppTheme.textFieldInputDecoration("PM Total"),
              ),
            ),

            //Total Milk count
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                controller: totalMilkInput,
                style: AppTheme.textStyleContainer(),
                onChanged: (value) {
                  setState(() {
                    totalMilkInput.text = value.toString();
                  });
                  final textSelection = TextSelection.collapsed(
                      offset: totalMilkInput.text.length);
                  totalMilkInput.selection = textSelection;
                },
                keyboardType: TextInputType.number,
                decoration:
                    AppTheme.textFieldInputDecoration("Total Milk Produced"),
              ),
            ),

            //Consumed Milk
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                controller: consumedMilkInput,
                style: AppTheme.textStyleContainer(),
                decoration: AppTheme.textFieldInputDecoration(
                    "Total Used(calves/consumed)"),
              ),
            ),

            //Number of cows Milked
            Visibility(
              visible: selectMilkType == "Bulk Milk",
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: numberOfCowInput,
                  style: AppTheme.textStyleContainer(),
                  onChanged: (value) {
                    setState(() {
                      numberOfCowInput.text = value.toString();
                    });
                    final textSelection = TextSelection.collapsed(
                        offset: numberOfCowInput.text.length);
                    numberOfCowInput.selection = textSelection;
                  },
                  keyboardType: TextInputType.number,
                  decoration:
                      AppTheme.textFieldInputDecoration("Number of Cows"),
                ),
              ),
            ),

            //Write Some Notes
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: TextFormField(
                controller: wsnInput,
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
