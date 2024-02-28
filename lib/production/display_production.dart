import 'package:animal_husbandry/app/bovine.dart';
import 'package:animal_husbandry/production/edit_fattening.dart';
import 'package:animal_husbandry/widget/handleSwipeGesture.dart';
import 'package:flutter/material.dart';
import 'package:animal_husbandry/objectbox/production_Box.dart';
import 'package:animal_husbandry/production/edit_view_production.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:hyper_object_box/model/production.dart';

class DisplayProduction extends StatefulWidget {
  const DisplayProduction({Key? key, required Production production})
      : super(key: key);

  @override
  State<DisplayProduction> createState() => _DisplayProductionState();
}

class _DisplayProductionState extends State<DisplayProduction> {
  final ProductionBox production = ProductionBox();
  List<Production> listMilkList = [];
  List<Production> listFattening = [];
  bool isMilkList = true;

  // Define a threshold to determine if a swipe is considered left or right.
  final double swipeThreshold = 50.0;
  // Variables to track swipe direction and position.
  double swipeStartX = 0.0;
  double swipeEndX = 0.0;

  @override
  Widget build(BuildContext context) {
    final productionBox = objectBox.store.box<Production>();

    listMilkList = production
        .list()
        .where((element) => element.productionType?.trim() == "Milk")
        .toList();
    listFattening = production
        .list()
        .where((element) => element.productionType?.trim() == "Fattening")
        .toList();
    setState(() {});


    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/homeScreen');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text("Records"),
          leading: AppTheme.buildBackIconButton(context, "/homeScreen"),

        ),
        body: GestureDetector(
          onHorizontalDragStart: (details) {
            swipeStartX = details.localPosition.dx;
          },
          onHorizontalDragUpdate: (details) {
            swipeEndX = details.localPosition.dx;
          },
          onHorizontalDragEnd: (details) {
            HandleGesture.handleSwipeGesture(
              swipeStartX,
              swipeEndX,
              swipeThreshold,
              isMilkList,
              (newValue) {
                setState(() {
                  isMilkList = newValue;
                });
              },
            );
          },
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 55,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AppTheme.customRadioButton(
                        title: 'Milk Records',
                        value: isMilkList,
                        onChanged: (bool value) {
                          setState(() {
                            isMilkList = value;
                          });
                        },
                        addIcon: Icons.water_drop,
                      ),
                    ),
                    Expanded(
                      child: AppTheme.customRadioButton(
                        title: 'Fattening',
                        value: !isMilkList,
                        onChanged: (bool value) {
                          setState(() {
                            isMilkList = !value;
                          });
                        },
                        addIcon: Icons.monitor_weight_outlined,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                  child: isMilkList
                      ? ListView.builder(
                          itemCount: listMilkList.length,
                          itemBuilder: (BuildContext ctx, index) {
                            final milkList =
                                listMilkList.reversed.toList()[index];
                            // Display the list item
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(5), // Sharp edges
                                side: const BorderSide(
                                  color: Colors
                                      .blueGrey, // Match MainScreen design
                                  width: 2,
                                ),
                              ),
                              elevation: 5,
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(milkList.id.toString()),
                                ),
                                title: AppTheme.sizedBox(
                                  milkList.milkType.toString() ==
                                          "Individual Milk"
                                      ? "Individual[TagNo:${milkList.cowTagNo}]"
                                      : "${milkList.milkType.toString()}(${milkList.cowsCount.toString()} cows)",
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppTheme.sizedBox(
                                        'Date: ${milkList.dateOfEntry.toString()}'),
                                    AppTheme.sizedBox(
                                        'Total: ${milkList.totalMilk.toString()} Litres'),
                                    AppTheme.sizedBox(
                                        'Used: ${milkList.consumedMilk.toString()}'),
                                    AppTheme.sizedBox(
                                        'Notes: ${milkList.notes.toString()}'),
                                    Visibility(
                                        visible:
                                            milkList.milkType == "Bulk Milk",
                                        child: AppTheme.sizedBox(
                                            'Average: ${milkList.averageMilk.toString()}')),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      // Handle edit action
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditViewMilkDetail(
                                                  production: milkList),
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      /*final cowTagNo =
                                          milkList.cowTagNo.toString();
                                      final cowObId = milkList.id;*/
                                      // await AppTheme.deleteRelatedData(
                                      //     " ", 'production', cowTagNo, 0);
                                      productionBox.remove(milkList.id);
                                      setState(() {});
                                    }
                                  },
                                  itemBuilder: (context) {
                                    return [
                                      const PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Text('Edit/View Record'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ];
                                  },
                                ),
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          itemCount: listFattening.length,
                          itemBuilder: (BuildContext ctx, index) {
                            final weight =
                                listFattening.reversed.toList()[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(5), // Sharp edges
                                side: const BorderSide(
                                  color: Colors
                                      .blueGrey, // Match MainScreen design
                                  width: 2,
                                ),
                              ),
                              elevation: 5,
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(weight.id.toString()),
                                ),
                                title: AppTheme.sizedBox(
                                  'TagNo: ${weight.tagNo.toString()} ',
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppTheme.sizedBox(
                                        'Date: ${weight.weightDate.toString()}'),
                                    AppTheme.sizedBox(
                                        'Weight: ${weight.fattening.toString()} Kg'),
                                    AppTheme.sizedBox(
                                        'Notes: ${weight.notes.toString()}'),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      // Handle edit action
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditFatDetails(
                                              production: weight),
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      productionBox.remove(weight.id);
                                    /*  final tagNo = weight.tagNo.toString();
                                      final cowTagNo =
                                          weight.cowTagNo.toString();*/
                                      // await AppTheme.deleteRelatedData(
                                      //     tagNo, 'production', cowTagNo, 0);
                                      setState(() {});
                                    }
                                  },
                                  itemBuilder: (context) {
                                    return [
                                      const PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Text('Edit/View Record'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ];
                                  },
                                ),
                              ),
                            );
                          },
                        )),
            ],
          ),
        ),
        floatingActionButton: AppTheme.floatingActionButton(
            context, isMilkList ? '/milkEntry' : '/fatteningEntry'),
      ),
    );
  }
}
