// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'package:animal_husbandry/app/bovine.dart';
import 'package:animal_husbandry/objectbox/animal_box.dart';
import 'package:animal_husbandry/objectbox/event_box.dart';
import 'package:animal_husbandry/objectbox/paymentBox.dart';
import 'package:animal_husbandry/objectbox/production_Box.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:hyper_object_box/model/ai.dart';
import 'package:hyper_object_box/model/animal.dart';
import 'package:hyper_object_box/model/payment.dart';
import 'package:hyper_object_box/model/production.dart';
import 'package:intl/intl.dart';
 import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ImportAndExport {
  final animalData = objectBox.store.box<Animal>();

  final paymentData = objectBox.store.box<Payment>();
  String mobileNumber = "";

 // Export Method For AnimalsDetails , EventDetails and ProductionDetails in Device Storage
  static Future<void> writeJsonToFile(

      List<Map<String, dynamic>> allData) async {
    try {
      String formattedDate = DateFormat('yyyy_MM_dd_hh_mm').format(DateTime.now());
      final directory = await getExternalStorageDirectory();
      final file = File('${directory!.path}/Animal_Husbandry_$formattedDate.json');
      await file.writeAsString(jsonEncode(allData));
    } catch (e) {
      print(e.toString());
    }
  }

///Static Method For Export Data to SQL Server
  static Future<List<Map<String, dynamic>>> exportDataToJson(BuildContext context) async {

    final animalBox = AnimalBox();
    final animals = animalBox.list();

    final aiBox = EventBox();
    final events = aiBox.list();

    final productionBox = ProductionBox();
    final production = productionBox.list();

    final paymentBox = PaymentBox();
    final payment = paymentBox.list();

    final jsonAnimals = animals.map((animal) => animal.toJson()).toList();
    final jsonEvents = events.map((event) => event.toJson()).toList();
    final jsonProduction = production.map((production) => production.toJson()).toList();
    final jsonPayment = payment.map((payment) => payment.toJson()).toList();

     ///Export to SQL SERVER
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    if (savedUsername != null) {
      try {
        final response = await http.post(
          Uri.parse('${AppTheme.baseUrl}/export_sync'), // Assuming '/sync' is the correct endpoint
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'mobileNumber': savedUsername,
            'animalData': jsonAnimals,
            'eventData': jsonEvents,
            'productionData': jsonProduction,
            'paymentData': jsonPayment
          }),
        );
        if (response.statusCode == 200) {
         AppTheme.showSnackBar(context, "Data Exported Successfully");
        } else {
          print('HTTP Error: ${response.statusCode}, ${response.body}');
          AppTheme.showSnackBar(context, "Data Not Exported!");
        }
      } catch (error) {
        print('Export Data to Database: $error');
      }
    }
    final allData = [...jsonAnimals, ...jsonEvents, ...jsonProduction, ...jsonPayment];
   return allData;
  }

   // Import Data Details
  static Future<void> importData(BuildContext context) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.isNotEmpty) {
        //Remove the existing records
        objectBox.store.box<AI>().removeAll();
        objectBox.store.box<Production>().removeAll();

        final File file = File(result.files.single.path!);
        final String fileContent = await file.readAsString();
        final jsonData = jsonDecode(fileContent) as List<dynamic>;

        final AnimalBox animalBox = AnimalBox();
        final ProductionBox productionBox = ProductionBox();
        final EventBox aiBox = EventBox();
        final PaymentBox paymentBox = PaymentBox();

        for (var jsonItem in jsonData) {
          if (jsonItem.containsKey('animalBread')) {
            final animalData = jsonItem as Map<String, Object?>;
            //await Future.delayed(const Duration(seconds: 5));
            animalBox.import(animalData);
          }

          if (jsonItem.containsKey('dateOfEvent')) {
            final eventData = jsonItem as Map<String, Object?>;
            aiBox.import(eventData);
          }

          if (jsonItem.containsKey('productionType')) {
            final productionData = jsonItem as Map<String, Object?>;
            final productionType = productionData['productionType'] as String?;

            if (productionType == 'Milk') {
              productionData['productionType'] = 'Milk';
              productionBox.import(productionData);
            } else if (productionType == 'Fattening') {
              productionData['productionType'] = 'Fattening';
              productionBox.import(productionData);
            }
          }

          if (jsonItem.containsKey('paymentId')) {
            final paymentData = jsonItem as Map<String, Object?>;
            paymentBox.import(paymentData);
          }
        }
        AppTheme.showSnackBar(context, "Imported Successfully");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> importSyncData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    if (savedUsername != null) {
      try {
        final response = await http.get(Uri.parse('${AppTheme.baseUrl}/import_sync?mobileNumber=$savedUsername'));

        if (response.statusCode == 200) {
          objectBox.store.box<AI>().removeAll();
          objectBox.store.box<Production>().removeAll();
          final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

          final AnimalBox animalBox = AnimalBox();
          final ProductionBox productionBox = ProductionBox();
          final EventBox eventBox = EventBox();
          final PaymentBox paymentBox = PaymentBox();

          if (jsonData.containsKey('animalData')) {
            final animalData = jsonData['animalData'] as List<dynamic>;
            for (var jsonItem in animalData) {
              animalBox.import(jsonItem as Map<String, dynamic>);
            }
          }

          if (jsonData.containsKey('eventData')) {
            final eventData = jsonData['eventData'] as List<dynamic>;
            final eventDataList = eventData.map((jsonItem) => jsonItem as Map<String, Object?>).toList();
            for (var eventDataItem in eventDataList) {
              eventBox.import(eventDataItem);
            }
          }

          if (jsonData.containsKey('productionData')) {
            final productionData = jsonData['productionData'] as List<dynamic>;
            for (var jsonItem in productionData) {
              final productionType = jsonItem['productionType'] as String?;
              if (productionType == 'Milk') {
                productionBox.import(jsonItem as Map<String, dynamic>);
              } else if (productionType == 'Fattening') {
                productionBox.import(jsonItem as Map<String, dynamic>);
              }
            }
          }

          if(jsonData.containsKey('paymentData')) {
            final paymentData = jsonData['paymentData'] as List<dynamic>;
            for (var jsonItem in paymentData) {
              paymentBox.import(jsonItem as Map<String, dynamic>);
            }
          }

          AppTheme.showSnackBar(context, "Data Imported Successfully");
        } else {
          AppTheme.showSnackBar(context, "No Data Found!");
          print('Failed to fetch sync data: ${response.statusCode}');
        }
      } catch (e) {
        print('Error importing sync data: $e');
      }
    }
  }
}
