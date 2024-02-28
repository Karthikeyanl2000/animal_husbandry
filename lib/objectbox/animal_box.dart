import 'package:animal_husbandry/app/bovine.dart';
import 'package:hyper_object_box/model/animal.dart';
import 'package:hyper_object_box/objectbox.g.dart';

class AnimalBox {
  final animalBox = objectBox.store.box<Animal>();

  int create(Map<String, Object?> values) {
    Animal animal = Animal.fromJson(values);
    try {
      if(animal.obid ==0) return animalBox.put(animal);
      Animal oldAnimal = readByName(animal.tagNo!);
      animal.obid = oldAnimal.obid;
      return animalBox.put(animal, mode: PutMode.update);
    } catch (e) {
      return animalBox.put(animal);
    }
  }


  Animal readByName(String name) {
    Query<Animal> query = animalBox.query(Animal_.tagNo.equals(name)).build();
    Animal? animal = query.findFirst();
    query.close();
    if (animal != null) {
      return animal;
    } else {
      throw Exception('Name $name not found');
    }
  }


  // Import Function
  int import(Map<String, Object?> values) {
    Animal animal = Animal.fromJson(values);
    try {
      Animal? oldAnimal = readByTagNo(animal.tagNo!);
      if (oldAnimal != null) {
         animal.tagNo = oldAnimal.tagNo;
        return animalBox.put(animal, mode: PutMode.update);
      } else {
        animal.obid = 0;
        return animalBox.put(animal);
      }
    } catch (e) {
      print('Error importing animal: $e');
      return -1;
    }
  }


  Animal? readByTagNo(String tagNo) {
    Query<Animal> query = animalBox.query(Animal_.tagNo.equals(tagNo)).build();
    Animal? animal = query.findFirst();
    query.close();
    return animal; // Return null if not found.
  }


  List<Animal> list() {
    return animalBox.getAll();
  }

  Map<String, Animal> listMap() {
    List<Animal> list = this.list();
    Map<String, Animal> maps = {};
    for (var element in list) {
      maps[element.animalId!] = element;
    }
    return maps;
  }

  List<Map<String, dynamic>> readList(List<String> userList) {
    Query<Animal> query = animalBox
        .query(Animal_.animalId.oneOf(userList.cast<String>()))
        .build();
    List<Animal> animals = query.find();
    query.close();
    List<Map<String, dynamic>> animalList = [];
    for (var element in animals) {
      animalList.add(element.toJson());
    }
    return animalList;
  }

  Animal? read(String userId) {
    Query<Animal> query = animalBox.query(Animal_.tagNo.equals(userId)).build();
    Animal? animal = query.findFirst();
    query.close();
    return animal;
  }

  bool delete(String userId) {
    Animal animal;
    try {
      animal = readByName(userId);
      return animalBox.remove(animal.obid);
    } catch (e) {
      return false;
    }
  }


  int deleteAll() {
    return animalBox.removeAll();
  }

  List<String?> getTagNumbersFromObjectBox() {
    List<Animal> listAnimal = animalBox.getAll();
    List<String?> tagNumbers = listAnimal
        .where((animal) => animal.isArchived?.isEmpty ?? true) // Filter non-archived animals
        .map((animal) => animal.tagNo) // Extract tagNo values from filtered animals
        .toList();
    return tagNumbers;
  }

  List<String?> getFTagNoNumbers() {
    List<Animal> listAnimal = animalBox.getAll();
    List<String?> femaleTagNo = listAnimal
        .where((animal) => animal.isArchived?.isEmpty ?? true)
        .where((animal) => animal.gender != "Male")
        .map((animal) => animal.tagNo)
        .toList();
    return femaleTagNo;
  }

  List<String?> getFemaleTagNoNumbers() {
    List<Animal> listAnimal = animalBox.getAll();
    List<String?> femaleTagNo = listAnimal
        .where((animal) => animal.isArchived?.isEmpty ?? true)
        .where((animal) => animal.gender != "Male")
        .map((animal) => '${animal.tagNo} [${animal.name}]') // Extract tagNo values from filtered animals
        .toList();
    return femaleTagNo;
  }

