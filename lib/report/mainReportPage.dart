import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:flutter/material.dart';

class MainReportScreen extends StatelessWidget {
  const MainReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Reports'),
        leading: AppTheme.buildBackIconButton(context, "/homeScreen"),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacementNamed(context, '/homeScreen');
          return true;
        },
        child: Container(
          margin: const EdgeInsets.all(25),
          child: GridView.count(
            crossAxisCount: 2, // Two columns
            crossAxisSpacing: 20.0,
            mainAxisSpacing: 20.0,
            children: [
              createReportCard(
                "Cattle's Report",
                '/cattleReport',
                "assets/images/cows.png",
                Colors.white54,
                context,
              ),
              createReportCard("Individual Report", 'individualReports',
                  "assets/images/ccow.png", Colors.white54, context),
              createReportCard("Mass Report", '/massReport',
                  "assets/images/mass.png", Colors.white54, context),
              createReportCard(
                "Insemination Report",
                '/insReport',
                "assets/images/insemination.png",
                Colors.white54,
                context,
              ),
              createReportCard(
                "Treatment Report",
                '/treatmentReport',
                "assets/images/cow_virus.png",
                Colors.white54,
                context,
              ),
              createReportCard(
                "Vaccination Report",
                '/vaccineReport',
                "assets/images/medical.png",
                Colors.white54,
                context,
              ),
              createReportCard(
                'Pregnancy Report',
                '/aiReport',
                "assets/images/pregnant.png",
                Colors.white54,
                context,
              ),
              createReportCard(
                  "Weight Report",
                  '/weightReport',
                  "assets/images/weighing-machine.png",
                  Colors.white54,
                  context),
              createReportCard("Milk Report", '/milkReport',
                  "assets/images/milk1.png", Colors.white54, context),
              createReportCard("Notification", '/report',
                  "assets/images/task.png", Colors.white54, context),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector createReportCard(String title, String routeName, String image,
      Color color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(routeName);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white38,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.blueGrey, // Set your desired border color
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    image,
                    width: 64,
                    height: 64,
                  ),
                  const SizedBox(height: 10), // Spacer between image and text
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
