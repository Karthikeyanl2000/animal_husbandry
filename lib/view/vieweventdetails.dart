import 'package:animal_husbandry/Update/edit_eventdetails.dart';
import 'package:animal_husbandry/app/bovine.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:flutter/material.dart';
import 'package:hyper_object_box/model/ai.dart';
import 'package:hyper_object_box/model/animal.dart';
import 'package:hyper_object_box/objectbox.g.dart';

class IndividualEventDetails extends StatefulWidget {
  final String tagNo;
  final int obid;
  const IndividualEventDetails(
      {Key? key, required this.tagNo, required this.obid})
      : super(key: key);

  @override
  State<IndividualEventDetails> createState() => AnimalDetailsState();
}

class AnimalDetailsState extends State<IndividualEventDetails> {
  Animal? animal;

  @override
  Widget build(BuildContext context) {
    final eventBox = objectBox.store.box<AI>();
    final animalBox = objectBox.store.box<Animal>();
    final AI? event =
        eventBox.query(AI_.obid.equals(widget.obid)).build().findFirst();
    if (event == null) {
      // Handle case when event is not found
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('Event Details'),
          centerTitle: true,
          leading: AppTheme.buildBackIconButton(context, "/viewEventEntry"),
          actions: [
            IconButton(
              onPressed: () {
                // Handle edit button click here
              },
              icon: const Icon(Icons.edit),
            ),
          ],
        ),
        body: const Center(child: Text('Event not found')),
      );
    }
    if (event.typeOfEvent != "Mass Events") {
      animal = animalBox
          .getAll()
          .singleWhere((element) => element.tagNo == event.tagNo);
    }
    final List<Widget> eventWidgets = [];
    //View Records Based on Individual Event Types and Mass Event Types
    if (event.eventType == "Inseminated/Mated" &&
        event.eventType != "Mass Events") {
      eventWidgets
          .add(AppTheme.buildListTile('Semen Used', event.semen.toString()));
      eventWidgets.add(AppTheme.buildListTile(
          'TechnicianName', event.technicianName.toString()));
      eventWidgets.add(AppTheme.buildListTile(
          'Expense', "₹${event.paymentType.toString()}"));
      eventWidgets.add(AppTheme.buildListTile(
          'Heat Date', event.estimatedHeatDate.toString()));
    } else if (event.typeOfEvent == "Mass Events" &&
            event.eventType == "Vaccination/Injection" ||
        event.eventType == "Treatment/Medication" ||
        event.eventType == "Deworming") {
      eventWidgets.add(AppTheme.buildListTile('Group', event.group.toString()));
      eventWidgets.add(
          AppTheme.buildListTile('Medicine', event.medicineName.toString()));
      eventWidgets.add(
          AppTheme.buildListTile('No.OfCows', event.numberOfAnimal.toString()));
      eventWidgets.add(AppTheme.buildListTile(
          'Expense', "₹${event.paymentType.toString()}"));
    } else if (event.eventType == "Pregnant" &&
        event.eventType != "Mass Events") {
      eventWidgets
          .add(AppTheme.buildListTile('Bull Tag', event.semen.toString()));
      eventWidgets.add(
          AppTheme.buildListTile('MatingDate', event.matingDate.toString()));
      eventWidgets.add(AppTheme.buildListTile(
          'DeliveryDate', event.deliveryDate.toString()));
    } else if (event.eventType == "Treated/Medicated" &&
        event.eventType != "Mass Events") {
      eventWidgets.add(AppTheme.buildListTile(
          'Symptoms', event.symptomsOfSickness.toString()));
      eventWidgets
          .add(AppTheme.buildListTile('Diagnosis', event.diagnosis.toString()));
      eventWidgets.add(AppTheme.buildListTile(
          'TechnicianName', event.technicianName.toString()));
      eventWidgets.add(AppTheme.buildListTile(
          'Expense', "₹${event.paymentType.toString()}"));
    } else if (event.eventType == "Gives Birth" &&
        event.eventType != "Mass Events") {
      eventWidgets
          .add(AppTheme.buildListTile('Bull Tag', event.semen.toString()));
      eventWidgets
          .add(AppTheme.buildListTile('Calf Tag', event.calfTagNo.toString()));
    } else if (event.typeOfEvent == "Mass Events") {
      eventWidgets.add(AppTheme.buildListTile(
          'Expense', "₹${event.paymentType.toString()}"));
      eventWidgets.add(AppTheme.buildListTile(
          'NumberOfCows', event.numberOfAnimal.toString()));
    } else if (event.eventType == "Vaccinated" &&
        event.typeOfEvent != "Mass Events") {
      eventWidgets.add(AppTheme.buildListTile(
          'MedicineName', event.medicineName.toString()));
      eventWidgets.add(AppTheme.buildListTile(
          'Technician name', event.technicianName.toString()));
      eventWidgets.add(AppTheme.buildListTile(
          'Expense', "₹${event.paymentType.toString()}"));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Event Details'),
        centerTitle: true,
      ),
      body: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 120.5),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Text(
              event.eventType.toString(),
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.typeOfEvent != "Mass Events")
                  AppTheme.buildListTile('Tag No', event.tagNo.toString()),
                if (animal != null && event.typeOfEvent != "Mass Events")
                  AppTheme.buildListTile('Name', animal!.name.toString()),
                AppTheme.buildListTile(
                    'DateOfEvent', event.dateOfEvent.toString()),
                AppTheme.buildListTile(
                    'Event Type', event.eventType.toString()),
                ...eventWidgets,
                AppTheme.buildListTile("Notes", event.desc.toString()),
              ],
            ),
            trailing: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditEventDetails(
                            event: event,
                          )),
                );
              },
              icon: const Icon(Icons.edit),
            ),
          ),
        ]),
      ),
    );
  }
}
