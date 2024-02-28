import 'dart:async';
import 'package:animal_husbandry/app/bovine.dart';
import 'package:animal_husbandry/objectbox/animal_box.dart';
import 'package:animal_husbandry/objectbox/dateCycle_Box.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hyper_object_box/model/animal.dart';
import 'package:hyper_object_box/model/cycle.dart';
import 'package:intl/intl.dart';
import 'package:hyper_object_box/model/ai.dart';
import 'package:animal_husbandry/services/notification_service.dart';


class NotificationManager{
  Animal animal = Animal();
  final AnimalBox animalBox = AnimalBox();
  AI event = AI();
  bool showNotification = false;

  //Notification Service
  late NotificationService notificationService;
  late Timer timer;
  int notificationId = 0;
  final aiBox = objectBox.store.box<AI>();
  final animalObjectBox = objectBox.store.box<Animal>();
  DateTime now = DateTime.now();
  String? title;
  String? body;
  int notificationDelay = 5; // 3 seconds
  int currentIndex = 0;
  String formattedTime = DateFormat('dd-MM-yyyy h:mm a').format(DateTime.now());

  NotificationManager() {
    notificationService = NotificationService();
    notificationDelay = 5; // 3 seconds
  }

  final dateCycle = Cycle();
  final CycleBox cycleBox = CycleBox();
  int monthlyVaccineCycle = 0;

  ///ReInsemination Heat Date Reminder Notification Method
  Future<void> getAIDates() async {
    List<AI> listAIDate = aiBox.getAll();
    List<Map<String, String>> eventDateList =
    await NotificationManager.filterAIEvents(listAIDate,
        "Inseminated/Mated", (event) => event.estimatedHeatDate ?? '');
    heatDateReminder(eventDateList);
  }

  static String getHeatDateCondition(int differenceInDays) {
    if (differenceInDays >= -3 && differenceInDays <= 0) {
      return "ReInsemination for this animal";
    } else {
      return ""; // Return an empty string for other conditions or no condition met
    }
  }

  Future<void> heatDateReminder(List<Map<String, String>> eventDateList) async {
    NotificationManager.eventReminder(
        eventDateList,
        notificationService,
            (differenceInDays) =>
            NotificationManager.getHeatDateCondition(differenceInDays));
  }

  ///After 60 days of last insemination, Show confirm pregnancy Notification
  Future<void> lastInseminationDates() async {
    List<AI> lastInseminationDate = aiBox.getAll();
    List<Map<String, String>> eventDateList =
    await NotificationManager.filterAIEvents(
      lastInseminationDate,
      "Inseminated/Mated",
          (event) => event.dateOfEvent ?? '',
    );

    eventDateList.sort((a, b) {
      DateFormat formatter = DateFormat("yyyy-MM-dd");
      DateTime aTime = formatter.parse(a['eventDate'] ?? '');
      DateTime bTime = formatter.parse(b['eventDate'] ?? '');
      return aTime.compareTo(bTime);
    });
    confirmPregnancyReminder(eventDateList);
  }

  static String getConditionForPregnancy(int differenceInDays) {
    if (differenceInDays >= -60 && differenceInDays <= -58) {
      return "Confirm Pregnancy for this animal";
    } else {
      return "";
    }
  }

  Future<void> confirmPregnancyReminder(
      List<Map<String, String>> eventDataList,) async {
    NotificationManager.eventReminder(
      eventDataList,
      notificationService,
          (differenceInDays) =>
          NotificationManager.getConditionForPregnancy(differenceInDays),
    );
  }

  ///Reminder for delivery and before 60 days Stop lactating reminder
  Future<void> getDeliveryDates() async {
    List<AI> listDeliveryDate = aiBox.getAll();
    List<Map<String, String>> eventDataList =
    await NotificationManager.filterAIEvents(
        listDeliveryDate, "Pregnant", (event) => event.deliveryDate ?? '');
    deliveryDatesReminder(eventDataList);
  }

  static String getDeliveryCondition(int differenceInDays) {
    if (differenceInDays >= 60 && differenceInDays <= 70) {
      return "Stop Lactating for this animal";
    } else if (differenceInDays == 0) {
      return "Delivery date reminder for this animal "; // Return an empty string for other conditions or no condition met
    } else {
      return "";
    }
  }

