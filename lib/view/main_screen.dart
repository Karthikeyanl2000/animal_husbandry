// ignore_for_file: use_build_context_synchronously
import 'package:animal_husbandry/app/bovine.dart';
import 'package:animal_husbandry/import_export_data/import_export.dart';
import 'package:animal_husbandry/view/login.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyper_object_box/model/ai.dart';
import 'package:hyper_object_box/model/animal.dart';
import 'package:hyper_object_box/model/payment.dart';
import 'package:hyper_object_box/model/production.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatelessWidget {
  MainScreen({Key? key}) : super(key: key);
  final animalBox = objectBox.store.box<Animal>();
  final aiBox = objectBox.store.box<AI>();
  final productionBox = objectBox.store.box<Production>();
  final paymentBox = objectBox.store.box<Payment>();

  // void logout(BuildContext context) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   ImportAndExport.exportDataToJson(context);
  //    objectBox.store.box<Animal>().removeAll();
  //   objectBox.store.box<AI>().removeAll();
  //   objectBox.store.box<Production>().removeAll();
  //   objectBox.store.box<Payment>().removeAll();
  //   prefs.remove('username'); // Remove the saved username
  //   Navigator.of(context).pushReplacement(MaterialPageRoute(
  //     builder: (context) => const Login(),
  //   ));
  // }

  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    /// Export Method For Export Data into Database
    await ImportAndExport.exportDataToJson(context);
    showClearDataAlertDialog(
      context,
          () async {
        animalBox.removeAll();
        aiBox.removeAll();
        productionBox.removeAll();
        paymentBox.removeAll();
        await prefs.remove('username');
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const Login(),
        ));
      },
      "Before logout, please export your data because logout after data will be deleted. After login, it will be easy to sync your data.",
    );
  }


/*
  // Future<void> logout(BuildContext context) async{
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final mobileNumber = prefs.getString('username');
  //
  //   final url = Uri.parse('${AppTheme.baseUrl}/logout');
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Content-Type':'application/json',
  //     },
  //     body: jsonEncode ({
  //       'mobileNumber':mobileNumber,
  //     }),
  //   );
  //   if(response.statusCode == 200){
  //     prefs.remove('username');
  //     Navigator.of(context).pushReplacement(MaterialPageRoute(
  //       builder: (context) => const Login(),
  //     ));
  //   }
  //   else{
  //   AppTheme.showSnackBar(context, 'Logout failed');
  //   }
  // }
*/


 static void showClearDataAlertDialog(BuildContext context, Function onConfirm , String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Import"),
          content:  Text(
            message
             ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.green),),
            ),
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
              child: const Text("OK", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: GestureDetector(
          child: const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/cow_boy.png'),
          ),
        ),
        title: const Center(child: Text("Animal Husbandry")),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'import') {
                showClearDataAlertDialog(context, () async {
                  await ImportAndExport.importData(context);
                }, "If you stop the import process in the middle, your event and production data will be cleared. Are you sure you want to proceed?");
              } else if (value == 'export') {
                final jsonData =
                    await ImportAndExport.exportDataToJson(context);
                await ImportAndExport.writeJsonToFile(jsonData);
                AppTheme.showSnackBar(context, "Exported Successfully");
              } else if (value == 'logout') {
                logout(context);
              } else if (value == 'settings') {
                Navigator.pushNamed(context, '/cattleSettings');
              } else if (value == 'exportSync') {
                await ImportAndExport.exportDataToJson(context);
              } else if (value == 'importSync') {
                showClearDataAlertDialog(context, () async {
                  await ImportAndExport.exportDataToJson(context);
                  await ImportAndExport.importSyncData(context);
                },  "If you stop the import process in the middle, your event and production data will be cleared. Are you sure you want to proceed?");
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'import',
                  child: ListTile(
                    leading: Icon(Icons.file_upload),
                    title: Text('Import'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'export',
                  child: ListTile(
                    leading: Icon(Icons.file_download),
                    title: Text('Export'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'importSync',
                  child: ListTile(
                    leading: Icon(Icons.sync),
                    title: Text('Import Sync Data'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'exportSync',
                  child: ListTile(
                    leading: Icon(Icons.sync_outlined),
                    title: Text('Export Sync Data'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Notification Settings'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Log Out'),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
      SystemNavigator.pop();
      return true;
    },
    child:
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Add this line
                    children: [
                      _buildImageBox(
                        context,
                        "assets/images/cow.png",
                        "Cattle",
                        "/viewAnimalEntry",
                      ),
                      const SizedBox(width: 20), // Add some space between boxes
                      _buildImageBox(
                        context,
                        "assets/images/planner.png",
                        "Events",
                        "/viewEventEntry",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Add this line
                    children: [
                      _buildImageBox(
                        context,
                        "assets/images/process.png",
                        "Stage",
                        "/changeAnimalStage",
                      ),

                      const SizedBox(width: 20), // Add some space between boxes
                      _buildImageBox(
                        context,
                        "assets/images/milk-box.png",
                        "Production",
                        "/displayMilk",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Add this line
                    children: [
                      _buildImageBox(
                        context,
                        "assets/images/report.png",
                        "Reports",
                        "/mainReport",
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween, // Add this line
                        children: [
                          _buildImageBox(
                            context,
                            "assets/images/benefits.png",
                            "Subscription",
                            'paymentScreen',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildImageBox(
      BuildContext context, String image, String text, String routeName) {
    var appWidth = MediaQuery.of(context).size.width;
    var appHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(routeName);
        },
        child: HighlightedImageBox(
          image: image,
          boxHeight: appHeight * 0.25,
          boxWidth: appWidth * 0.4,
          text: text,
        ));
  }
}

class HighlightedImageBox extends StatelessWidget {
  final String image;
  final double boxHeight;
  final double boxWidth;
  final String text;

  const HighlightedImageBox({
    super.key,
    required this.image,
    required this.boxHeight,
    required this.boxWidth,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white54,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.blueGrey,
          width: 2,
        ),
      ),
      height: boxHeight,
      width: boxWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            width: 100,
            height: 115,
            fit: BoxFit.contain,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
