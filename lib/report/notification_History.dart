import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:flutter/material.dart';
import 'package:hyper_object_box/model/ai.dart';
import 'package:hyper_object_box/model/animal.dart';
import 'package:animal_husbandry/app/bovine.dart';
import 'package:animal_husbandry/objectbox/event_box.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({
    Key? key,
  }) : super(key: key);
  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  final EventBox aiBox = EventBox();
  Animal animal = Animal();
  AI event = AI();
  final animalBox = objectBox.store.box<Animal>();
  final eventBox = objectBox.store.box<AI>();

  List<Widget> buildMatchingEvents(
      List<AI> events, String eventTypeFilter, String tagNoFilter) {

    final now = DateTime.now();
    final matchingEventsWidgets = <Widget>[];

    List<Map<String, dynamic>> eventsWithDifferences = [];

    for (final event in events) {
      if ((eventTypeFilter.isEmpty || event.eventType == eventTypeFilter) &&
          (tagNoFilter.isEmpty || event.tagNo == tagNoFilter  ) &&
          (event.eventType == "Inseminated/Mated" || event.eventType == "Pregnant")) {
        String dateText = "";
        int differenceInDays = 0;

        if (event.eventType == "Inseminated/Mated") {
          String heatDate = event.estimatedHeatDate ?? "";
          final heatDateObj = DateTime.tryParse(heatDate);
          if (heatDateObj != null) {
            differenceInDays = heatDateObj.difference(now).inDays;
            if ((differenceInDays >= -3 && differenceInDays <= 0)) {
              dateText = 'Heat Date: $heatDate';
            }

            else if (event.eventType == "Inseminated/Mated") {
              List<AI> filteredEvents = events
                  .where((event) => event.eventType == "Inseminated/Mated")
                  .toList();

              filteredEvents.sort((a, b) {
                DateTime? dateA = DateTime.tryParse(a.dateOfEvent ?? '');
                DateTime? dateB = DateTime.tryParse(b.dateOfEvent ?? '');
                return dateA!.compareTo(dateB!);
              });

              if (filteredEvents.isNotEmpty) {
                final lastEvent = filteredEvents.last; // Get the last event after sorting
                DateTime? lastEventDateObj = DateTime.tryParse(lastEvent.dateOfEvent ?? '');

                if (lastEventDateObj != null) {
                  differenceInDays = lastEventDateObj.difference(now).inDays;
                  if (differenceInDays >= -60 && differenceInDays <= -58) {
                    dateText = 'Confirm Pregnancy: ${DateTime.now()}';
                  }
                }
              }
            }
          }
        }

        else if (event.eventType == "Pregnant") {
          String deliveryDate = event.deliveryDate ?? "";
          final deliveryDateObj = DateTime.tryParse(deliveryDate);
          if (deliveryDateObj != null) {
            differenceInDays = deliveryDateObj.difference(now).inDays;
            if (differenceInDays >= -5 && differenceInDays <= 0) {
              dateText = 'Delivery Date: $deliveryDate';
            }
            else if(differenceInDays >= 60  && differenceInDays <= 70){
              dateText = 'Stop Lactating: $deliveryDate' ;
            }
          }
        }

        if (dateText.isNotEmpty) {
          eventsWithDifferences.add({
            'widget': Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: const BorderSide(
                  color: Colors.blueGrey,
                  width: 2,
                ),
              ),
              elevation: 10,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: AppTheme.sizedBox(dateText),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTheme.sizedBox('Event Type: ${event.eventType ?? ""}'),
                    AppTheme.sizedBox('Animal TagNo: ${event.tagNo ?? ""}'),
                    AppTheme.sizedBox('Animal Name : ${event.name ?? ""}'),
                    AppTheme.sizedBox('Event Date: ${event.dateOfEvent ?? ""}'),
                  ],
                ),
                trailing: const Icon(Icons.notifications),
              ),
            ),
            'differenceInDays': differenceInDays,
          });
        }
        else {
          const Text ("No Results Found");
        }
      }
    }
    // Sort the events based on the difference in days in ascending order
    eventsWithDifferences
        .sort((a, b) => b['differenceInDays'].compareTo(a['differenceInDays']));
    // Add the sorted widgets to matchingEventsWidgets
    for (final event in eventsWithDifferences) {
      matchingEventsWidgets.add(event['widget']);
    }
    return matchingEventsWidgets;
  }

  String eventTypeFilter = ""; // Initialize with an empty string
  String tagNoFilter = "";

  @override
  Widget build(BuildContext context) {
    final allEvents = eventBox.getAll();


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Daily Reminders"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  buildMatchingEvents(allEvents, eventTypeFilter, tagNoFilter)
                      .length,
              itemBuilder: (context, index) {
                return buildMatchingEvents(
                    allEvents, eventTypeFilter, tagNoFilter)[index];
              },
            ),
          ],
        ),
      ),
    );
  }
}
