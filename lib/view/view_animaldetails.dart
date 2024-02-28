import 'dart:convert';
import 'dart:typed_data';
import 'package:animal_husbandry/Update/edit_animaldetails.dart';
import 'package:flutter/material.dart';
import 'package:hyper_object_box/model/animal.dart';
import 'package:animal_husbandry/widget/apptheme.dart';

class AnimalDetails extends StatefulWidget {
  final String tagNo;
  const AnimalDetails({Key? key, required this.tagNo}) : super(key: key);
  @override
  State<AnimalDetails> createState() => _AnimalDetailsState();
}

class _AnimalDetailsState extends State<AnimalDetails> {

  @override
  Widget build(BuildContext context) {
    final Animal? animal = AppTheme.getAnimalByTagNo(widget.tagNo);

    if (animal == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('Animal Details'),
          centerTitle: true,
        ),
        body: const Center(child: Text('Animal not found')),
      );
    }

    final List<Widget> animalWidgets = [];
    if (animal.isArchived!.isNotEmpty) {

      animalWidgets.add(archivedListTile("Archived", ""));
      animalWidgets.add(
          AppTheme.buildListTile('Archived', animal.isArchived.toString()));
      animalWidgets.add(AppTheme.buildListTile(
          'Archived Date', animal.archivedDate.toString()));
      animalWidgets
          .add(AppTheme.buildListTile('Notes', animal.archivedNote.toString()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Animal Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(95, 8, 120, 8),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: const Text(
                  'General Details',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTheme.buildListTile('Tag No', animal.tagNo.toString()),
                    AppTheme.buildListTile('Name', animal.name.toString()),
                    AppTheme.buildListTile('DOB', animal.dob.toString()),
                    AppTheme.buildListTile('Gender', animal.gender.toString()),
                    AppTheme.buildListTile(
                        'Stage', animal.cattlestage.toString()),
                    AppTheme.buildListTile('Weight', animal.weight.toString()),
                    AppTheme.buildListTile(
                        'Breed', animal.animalBread.toString()),
                    if (animal.gender == "Female")
                      AppTheme.buildListTile(
                          'Status', animal.cattleStatus.toString()),
                    AppTheme.buildListTile(
                        'Cattle Group', animal.group.toString()),
                    AppTheme.buildListTile('Joined On', animal.doe.toString()),
                    AppTheme.buildListTile('Source', animal.soa.toString()),
                    AppTheme.buildListTile(
                        'Mother TagNo', animal.motherTagNo.toString()),
                    AppTheme.buildListTile(
                        'Semen/Bull TagNo', animal.fatherTagNo.toString()),
                    AppTheme.buildListTile('Notes', animal.notes.toString()),
                    ...animalWidgets,
                    if (animal.image != null && animal.image!.isNotEmpty)
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 200,
                        child: Image.memory(
                          Uint8List.fromList(base64Decode(animal.image!)),
                          fit: BoxFit
                              .fill, // Adjust the fit as needed (e.g., cover, contain, etc.)
                        ),
                      ),
                  ],
                ),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditAnimalDetails(
                            animal: animal,
                          )),
                    );
                  },
                  icon: const Icon(Icons.edit),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget archivedListTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(55, 8, 55, 8),
          decoration: const BoxDecoration(
            color: Colors.red,
          ),
          child: Text(
            title,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
