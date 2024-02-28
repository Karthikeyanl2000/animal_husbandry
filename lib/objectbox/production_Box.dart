import 'package:animal_husbandry/app/bovine.dart';
import 'package:animal_husbandry/widget/pageRoutes.dart';
import 'package:hyper_object_box/model/production.dart';
import 'package:hyper_object_box/objectbox.g.dart';

class ProductionBox {
  final productionBox = objectBox.store.box<Production>();

  int create(Map<String, Object?> values) {
    Production production = Production.fromJson(values);
    try {
      if (production.id == 0) productionBox.put(production);
      Production oldProductionId = readByName(production.id);
      production.id = oldProductionId.id;
      return productionBox.put(production, mode: PutMode.update);
    } catch (e) {
      print(e.toString());
      return productionBox.put(production);
    }
  }

  Production readByName(int name) {
    Query<Production> query =
        productionBox.query(Production_.id.equals(name)).build();
    Production? production = query.findFirst();
    query.close();
    if (production != null) {
      print('ID $name already exists');
      return production;
    } else {
      print(' ID $name not found');
      throw Exception('Animal ID $name not Found');
    }
  }

  List<Production> list() {
    return productionBox.getAll();
  }

  String? getProductionProperty(String tagNo, String propertyName) {
    String actualTagNo = tagNo.split('[').first.trim();
    Production? weight = productionBox
        .query(Production_.tagNo.equals(actualTagNo))
        .build()
        .findFirst();
    switch (propertyName) {
      case 'weightDate':
        return weight?.weightDate;
      case 'tagNo':
        return weight?.tagNo;
      case 'fattening':
        return weight?.fattening;
      case 'productionType':
        return weight?.productionType;
      case 'dateOfEvent':
        return weight?.dateOfEntry;
      case 'noOfAnimals':
        return weight?.cowsCount;
      case 'totalMilk':
        return weight?.totalMilk;
      case 'avgMilk':
        return weight?.averageMilk;
      default:
        return null;
    }
  }


  int import(Map<String, Object?> values) {
    Production production = Production.fromJson(values);
    try {
      Production? oldWeightTagNo = readByTagNo(production.tagNo!);
      Production? oldCowTagNo = readByCowTagNo(production.cowTagNo!);
      if (oldWeightTagNo != null)
      {
        production.tagNo = oldWeightTagNo.tagNo;
        production.id = 0;
        return productionBox.put(production);
      }
      else if (oldCowTagNo != null) {
        production.cowTagNo = oldCowTagNo.cowTagNo;
        production.id = 0;
        return productionBox.put(production);
      }
       else {
        production.id = 0;
        return productionBox.put(production);
      }
    } catch (e) {
      print('Error importing production: $e');
      return -1; // Return an error code or handle the error as needed.
    }
  }

  Production? readByTagNo(String tagNo) {
    Query<Production> query = productionBox.query(Production_.tagNo.equals(tagNo)).build();
    Production? production = query.findFirst();
    query.close();
    return production;
  }

  Production? readByCowTagNo(String cowTagNo) {
    Query<Production> query = productionBox.query(
        Production_.cowTagNo.equals(cowTagNo)).build();
    Production? production = query.findFirst();
    query.close();
    return production;
  }
}
