import 'package:animal_husbandry/app/bovine.dart';
import 'package:animal_husbandry/objectbox/event_box.dart';
import 'package:flutter/material.dart';
import 'package:animal_husbandry/objectbox/animal_box.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:animal_husbandry/widget/dropdown_ListItems.dart';
import 'package:hyper_object_box/model/ai.dart';
import 'package:hyper_object_box/model/animal.dart';

class MassReportHistory extends StatefulWidget {
  const MassReportHistory({Key? key}) : super(key: key);

  @override
  State<MassReportHistory> createState() => _MassReportHistoryState();
}


class _MassReportHistoryState extends State<MassReportHistory> {
  final AnimalBox animalBox = AnimalBox();
  final animal = objectBox.store.box<Animal>();
  final eventBox = objectBox.store.box<AI>();
  final EventBox aiBox = EventBox();
  String? selectMassEvent;
  String? selectCattleGroup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Mass Report'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: DropdownButtonFormField<String>(
                value: selectCattleGroup,
                onChanged: (String? newValue) {
                  setState(() {
                    selectCattleGroup = newValue;
                  });
                },
                decoration:
                AppTheme.textFieldInputDecoration("Select Cattle Group"),
                items: DropdownListItems.massEventItems
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: DropdownButtonFormField<String>(
                value: selectMassEvent,
                onChanged: (String? newValue) {
                  setState(() {
                    selectMassEvent = newValue;
                  });
                },
                decoration:
                AppTheme.textFieldInputDecoration("Select Event Type"),
                items: DropdownListItems.eventTypeMassItems
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            if (selectMassEvent?.isNotEmpty == true &&
                selectCattleGroup?.isNotEmpty == true)
              ..._buildMassReportContent()
            else
              AppTheme.staticCard('Mass History', 'No Mass History Found!'),
          ],
        ),
      ),
    );
  }

  List<String>getMatchingTagNumberByGroup(List<String> list,
      String cattleGroup) {
    List<String> matchingTagNumbers = [];
    final animalsList = animal.getAll();

    for (var animal in animalsList) {
      if (animal.group == cattleGroup) {
        matchingTagNumbers.add(animal.group!);
      }
    }
    return matchingTagNumbers;
  }

  //Get Filter Mass Events
  List<AI> getFilteredMassEvents() {
    final massList = eventBox.getAll();

    List<String> animalList = animalBox.getTagNumbersFromObjectBox().whereType<
        String>().toList();

    if (selectCattleGroup == "All") {
      return massList
          .where((element) =>
      element.eventType == selectMassEvent &&
          element.typeOfEvent == "Mass Events")
          .toList();
    }
    else {
      List<String> matchingTagNumbers = getMatchingTagNumberByGroup(
          animalList, selectCattleGroup!);

      return massList
          .where((element) =>
      matchingTagNumbers.contains(element.group) &&
          element.eventType == selectMassEvent &&
          element.typeOfEvent == "Mass Events")
          .toList();
    }
  }


  List<Widget> _buildMassReportContent() {
    List<AI> listMassEvent = getFilteredMassEvents();

    List<Widget> listTiles = [];

    for (var ai in listMassEvent.reversed) {
      final animalsList = animal.getAll();
      List<Widget> matchingAnimalWidgets = [];

      for (var animal in animalsList) {
        if (animal.group == ai.group) {
          matchingAnimalWidgets.add(
            AppTheme.sizedBox('Tag No: ${animal.tagNo ?? ''}'),
          );

          listTiles.add(
            ListTile(
              title: Text('Event Type: ${ai.eventType ?? ''}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  )
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTheme.sizedBox("Tag No: ${animal.tagNo ??''}" ),
                  AppTheme.sizedBox("Name: ${animal.name ?? ''}"),
                  AppTheme.sizedBox('Event Date: ${ai.dateOfEvent ?? ''}'),
                  AppTheme.sizedBox('Cattle Group: ${ai.group ?? ''}')
                ],
              ),
            ),
          );
        }
      }
    }

    return[
      Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        elevation: 7,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: const Center(
                child: Text(
                  'Mass Report History',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return listTiles[index];
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  color: Colors.grey,
                  thickness: 2,
                  indent: 2,
                  endIndent: 2,
                );
              },
              itemCount: listTiles.length,
            ),
            if (listMassEvent.isEmpty)
              AppTheme.staticCard('Mass History', 'No Mass History Found!'),
          ],
        ),
      ),
    ];
  }
}

