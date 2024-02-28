import 'package:animal_husbandry/objectbox/animal_box.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:animal_husbandry/widget/pdfGenerator.dart';
import 'package:flutter/material.dart';

class CattleReport extends StatefulWidget{
  const CattleReport({super.key});
  @override State<CattleReport> createState() => _CattleReportState();

}

class _CattleReportState extends State<CattleReport> {
  final AnimalBox animal = AnimalBox();
  int totalCattle = 0;// Replace this with the actual value of total cattle
  int totalCattleStage =0;
  int cowCount = 0;
  int heiferCount = 0;
  int bullCount = 0;
  int steerCount = 0;
  int weanerCount =0;
  int calfCount =0;
  int weanerFemaleCount =0;
  int calfFemaleCount= 0;
  int pregnantCount =0;
  int lactatingCount =0;
  int lactatePregnant =0;
  int nonLactating =0;
  bool showOtherContainers = true;
  bool showStageContainers = true;


  @override
  void initState() {
    super.initState();

    // final animalBox = objectbox.store.box<Animal>();
    // final List<Animal> listAnimal = animalBox.getAll();

   totalCattle = animal.getFilterTagNumbersFromObjectBox().length;

     cowCount = animal.getCountByCriteria('Cow');
     heiferCount = animal.getCountByCriteria('Heifer');
    bullCount = animal.getCountByCriteria('Bull');
    steerCount = animal.getCountByCriteria('Steer');
   weanerCount = animal.getCountByCriteria('Weaner');
   weanerFemaleCount = animal.getCountByCriteria("WeanerFemale");
    calfCount = animal.getCountByCriteria('Calf');
   calfFemaleCount = animal.getCountByCriteria('CalfFemale');
   totalCattleStage =animal.getCountByCriteria('Total');
   pregnantCount = animal.getCountByCriteria('Pregnant');
    lactatingCount = animal.getCountByCriteria('Lactating');
    lactatePregnant = animal.getCountByCriteria('Lactating&Pregnant');
    nonLactating= animal.getCountByCriteria('Non Lactating');
  }

  void toggleCattleVisibility() {
    setState(() {
      showOtherContainers = !showOtherContainers;
    });
  }
  void toggleCattleStageVisibility() {
    setState(() {
      showStageContainers = !showStageContainers;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Cattle Report'),
        actions: [
          IconButton(
              onPressed: () async {
                String pdfName = "Cattle's_Report"; // Define your PDF file name here

                // Extract the relevant data from filterList
                final List<String> columnValues = [
                  'Total Cattle',
                  'Cows',
                  'Heifers',
                  'Bulls',
                  'Steers',
                  'Male Weaners',
                  'Female Weaners',
                  'Male Calves',
                  'Female Calves',
                ];

                final List<List<String>> tableRows = [
                  [
                    totalCattle.toString(),
                    cowCount.toString(),
                    heiferCount.toString(),
                    bullCount.toString(),
                    steerCount.toString(),
                    weanerCount.toString(),
                    weanerFemaleCount.toString(),
                    calfCount.toString(),
                    calfFemaleCount.toString(),
                  ],
                ];

                // Generate and save the PDF
                await GeneratePDF.generateAndSavePdf(
                  "Animal Husbandry",
                  columnValues,
                  tableRows,
                  pdfName,
                  context,
                );

                // final filteredAnimals =
                // filterList(); // Get the filtered list of animals
                // generateAndSavePdf(filteredAnimals);
              },
              icon: const Icon(Icons.picture_as_pdf)),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: toggleCattleVisibility,
              child: Container(
                padding: const EdgeInsets.all(16.0), // Apply padding here only for Total Cattle
                color: Colors.blueGrey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   const Text(
                      'Total Cattle',
                      style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      totalCattle.toString(),
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            if (showOtherContainers) ...[
           AppTheme.buildCountContainer('Cow', cowCount),
              AppTheme.buildCountContainer('Heifers', heiferCount),
              AppTheme.buildCountContainer('Bulls', bullCount),
              AppTheme.buildCountContainer('Steers', steerCount),
              AppTheme.buildCountContainer('Male Weaners', weanerCount),
              AppTheme.buildCountContainer('Female Weaners', weanerFemaleCount),
              AppTheme.buildCountContainer('Male Calves', calfCount),
              AppTheme.buildCountContainer('Female Calves', calfFemaleCount),
            ],

            //Container For Cattle Status
               GestureDetector(
               onTap: toggleCattleStageVisibility,
                 child: Container(
                   padding: const EdgeInsets.all(16.0), // Apply padding here only for Total Cattle
                   color: Colors.blueGrey,
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text(
                         'Female Cattle by Status',
                         style: TextStyle(color: Colors.black, fontSize: 18 ,fontWeight: FontWeight.bold),
                       ),
                       Text(
                         totalCattleStage.toString(),
                         style: const TextStyle(color: Colors.black, fontSize: 18),
                       ),
                     ],
                   ),
                 ),
               ),
            if (showStageContainers) ...[
              AppTheme. buildCountContainer('Pregnant', pregnantCount),
              AppTheme. buildCountContainer('Lactating', lactatingCount),
              AppTheme. buildCountContainer('Lactating&Pregnant', lactatePregnant),
              AppTheme. buildCountContainer('Non Lactating', nonLactating),
            ],
          ],
        ),
      ),
    );
  }
}


