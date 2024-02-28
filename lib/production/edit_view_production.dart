import 'package:animal_husbandry/objectbox/animal_box.dart';
import 'package:animal_husbandry/objectbox/event_box.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:animal_husbandry/widget/dateTimePicker.dart';
import 'package:animal_husbandry/widget/search_container.dart';
import 'package:flutter/material.dart';
import 'package:hyper_object_box/model/production.dart';
import 'package:intl/intl.dart';
import '../objectbox/production_Box.dart';

class EditViewMilkDetail extends StatefulWidget {
  final Production production;
 const EditViewMilkDetail({Key? key, required this.production}) : super(key: key);

  @override
  State<EditViewMilkDetail> createState() => _EditMilkDetailState();
}

class _EditMilkDetailState extends State<EditViewMilkDetail>{
  final EventBox aiBox = EventBox();
  final AnimalBox animalBox = AnimalBox();
  TextEditingController milkingDateInput = TextEditingController();
  TextEditingController selectMilkType = TextEditingController();
TextEditingController selectCowTagNo = TextEditingController();
  TextEditingController amMilkInput = TextEditingController();
  TextEditingController noonMilkInput = TextEditingController();
  TextEditingController pmMilkInput = TextEditingController();
  TextEditingController totalMilkInput = TextEditingController();
  TextEditingController numberOfCowInput = TextEditingController();
  TextEditingController consumedMilkInput = TextEditingController();
  TextEditingController wsnInput = TextEditingController();
  TextEditingController avgMilkInput = TextEditingController();
  TextEditingController productionTypeInput = TextEditingController();
  bool showSuggestions = true;
  void toggleSuggestions() {
    setState(() {
      showSuggestions = !showSuggestions;
    });
  }


  int showid=0;
  @override
  void initState() {
    super.initState();
    selectMilkType.text = widget.production.milkType.toString();
    selectCowTagNo.text = widget.production.cowTagNo.toString();
    milkingDateInput.text = widget.production.dateOfEntry.toString();
    amMilkInput.text = widget.production.amTotal.toString();
    noonMilkInput.text = widget.production.noonTotal.toString();
    pmMilkInput.text = widget.production.pmTotal.toString();
    totalMilkInput.text = widget.production.totalMilk.toString();
    numberOfCowInput.text = widget.production.cowsCount.toString();
    consumedMilkInput.text = widget.production.consumedMilk.toString();
    wsnInput.text = widget.production.notes.toString();
    showid = int.parse(widget.production.id.toString());
    productionTypeInput.text = widget.production.productionType.toString();
    updateTotalMilk();
     double  totalMilks = double.tryParse(totalMilkInput.text) ?? 0.0;
    double totalCattle = double.tryParse(numberOfCowInput.text) ?? 0.0;
    double averageMilkPerCattle = totalMilks / totalCattle;
    avgMilkInput.text = averageMilkPerCattle.toString();
  }

