import 'package:animal_husbandry/Update/edit_eventdetails.dart';
import 'package:animal_husbandry/app/bovine.dart';
import 'package:animal_husbandry/view/event_entry.dart';
import 'package:animal_husbandry/widget/handleSwipeGesture.dart';
import 'package:animal_husbandry/widget/pdfGenerator.dart';
import 'package:flutter/material.dart';
import 'package:animal_husbandry/objectbox/event_box.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:animal_husbandry/view/vieweventdetails.dart';
import 'package:hyper_object_box/model/ai.dart';
import 'package:hyper_object_box/model/animal.dart';

class DisplayEventEntry extends StatefulWidget {
  const DisplayEventEntry({Key? key, required String tagNo}) : super(key: key);
  @override
  State<DisplayEventEntry> createState() => DisplayEventEntryState();
}

class DisplayEventEntryState extends State<DisplayEventEntry> {
  final EventBox aiBox = EventBox();
  Animal animal = Animal();
  final eventBox = objectBox.store.box<AI>();
  AI event = AI();
  List<AI> listIndividualEvent = [];
  List<AI> listOfAllEvents = [];
  List<AI> listMassEvents = [];
  bool isIndividualEvents = true;
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchIndividualEvents();
  }

  // Fetch the events from the database and update the list
  Future<void> fetchIndividualEvents() async {
    final searchQuery = searchController.text.toLowerCase();
    listIndividualEvent = aiBox
        .list()
        .where((element) =>
            element.typeOfEvent?.trim() == "Individual Events" &&
            (element.name!.toLowerCase().contains(searchQuery) ||
                element.tagNo.toString().contains(searchQuery) ||
                element.eventType!.toLowerCase().contains(searchQuery) ||
                (element.dateOfEvent!.toLowerCase().contains(searchQuery))))
        .toList();
    listMassEvents = aiBox
        .list()
        .where((element) =>
            element.typeOfEvent?.trim() == "Mass Events" &&
            element.eventType!.toLowerCase().contains(searchQuery))
        .toList();
    setState(() {
      listOfAllEvents = listIndividualEvent;
    });
  }

  double swipeStartX = 0.0;
  double swipeEndX = 0.0;
  double swipeThreshold = 70.0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      // Navigate to HomeScreen
      Navigator.pushReplacementNamed(context, '/homeScreen');
      return false;
    },
    child: GestureDetector(
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
          isIndividualEvents,
          (newValue) {
            setState(() {
              isIndividualEvents = newValue;
            });
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), // Adjust the value as needed
          color: Colors.white, // Set the background color of the page
        ),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize:
                Size.fromHeight(isSearching ? kToolbarHeight : kToolbarHeight),
            child: AppBar(
              backgroundColor: Colors.green,
              title: isSearching
                  ? TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          fetchIndividualEvents();
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search Events...',
                        border: InputBorder.none,
                      ),
                    )
                  : const Text('Events List'),
              centerTitle: true,
              leading: AppTheme.buildBackIconButton(context, "/homeScreen"),
              actions: [
                IconButton(
                  icon: Icon(isSearching ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      if (isSearching) {
                        searchController.clear();
                        fetchIndividualEvents();
                      }
                      isSearching = !isSearching;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: () async {
                    String pdfName = "Event_Report";
                    final List<String> columnValues = [
                      'Animal TagNo',
                      'Animal Name',
                      'Event Type',
                      'Date of Event'
                    ];
                    final List<List<String>> tableRows =
                        listIndividualEvent.map((event) {
                      return [
                        event.tagNo ?? '',
                        event.name ?? '',
                        event.eventType ?? '',
                        event.dateOfEvent ?? '',
                      ];
                    }).toList();
                    await GeneratePDF.generateAndSavePdf(
                      "Animal Husbandry",
                      columnValues,
                      tableRows,
                      pdfName,
                      context,
                    );
                  },
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 55,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AppTheme.customRadioButton(
                        title: 'Individual Events',
                        value: isIndividualEvents,
                        onChanged: (bool value) {
                          setState(() {
                            isIndividualEvents = value;
                          }
                          );
                        },
                        addIcon: Icons.person,
                      ),
                    ),
                    Expanded(
                      child: AppTheme.customRadioButton(
                        title: 'Mass Events',
                        value: !isIndividualEvents,
                        onChanged: (bool value) {
                          setState(() {
                            isIndividualEvents = !value;
                          });
                        },
                        addIcon: Icons.people,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: isIndividualEvents
                    ? buildEventList(listIndividualEvent)
                    : buildEventList(listMassEvents),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (!isIndividualEvents) {
                setState(() {
                  isIndividualEvents = false;
                });
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventEntry(
                    animal: animal,
                    event: event,
                    onEventAdded: (AI) {},
                    typeOfEvent: !isIndividualEvents
                        ? "Mass Events"
                        : "Individual Events",
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    )
    );
  }
  Widget buildEventList(List<AI> eventList) {
    return ListView.builder(
      itemCount: eventList.length,
      itemBuilder: (BuildContext ctx, index) {
        final event = eventList.reversed.toList()[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: const BorderSide(
              color: Colors.blueGrey,
              width: 2,
            ),
          ),
          elevation: 5,
          child: Container(
            height: 95,
            padding: const EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(event.obid.toString()),
              ),
              title: event.typeOfEvent == "Individual Events"
                  ? AppTheme.sizedBox("Tag No:${event.tagNo.toString()}")
                  : AppTheme.sizedBox("Date:${event.dateOfEvent.toString()}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event.typeOfEvent == "Individual Events")
                    AppTheme.sizedBox("Name:${event.name.toString()}"),
                  AppTheme.sizedBox("Event:${event.eventType.toString()}"),
                  event.typeOfEvent == "Mass Events"
                      ? AppTheme.sizedBox("Group:${event.group.toString()}")
                      : AppTheme.sizedBox(
                          "Date:${event.dateOfEvent.toString()}")
                ],
              ),
              trailing: buildPopupMenu(event),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IndividualEventDetails(
                      tagNo: event.tagNo.toString(),
                      obid: event.obid.toInt(),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildPopupMenu(AI event) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditEventDetails(
                event: event,
              ),
            ),
          );
        } else if (value == 'delete') {
          AppTheme.showDialogBox(
            context,
            "If you delete this Event , its not change cattle's stage and status ",
            "Deleting Event",
            () {
              final eventId = event.obid.toInt();
             // final tagNo = event.tagNo.toString();
              aiBox.delete(eventId);
              // AppTheme.deleteRelatedData(tagNo, 'event', '', eventId);
              setState(() {
                if (isIndividualEvents) {
                  listIndividualEvent.remove(event);

                } else {
                  listMassEvents.remove(event);
                }
                aiBox.delete(event.obid);
              });
            },
          );
        }
      },

      itemBuilder: (context) {
        return [
          const PopupMenuItem<String>(
            value: 'edit',
            child: Text('Edit'),
          ),
          const PopupMenuItem<String>(
            value: 'delete',
            child: Text('Delete'),
          ),
        ];
      },
    );
  }
}
