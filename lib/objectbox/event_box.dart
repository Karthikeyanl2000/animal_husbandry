import 'package:animal_husbandry/app/bovine.dart';
import 'package:hyper_object_box/model/ai.dart';
import 'package:hyper_object_box/objectbox.g.dart';

class EventBox {
  final eventBox = objectBox.store.box<AI>();

  int create(Map<String, Object?> values) {
    AI event = AI.fromJson(values);
    try {
      if (event.obid == 0) eventBox.put(event);
      var tmpList = eventBox.getAll();
      AI oldEventId = readByName(event.obid);
      event.obid = oldEventId.obid;
      return eventBox.put(event, mode: PutMode.update);
    } catch (e) {
      print("Exception on Create ==> ${e.toString()}");
      return eventBox.put(event);
    }
  }

  AI readByName(int name) {
    Query<AI> query = eventBox.query(AI_.obid.equals(name)).build();
    AI? event = query.findFirst();
    query.close();
    if (event != null) {
      print('Animal ID $name already exists');
      return event;
    } else {
      print('Animal ID $name not found');
      throw Exception('Animal ID $name not Found');
    }
  }

  AI readById(int obid) {
    Query<AI> query = eventBox.query(AI_.obid.equals(obid)).build();
    AI? event = query.findFirst();
    query.close();
    if (event != null) {
      print('ID $obid already exists');
      return event;
    } else {
      print('ID $obid not found');
      throw Exception('ID $obid not Found');
    }
  }

  List<AI> list() {
    return eventBox.getAll();
  }

  Map<String, AI> listMap() {
    List<AI> list = this.list();
    Map<String, AI> maps = {};
    for (var element in list) {
      maps[element.animalId!] = element;
    }
    return maps;
  }

  List<Map<String, dynamic>> readList(List<String> userList) {
    Query<AI> query =
    eventBox.query(AI_.animalId.oneOf(userList.cast<String>())).build();
    List<AI> ais = query.find();
    query.close();
    List<Map<String, dynamic>> aiList = [];
    for (var element in ais) {
      aiList.add(element.toJson());
    }
    return aiList;
  }

  AI? read(String userId) {
    Query<AI> query = eventBox.query(AI_.animalId.equals(userId)).build();
    AI? ai = query.findFirst();
    query.close();
    return ai;
  }

  bool delete(int id) {
    AI event;
    try {
      event = readById(id);
      return eventBox.remove(event.obid);
    } catch (e) {
      return false;
    }
  }

  int deleteAll() {
    return eventBox.removeAll();
  }


  List<String?> getDateOfEventFromObjectBox() {
    List<AI> listEventDate = eventBox.getAll();
    List<String?> eventDate =
    listEventDate.map((event) => event.dateOfEvent).toList();
    return eventDate;
  }

  String? getEventProperty(String tagNo, String propertyName) {
    String actualTagNo = tagNo
        .split('[')
        .first
        .trim();
    AI? event = eventBox.query(AI_.tagNo.equals(actualTagNo))
        .build()
        .findFirst();
    switch (propertyName) {
      case 'deliveryDate':
        return event?.deliveryDate;
      case 'tagNo':
        return event?.tagNo;
      case 'weight':
        return event?.weighedResult;
      default:
        return null;
    }
  }

  List<String?> filterMassEvents(String cattleGroup) {
    List<AI> events = eventBox.getAll();

    List<String?> massEvents = events
        .where((element) =>
    element.typeOfEvent == "Mass Events" &&
        element.group == cattleGroup.toString())
        .map((e) => e.eventType)
        .toList();
    return massEvents;
  }

  List<String?> getTecName() {
    List<AI> listEvent = eventBox.getAll();
    Set<String?> techNameSet = {};
    for (AI event in listEvent) {
      String? technicianName = event.technicianName;
      if (technicianName != null && technicianName.isNotEmpty) {
        techNameSet.add(technicianName);
      }
    }
    List<String?> techName = techNameSet.toList();
    return techName;
  }

  int import(Map<String, Object?> values) {
    AI ai = AI.fromJson(values);
    try {
      // Check if AI record already exists by tagNo.
      AI? oldAI = readByImportName(ai.tagNo!);
      if (oldAI != null) {
        ai.tagNo = oldAI.tagNo;
        ai.obid =0;
        return eventBox.put(ai);
      } else {
        ai.obid = 0;
        eventBox.put(ai);
      }
    } catch (e) {
      print("Exception on Create ==> ${e.toString()}");
      return -1; // Return an error code or handle the error as needed.
    }
    return -1;
  }

  AI? readByImportName(String tagNo) {
    Query<AI> query = eventBox.query(AI_.tagNo.equals(tagNo)).build();
    AI? ai = query.findFirst();
    query.close();
    return ai; // Return null if not found.
  }
}