  List<String?> getFilterTagNumbersFromObjectBox() {
    List<Animal> listAnimal = animalBox.getAll();
    List<String?> tagNumbers = listAnimal
        .where((animal) => animal.isArchived?.isEmpty ?? true) // Filter non-archived animals
        .map((animal) => '${animal.tagNo} [${animal.name}]') // Extract tagNo values from filtered animals
        .toList();
    return tagNumbers;
  }


  String? getPropertyForTagNo(String tagNo, String propertyName) {

    // Extract the tag number from the combined tagNo[name] string
    String actualTagNo = tagNo.split('[').first.trim();
    Animal? animal = animalBox.query(Animal_.tagNo.equals(actualTagNo)).build().findFirst();
    switch (propertyName) {
      case 'gender':
        return animal?.gender;
      case 'name':
        return animal?.name;
      case 'cattlestage':
        return animal?.cattlestage;
      case 'cattleStatus':
        return animal?.cattleStatus;
      case 'obid':
        return animal?.obid.toString();
      case 'dob':
        return animal?.dob;
      case 'doe':
        return animal?.doe;
      case 'soa':
        return animal?.soa;
      case 'group':
        return animal?.group;
      case 'animalBread':
        return animal?.animalBread;
      case 'notes':
        return animal?.notes;
      case 'motherTagNo':
        return animal?.motherTagNo;
      case 'fatherTagNo':
        return animal?.fatherTagNo;
      case'weight':
        return animal?.weight.toString();
      case'isArchived':
        return animal?.isArchived;
      case 'tagNo':
        return animal?.tagNo;
      default:
        return null;
    }
  }

  //get length of Animals
  int getCountByCriteria(String criteria) {
    List<Animal> listAnimal = animalBox.getAll();
      return listAnimal.where((animal) {
        if(animal.isArchived?.isEmpty?? true) {
          if (criteria == 'Cow') {
            return animal.cattlestage == 'Cow';
          } else if (criteria == 'Heifer') {
            return animal.cattlestage == 'Heifer';
          } else if (criteria == 'Bull') {
            return animal.cattlestage == 'Bull';
          } else if (criteria == 'Steer') {
            return animal.cattlestage == 'Steer';
          } else if (criteria == 'Weaner') {
            return animal.cattlestage == 'Weaner' && animal.gender == "Male";
          }
          else if (criteria == 'WeanerFemale') {
            return animal.cattlestage == 'Weaner' && animal.gender == "Female";
          }
          else if (criteria == 'Calf') {
            return animal.cattlestage == 'Calf' && animal.gender == "Male";
          }
          else if (criteria == 'CalfFemale') {
            return animal.cattlestage == 'Calf' && animal.gender == "Female";
          }
          if (criteria == 'Pregnant') {
            return animal.cattleStatus == 'Pregnant';
          } else if (criteria == 'Lactating') {
            return animal.cattleStatus == 'Lactating';
          } else if (criteria == 'Lactating&Pregnant') {
            return animal.cattleStatus == 'Lactating&Pregnant';
          } else if (criteria == 'Non Lactating') {
            return animal.cattleStatus == 'Non Lactating';
          } else if (criteria == 'Total'  ) {
            return animal.gender == 'Female';
          }
        }
      return false;
    }).length;
  }

  List<String?> getCowTagNoNumbers() {
    List<Animal> listAnimal = animalBox.getAll();
    List<String?> cowTagNo = listAnimal
        .where((animal) => animal.isArchived?.isEmpty ?? true)
        .where((animal) => animal.cattlestage == "Cow")
        .map((animal) => animal.tagNo) // Extract tagNo values from filtered animals
        .toList();
    return cowTagNo;
  }
  List<String?> getCowName() {
    List<String?> cowTagNo = animalBox.getAll()
        .where((animal) => animal.isArchived?.isEmpty ?? true)
        .where((animal) => animal.cattlestage =="Cow")
        .map((animal) => '${animal.tagNo} [${animal.name}]') // Extract tagNo values from filtered animals
        .toList();
    return cowTagNo;
  }

  List<String?> getLactatingCow() {
    List<String?> cowTagNo = animalBox.getAll()
        .where((animal) => animal.isArchived?.isEmpty ?? true)
        .where((animal) => animal.cattlestage =="Cow" && animal.cattleStatus == "Lactating" || animal.cattleStatus =="Lactating&Pregnant" )
        .map((animal) => '${animal.tagNo} [${animal.name}]') // Extract tagNo values from filtered animals
        .toList();
    return cowTagNo;
  }

}
