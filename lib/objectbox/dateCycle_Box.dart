import 'package:animal_husbandry/app/bovine.dart';
import 'package:hyper_object_box/model/cycle.dart';
import 'package:hyper_object_box/objectbox.g.dart';

class CycleBox {
  final cycleBox = objectBox.store.box<Cycle>();

  int create(Map<String, Object?> values) {
    Cycle dateCycle = Cycle.fromJson(values);
    try {
      if(dateCycle.id == 0) {
        return cycleBox.put(dateCycle);
      }else if(dateCycle.id == 1) {
        Cycle oldAnimal = readById(dateCycle.id);
        dateCycle.id = oldAnimal.id;
        return cycleBox.put(dateCycle, mode: PutMode.update);
      }
    } catch (e) {
      print(e.toString());
    }
    return cycleBox.put(dateCycle);
  }
  Cycle readById(int id) {
    Query<Cycle> query = cycleBox.query(Cycle_.id.equals(id)).build();
    Cycle? cycle = query.findFirst();
    query.close();
    if (cycle != null) {
      return cycle;
    } else {
      throw Exception('Name $id not found');
    }
  }

  List<Cycle> list() {
    return cycleBox.getAll();
  }

}