  void updateTotalMilk() {
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
      totalMilkInput.text = "";
    }
  }

  @override
  void dispose() {
    numberOfCowInput.dispose(); // Dispose the controller when not needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> cowNameAndTagNo =
    animalBox.getLactatingCow().whereType<String>().toList();
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
                double totalMilk = double.tryParse(totalMilkInput.text )?? 0.0;
                String formattedTotalMilk = totalMilk.toStringAsFixed(2);
                print("Count ==> $tmp");
                String actualTagNo =selectCowTagNo.text.split('[').first.trim();
                Production production = Production(
                    id: showid,
                    dateOfEntry: milkingDateInput.text,
                    milkType: selectMilkType.text,
                    amTotal: amMilkInput.text,
                    noonTotal: noonMilkInput.text,
                    pmTotal: pmMilkInput.text,
                    totalMilk: formattedTotalMilk.toString(),
                    consumedMilk: consumedMilkInput.text,
                    notes: wsnInput.text,
                productionType: productionTypeInput.text);
                if(actualTagNo.toString()!.isNotEmpty && selectMilkType.text != "Bulk Milk"){
                  production.cowTagNo= actualTagNo.toString();
                }
                if(selectMilkType.text != "Individual Milk"){
                  production.cowsCount = numberOfCowInput.text;
                  production.averageMilk = avgMilkInput.text;
                }

                productionBox.create(production.toJson());
                print("Count ==> ${productionBox.list().length}");
              } catch (e) {
                print(e);
              } finally {
                Navigator.of(context).popAndPushNamed("/displayMilk");
                AppTheme.showSnackBar(context, "Successfully Updated");
              }
            },
            child: const Icon(
              Icons. check_box,
              size: 30,
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
                    DateTime? dateTime = await OmniDateTimePickerUtil.showDateTimePicker(context);
                    if (dateTime != null) {
                      milkingDateInput.text = DateFormat('yyyy-MM-dd').format(dateTime);
                    }
                  },
                  controller: milkingDateInput,
                  style: AppTheme.textStyleContainer(),
                  decoration: AppTheme.textFieldInputDecoration("Milking Date"),
                ),
              ),
              //select   milk type
              Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: selectMilkType,
                  style: AppTheme.textStyleContainer(),
                  keyboardType:
                  TextInputType.number,
                  onChanged: (_) {
                    setState(() {
                      updateTotalMilk();
                    });
                  },
                  decoration: AppTheme.textFieldInputDecoration("Milk Type"),
                ),
              ),

              //Search and Select Cow
              Visibility(
                visible: selectMilkType.text == "Individual Milk",
                child: SearchContainer(
                  controller: selectCowTagNo,
                  suggestionList: cowNameAndTagNo,
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      selectCowTagNo.text = suggestion;
                      showSuggestions = false;
                      updateTotalMilk();
                    });
                  },

                  decoration: AppTheme.textFieldInputDecoration('Select Cow',),
                  // onPressedCallback: toggleSuggestions,
                  showSuggestions: showSuggestions,
                ),
              ),


              //Am Milk Input
              Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: amMilkInput,
                  style: AppTheme.textStyleContainer(),
                  keyboardType:
                  TextInputType.number,
                  onChanged: (_) {
                    setState(() {
                      updateTotalMilk();
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
                  keyboardType:
                  TextInputType.number,
                  onChanged: (_) {
                    setState(() {
                      updateTotalMilk();
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
                  keyboardType:
                  TextInputType.number,
                  onChanged: (_) {
                    setState(() {
                      updateTotalMilk();
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
                  keyboardType:
                  TextInputType.number,
                  onChanged: (_) {
                    setState(() {
                      updateTotalMilk();
                    });
                  },
                  decoration: AppTheme.textFieldInputDecoration("Total Milk Produced"),
                ),
              ),

              //Consumed Milk
              Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: consumedMilkInput,
                  style: AppTheme.textStyleContainer(),
                  keyboardType: TextInputType.number,
                  decoration: AppTheme.textFieldInputDecoration("Total Used(calves/consumed)"),
                ),
              ),

              //Number of cows Milked
              Visibility(visible: selectMilkType.text == "Bulk Milk",
                child:
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                  child: TextFormField(
                    controller: numberOfCowInput,
                    style: AppTheme.textStyleContainer(),
                    onChanged: (value) {
                      setState(() {
                        numberOfCowInput.text = value.toString();
                        double totalMilk = double.tryParse(totalMilkInput.text) ?? 0.0;
                        double totalCows = double.tryParse(numberOfCowInput.text) ?? 0.0;
                        double averageMilkPerCattle = totalMilk / totalCows;
                        avgMilkInput.text = averageMilkPerCattle.toString();
                      });
                      final textSelection = TextSelection.collapsed(offset: numberOfCowInput.text.length);
                      numberOfCowInput.selection = textSelection;
                    },

                    keyboardType:
                    TextInputType.number,
                    decoration: AppTheme.textFieldInputDecoration("Number of Cows"),
                  ),
                ),
              ),
              //Write Some Notes
              Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: TextFormField(
                  controller: wsnInput,
                  style: AppTheme.textStyleContainer(),
                  decoration: AppTheme.textFieldInputDecoration("Write Some Notes"),
                ),
              ),
            ]
        ),
      ),

    );
  }

}