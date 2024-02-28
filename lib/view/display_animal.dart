import 'dart:convert';
import 'dart:typed_data';
import 'package:animal_husbandry/Update/edit_animaldetails.dart';
import 'package:animal_husbandry/app/bovine.dart';
import 'package:animal_husbandry/objectbox/animal_box.dart';
import 'package:animal_husbandry/view/view_animaldetails.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:animal_husbandry/widget/pdfGenerator.dart';
import 'package:flutter/material.dart';
import 'package:hyper_object_box/model/ai.dart';
import 'package:hyper_object_box/model/animal.dart';
import 'package:hyper_object_box/model/production.dart';
import 'package:hyper_object_box/objectbox.g.dart';

class DisplayAnimalEntry extends StatefulWidget {
  const DisplayAnimalEntry({Key? key}) : super(key: key);
  @override
  State<DisplayAnimalEntry> createState() => _DisplayAnimalEntryState();
}

class _DisplayAnimalEntryState extends State<DisplayAnimalEntry> {
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  final AnimalBox animal = AnimalBox();
  bool showArchivedItems = false;
  bool showPopupIcon = true;

  @override
  Widget build(BuildContext context) {
    final animalBox = objectBox.store.box<Animal>();
    final eventBox = objectBox.store.box<AI>();
    final productionBox = objectBox.store.box<Production>();
    final List<Animal> listAnimal = animalBox.getAll();

    //Delete Animal and that related all events and records
    void deleteRelatedIndividualEvents(String tagNo) {
      final List<AI> eventsToDelete =
          eventBox.query(AI_.tagNo.equals(tagNo)).build().find();
      for (final event in eventsToDelete) {
        eventBox.remove(event.obid);
      }
    }

    void deleteRelatedIndividualProductions(String tagNo, String cowTagNo) {
      final List<Production> productionsToDelete = productionBox
          .query(Production_.tagNo.equals(tagNo) |
              Production_.cowTagNo.equals(cowTagNo))
          .build()
          .find();
      for (final production in productionsToDelete) {
        productionBox.remove(production.id);
      }
    }

    List<Animal> filterList() {
      final searchQuery = searchController.text.toLowerCase();

      if (showArchivedItems) {
        return animal
            .list()
            .where((element) =>
                element.isArchived!.isNotEmpty &&
                (element.name!.toLowerCase().contains(searchQuery) ||
                    element.tagNo.toString().contains(searchQuery)))
            .toList();
      } else {
        return listAnimal
            .where((element) =>
                element.isArchived!.isEmpty &&
                (element.name!.toLowerCase().contains(searchQuery) ||
                    element.tagNo.toString().contains(searchQuery)))
            .toList();
      }
    }
    return WillPopScope(
      onWillPop: () async {
        // Navigate to HomeScreen
        Navigator.pushReplacementNamed(context, '/homeScreen');
        return false; // Prevent the default back button behavior
      },
      child:  Container(
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
            // Match the color from MainScreen
            title: isSearching
                ? TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        // Update the filter when search query changes
                        filterList();
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search animals...',
                      border: InputBorder.none,
                    ),
                  )
                : const Text('Animal List'),
            centerTitle: true,
            leading: AppTheme.buildBackIconButton(context, "/homeScreen"),
            elevation: 10,
            actions: [
              IconButton(
                  onPressed: () async {
                    String pdfName = "Animal_Report";
                    final List<String> columnValues = [
                      'Animal TagNo',
                      'Animal Name',
                      'Gender',
                      'Date of Birth',
                      'Animal Breed',
                      'Cattle Stage',
                      'Cattle Status',
                      'Obtained From',
                    ];
                    final List<List<String>> tableRows =
                        filterList().map((animal) {
                      return [
                        animal.tagNo ?? '',
                        animal.name ?? '',
                        animal.gender ?? '',
                        animal.dob ?? '',
                        animal.animalBread ?? '',
                        animal.cattlestage ?? '',
                        animal.cattleStatus ?? '',
                        animal.soa ?? '',
                      ];
                    }).toList();

                    // Generate and save the PDF
                    await GeneratePDF.generateAndSavePdf(
                      "Animal Husbandry",
                      columnValues,
                      tableRows,
                      pdfName,
                      context,
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf)),
              IconButton(
                icon: isSearching
                    ? const Icon(Icons.clear)
                    : const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    if (isSearching) {
                      searchController.clear();
                      isSearching = false;
                      showArchivedItems = false;
                      showPopupIcon = true;
                    } else {
                      isSearching = true;
                      showArchivedItems = false;
                      showPopupIcon = false;
                    }
                  });
                },
              ),
              if (showPopupIcon)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      if (value == 'archived') {
                        showArchivedItems = true;
                        showPopupIcon = false; // Hide the popup menu icon
                      }
                    });
                  },
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'archived',
                        child: Row(
                          children: [
                            Icon(Icons.archive_outlined),
                            SizedBox(width: 8),
                            Text('Archived'),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              for (final currentAnimal in filterList().reversed)
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // Sharp edges
                    side: const BorderSide(
                      color: Colors.blueGrey, // Match MainScreen design
                      width: 2,
                    ),
                  ),
                  elevation: 10, //  shadow
                  child: Container(
                    height: 100, // Increase the height of the ListTile
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: Container(
                        width: 60, // Adjust the size of the CircleAvatar
                        height: 60, // Adjust the size of the CircleAvatar
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blueGrey, // Match MainScreen design
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: currentAnimal.image != null &&
                                    currentAnimal.image!.isNotEmpty
                                ? ClipOval(
                                    child: Image.memory(
                                      Uint8List.fromList(
                                          base64Decode(currentAnimal.image!)),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : (currentAnimal.cattlestage == "Calf")
                                    ? Image.asset("assets/images/dcalf.png")
                                    : (currentAnimal.cattlestage == "Heifer" ||
                                            currentAnimal.cattlestage ==
                                                "Weaner")
                                        ? Image.asset(
                                            "assets/images/dheifer.png")
                                        : (currentAnimal.cattlestage == "Cow")
                                            ? Image.asset(
                                                "assets/images/dcow.png")
                                            : (currentAnimal.cattlestage ==
                                                        "Bull") ||
                                                    (currentAnimal
                                                            .cattlestage ==
                                                        "Steer")
                                                ? Image.asset(
                                                    "assets/images/dbull.png")
                                                : Text(currentAnimal.obid
                                                    .toString())),
                      ),
                      title: AppTheme.sizedBox(
                          "TagNo: ${currentAnimal.tagNo.toString()}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Name: ${currentAnimal.name.toString()}\n"
                              "Gender: ${currentAnimal.gender.toString()}\n"
                              "Stage: ${currentAnimal.cattlestage.toString()}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditAnimalDetails(animal: currentAnimal),
                              ),
                            );
                          } else if (value == 'delete') {
                            AppTheme.showDialogBox(
                              context,
                              "If you delete this animal, that related events and production records will be deleted. Is it okay? Click Yes!",
                              "Deleting Cattle",
                              () async {
                                String? animalTagNo = currentAnimal.tagNo;
                                deleteRelatedIndividualEvents(animalTagNo!);
                                deleteRelatedIndividualProductions(
                                    animalTagNo, animalTagNo);
                                animalBox.remove(currentAnimal.obid);
                                setState(() {
                                  animalBox.remove(currentAnimal.obid);
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
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnimalDetails(
                              tagNo: currentAnimal.tagNo.toString(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
            ],
          ),
        ),
        floatingActionButton:
            AppTheme.floatingActionButton(context, "/animalEntry"),
      ),
      )
    );
  }
}
