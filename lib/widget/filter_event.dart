import 'package:animal_husbandry/objectbox/production_Box.dart';
import 'package:hyper_object_box/model/ai.dart';
import 'package:hyper_object_box/model/production.dart';
import 'package:intl/intl.dart';

class FilterEvents {

  static List<AI> getFilteredList(
      List<AI> aiList, String eventType, String tagNo) {
    return aiList.where((element) =>
    element.eventType?.trim() == eventType &&
        element.tagNo == tagNo)
        .toList();
  }

  static List<AI> getLastFilterDate(
      List<AI> aiList, String eventType, String tagNo) {
    return aiList.where((element) =>
    element.eventType?.trim() == eventType &&
        element.tagNo == tagNo)
        .toList()..sort((a, b) {
            DateFormat formatter = DateFormat("yyyy-MM-dd");
            DateTime aTime = formatter.parse(a.dateOfEvent!);
            DateTime bTime = formatter.parse(b.dateOfEvent!);

            return aTime.compareTo(bTime);
          });
  }

  static List<AI> getEventList(
      List<AI> aiList, String tagNo) {
    return aiList.where((element) =>
        element.tagNo == tagNo)
        .toList()..sort((a, b) {
      DateFormat formatter = DateFormat("yyyy-MM-dd");
      DateTime aTime = formatter.parse(a.dateOfEvent!);
      DateTime bTime = formatter.parse(b.dateOfEvent!);
      return aTime.compareTo(bTime);
    });
  }

  static List<Production> fetchAndSortMilkProduction(ProductionBox productionBox) {
    final milkProductions = productionBox
        .list()
        .where((element) => element.productionType == "Milk")
        .toList()
      ..sort((a, b) {
        DateFormat formatter = DateFormat("yyyy-MM-dd");
        DateTime aTime = formatter.parse(a.dateOfEntry!);
        DateTime bTime = formatter.parse(b.dateOfEntry!);
        return bTime.compareTo(aTime);
      });

    return milkProductions;
  }

  static List<Production> filterWeightProduction(ProductionBox productionBox, String tagNo){
  final lastWeightResult = (productionBox
        .list()
        .where((element) => element.tagNo == tagNo)
        .toList()
      ..sort((a, b) {
        DateFormat formatter = DateFormat("yyyy-MM-dd");
        DateTime aTime = formatter.parse(a.weightDate!);
        DateTime bTime = formatter.parse(b.weightDate!);
        return aTime.compareTo(bTime);
      }))
        .cast<Production>();

  return lastWeightResult;
  }

}