  Future<void> deliveryDatesReminder(
      List<Map<String, String>> eventDataList,) async {
    NotificationManager.eventReminder(
      eventDataList,
      notificationService,
          (differenceInDays) =>
          NotificationManager.getDeliveryCondition(differenceInDays),
    );
  }

  ///Dehorning, Deworming reminder for Calves
  Future<void> getAnimalBirth(event) async {
    List<Animal> listCalfBirth = animalObjectBox.getAll();
    List<Map<String, String>> animalDataList =
    await NotificationManager.filterAnimal(
        listCalfBirth, "Calf", (a) => a.dob ?? '');
    deWormReminder(animalDataList);
  }

  ///Conditions for duration
  static String getDewormCondition(int differenceInDays) {
    if (differenceInDays >= -4 && differenceInDays <= -2) {
      return "Dehorning for this animal";
    } else if (differenceInDays >= -10 && differenceInDays <= -9) {
      return " First DeWorming for this animal";
    }
    else if (differenceInDays >= -45 && differenceInDays <= -40) {
      return " Second DeWorming for this animal";
    }
    else if (differenceInDays >= -120 && differenceInDays <= -118) {
      return "FMD first dose";
    } else if (differenceInDays >= -120 && differenceInDays <= -119) {
      return "Brucellosis first dose";
    }
    else {
      return "";
    }
  }

  Future<void> deWormReminder(List<Map<String, String>> eventDateList) async {
    eventReminder(
        eventDateList,
        notificationService,
            (differenceInDays) =>
            NotificationManager.getDewormCondition(differenceInDays));
  }


  /// Monthly Vaccine Reminder for cow
  Future<void> monthlyNotifications() async {
    final List<Animal> listCowTagNo = animalObjectBox.getAll();
    final List<Map<String, String>> animalDataList = await filterAnimal(
        listCowTagNo, "Cow", (a) => a.dob ?? '');
    try {
      final List<Cycle> cycles = cycleBox.list();
      if (cycles.isNotEmpty) {
        monthlyVaccineCycle = cycles[0].vaccineCycle;
      } else if (cycles.isEmpty) {
        monthlyVaccineCycle = dateCycle.vaccineCycle;
      }
      final now = DateTime.now();
      final month = now.month;
      final formattedTime = DateFormat('dd-MM-yyyy h:mm a').format(now);

      // Define the time windows
      final morningStartTime = DateTime(now.year, now.month, now.day, 8, 0);
      final morningEndTime = DateTime(now.year, now.month, now.day, 8, 5);
      final eveningStartTime = DateTime(now.year, now.month, now.day, 17, 00);
      final eveningEndTime = DateTime(now.year, now.month, now.day, 17, 05);

      for (int currentIndex = 0; currentIndex < animalDataList.length; currentIndex++) {
        final animalData = animalDataList[currentIndex];
        final tagNo = animalData['tagNo'];
        final name = animalData['name'];
        String title = '';
        String body = '';

        if (now.day == monthlyVaccineCycle) {
          switch (month) {
            case DateTime.january:
            case DateTime.february:
              title = 'Reminder ($tagNo - $name)';
              body = 'FMD vaccination for $formattedTime';
              break;
            case DateTime.march:
            case DateTime.april:
              title = 'Reminder ($tagNo - $name)';
              body = 'Brucellosis vaccination for $formattedTime';
              break;
            case DateTime.may:
            case DateTime.june:
              title = 'Reminder ($tagNo - $name)';
              body = 'Anthrax vaccination for $formattedTime';
              break;
            case DateTime.july:
            case DateTime.august:
              title = 'Reminder ($tagNo - $name)';
              body = 'FMD vaccination for $formattedTime';
              break;
            case DateTime.september:
            case DateTime.october:
              title = 'Reminder ($tagNo - $name)';
              body = 'Black Quarter vaccination for $formattedTime';
              break;
            case DateTime.november:
            case DateTime.december:
              title = 'Reminder ($tagNo - $name)';
              body = 'Diphtheria vaccination for $formattedTime';
              break;
            default:
              break;
          }

          if (title.isNotEmpty && body.isNotEmpty && (now.isAfter(morningStartTime) && now.isBefore(morningEndTime)) ||
              (now.isAfter(eveningStartTime) && now.isBefore(eveningEndTime))) {
            notificationId++;
            notificationService.showNotification(
              id: notificationId,
              title: title,
              body: body,
                importance: Importance.high,
                priority: Priority.high
            );
          }
        }

        // Pause for a moment before processing the next animal
        if (currentIndex < animalDataList.length - 1) {
          await Future.delayed(Duration(seconds: notificationDelay));
        }
      }
    } catch (ex) {
      print("Error: ${ex.toString()}");
    }
  }

