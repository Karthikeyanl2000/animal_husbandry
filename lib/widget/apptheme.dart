import 'dart:convert';

import 'package:animal_husbandry/app/bovine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyper_object_box/model/ai.dart';
import 'package:hyper_object_box/model/animal.dart';
import 'package:hyper_object_box/model/production.dart';
import 'package:hyper_object_box/objectbox.g.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AppTheme {

  static InputDecoration textFieldInputDecoration(String data) {
    return InputDecoration(
      focusColor: Colors.white,
      //add prefix icon
      prefixIcon: const Icon(
        Icons.person_outline_rounded,
        color: Colors.grey,
      ),
      hintText: data,
      labelText: data,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),

      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue, width: 1.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      fillColor: Colors.grey,
      //make hint text
      hintStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 16,
        fontFamily: "verdana_regular",
        fontWeight: FontWeight.w400,
      ),

      //label style
      labelStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 16,
        fontFamily: "verdana_regular",
        fontWeight: FontWeight.w400,
      ),
    );
  }


  static void showSnackBar(BuildContext context, String message) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Padding buildListTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 140, // Adjust the width as needed
            child: Text(
              '$title :',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15, // Adjust the font size as needed
                color: Colors.black, // Customize the text color
              ),
            ),
          ),
          const SizedBox(width: 0), // Adjust the spacing as needed
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15, // Adjust the font size as needed
                color: Colors.green, // Customize the text color
              ),
            ),
          ),
        ],
      ),
    );
  }

//Floating Button For Add New Animal and New Events Entries
  static FloatingActionButton floatingActionButton(BuildContext context,
      String routeName) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).popAndPushNamed(routeName);
      },
      backgroundColor: Colors.green,
      child: const Icon(Icons.add),
    );
  }

  static Widget buildCountContainer(String text, int count) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      // color: Colors.amberAccent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
          Text(
            count.toString(),
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
        ],
      ),
    );
  }

  static Widget buildList(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      // color: Colors.amberAccent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
        ],
      ),
    );
  }

  static Widget buildEventCard(BuildContext context, String heading, padding) {
    return Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Text(
              heading,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ]));
  }

  static Animal? getAnimalByTagNo(String tagNo) {
    final animalBox = objectBox.store.box<Animal>();
    final animalQuery = animalBox.query(Animal_.tagNo.equals(tagNo)).build();
    final animalList = animalQuery.find();
    animalQuery.close();
    if (animalList.isNotEmpty) {
      return animalList.first;
    } else {
      return null;
    }
  }

  static void showDialogBox(BuildContext context,
      String message,
      String warning,
      VoidCallback onDeleteConfirmed,) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              warning,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.start,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                overlayColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.green.withOpacity(
                          0.2); // Custom overlay color when pressed
                    }
                    return Colors.transparent;
                  },
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: const BorderSide(
                        color: Colors.green), // Custom border color
                  ),
                ),
              ),
              child: const Text(
                "No",
              ),
            ),
            TextButton(
              onPressed: () {
                onDeleteConfirmed();
                Navigator.pop(context); // Close the dialog
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                overlayColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.red.withOpacity(
                          0.2); // Custom overlay color when pressed
                    }
                    return Colors.transparent;
                  },
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: const BorderSide(
                        color: Colors.red), // Custom border color
                  ),
                ),
              ),
              child: const Text(
                "Yes",
              ),
            ),
          ],
        );
      },
    );
  }

  //custom Radio Button
  static Widget customRadioButton({
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged,
    required IconData addIcon,
  }) {
    final isSelected = value;
    return InkWell(
      onTap: () => onChanged?.call(!value),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [Colors.green.shade500, Colors.green.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : const LinearGradient(
            colors: [Colors.white60, Colors.white60],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            0.0, // Left padding
            10.0, // Top padding
            0.0, // Right padding
            10.0, // Bottom padding (increase this value)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              // Display the icon based on the selected value
              Icon(
                addIcon,
                color: isSelected ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget sizedBox(String text) {
    return SizedBox(
      height: 20,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  static Widget expandedText(String text, Color color) {
    return Expanded(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  static Widget staticCard(String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            subtitle: Text(subtitle),
          ),
        ],
      ),
    );
  }

  static Widget messageCard(String message) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: ListTile(
        title: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.red, // Change color as needed
          ),
        ),
      ),
    );
  }

  //This TextStyle For TextFormField Container
  static TextStyle textStyleContainer() {
    return const TextStyle(
      fontSize: 20,
      color: Colors.blue,
      fontWeight: FontWeight.w600,
    );
  }

  static IconButton buildBackIconButton(BuildContext context,
      String routeName) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {

        Navigator.pushReplacementNamed(context, routeName);
      },
    );
  }

  static InputDecoration logInFormDecoration(String text) {
    return InputDecoration(
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white),
      ),
      hintText: text,
      hintStyle: const TextStyle(color: Colors.white),
    );
  }


  static Padding buildListTiles(String title,
      String value,
      BoxConstraints constraints,
      double titleWidthPercentage,
      TextStyle titleTextStyle,
      TextStyle valueTextStyle,) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: titleWidthPercentage * constraints.maxWidth,
            child: Text(
              '$title :',
              style: titleTextStyle,
            ),
          ),
          const SizedBox(width: 8), // Adjust spacing as needed
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.justify,
              style: valueTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  //View and Share PDF Options
  static Future<void> showPdfOptions(BuildContext context, String filePath,
      String fileName) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('View PDF'),
              onTap: () async {
                // Close the bottom sheet
                Navigator.pop(context);
                // Show the PDF using OpenFile
                await OpenFile.open(filePath);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share PDF'),
              onTap: () async {
                // Close the bottom sheet
                Navigator.pop(context);
                // Share the PDF using Share.shareFiles
                await Share.shareFiles([filePath], text: fileName);
              },
            ),
          ],
        );
      },
    );
  }

  static Expanded rowExpanded(String text, TextAlign textAlign, Color color,
      BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: MediaQuery
              .of(context)
              .size
              .width * 0.03,
          color: color,
        ),
      ),
    );
  }

  static void alertDialog(BuildContext context, TextEditingController controller, String text) {
    showDialog(
        context: context, // Replace with your context
        builder: (BuildContext context)
    {
      return AlertDialog(
        title: Center(
          child: Text(text),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller, // Add controller
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: text, // Customize label text
              ),
            ),
            const SizedBox(height: 20), // Adjust spacing as needed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle cancel button click
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    String newValue = controller.text;
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      );
    }
    );
  }

  static const String baseUrl = 'https://fgts-animal.onrender.com';
 // static const String baseUrl = 'http://192.168.1.2:5798';

}