  static Future<List<Map<String, String>>> filterAIEvents(List<AI> aiEvents,
      String eventType,
      String Function(AI event) getDateField,) async {
    Map<String, Map<String, String>> tagNoToEventData = {};
    aiEvents.where((event) => event.eventType == eventType).forEach((e) {
      final dateOfEvent =
      getDateField(e); // Use the provided function to get the date
      if (dateOfEvent != null) {
        final tagNo = e.tagNo;
        final name = e.name;
        if (tagNo != null) {
          tagNoToEventData[tagNo] = {
            'tagNo': tagNo,
            'eventDate': dateOfEvent,
            'name': name ?? '', // Ensure a default value if name is null
          };
        }
      }
    });
    List<Map<String, String>> eventDataList = tagNoToEventData.values.toList();
    return eventDataList;
  }

  /// Filter Animals based on cattle Stage
  static Future<List<Map<String, String>>> filterAnimal(List<Animal> animalBox,
      String cattleStage,
      String Function(Animal a) getDateField,) async {
    Map<String, Map<String, String>> tagNoToEventData = {};
    animalBox.where((animal) => animal.cattlestage == cattleStage).forEach((a) {
      final dateOfBirth =
      getDateField(a); // Use the provided function to get the date
      if (dateOfBirth != null ) {
        final tagNo = a.tagNo;
        final name = a.name;
        if (tagNo != null) {
          tagNoToEventData[tagNo] = {
            'tagNo': tagNo,
            'eventDate': dateOfBirth,
            'name': name ?? '', // Ensure a default value if name is null
          };
        }
      }
    });
    List<Map<String, String>> animalDataList = tagNoToEventData.values.toList();
    return animalDataList;
  }


  //Event
  static Future<void> eventReminder(List<Map<String, String>> eventDateList,
      NotificationService notificationService,
      String Function(int differenceInDays) getReminderBody,) async {
    int notificationId = 0;
    DateTime now = DateTime.now();
    int notificationDelay = 5; // 3 seconds
    int currentIndex = 0;
    DateTime currentDate = DateTime(
        now.year, now.month, now.day); // Move this line outside the loop
    final morningStartTime = DateTime(now.year, now.month, now.day, 8, 0);
    final morningEndTime = DateTime(now.year, now.month, now.day, 8, 5);
    final noonStartTime = DateTime(now.year, now.month, now.day, 12, 00);
    final noonEndTime = DateTime(now.year, now.month, now.day, 12, 05);
    final eveningStartTime = DateTime(now.year, now.month, now.day, 17, 00);
    final eveningEndTime = DateTime(now.year, now.month, now.day, 17, 05);

    void showNextNotification() {
      if (currentIndex < eventDateList.length) {
        final eventData = eventDateList[currentIndex];
        final tagNo = eventData['tagNo'];
        final lastEventDate = eventData['eventDate'];
        final name = eventData['name'];

        if (lastEventDate != null) {
          var eventDateTime = DateTime.parse(lastEventDate);
          DateTime targetDate = DateTime(
            eventDateTime.year,
            eventDateTime.month,
            eventDateTime.day,
          );

          int differenceInDays = targetDate
              .difference(currentDate)
              .inDays;

          String body = getReminderBody(differenceInDays);

          if (body.isNotEmpty && (now.isAfter(morningStartTime) && now.isBefore(morningEndTime)) ||
              (now.isAfter(eveningStartTime) && now.isBefore(eveningEndTime)) || (now.isAfter(noonStartTime) && now.isBefore(noonEndTime))) {
            String title = 'Reminder-($tagNo[$name])';
            notificationId++; // Increment for each notification
            notificationService.showNotification(
              id: notificationId,
              title: title,
              body: body,
              importance: Importance.high,
              priority: Priority.high
            );
            currentIndex++;
            Timer(Duration(seconds: notificationDelay), showNextNotification);
          }
        }
      }
    }
    showNextNotification();
  }
}

