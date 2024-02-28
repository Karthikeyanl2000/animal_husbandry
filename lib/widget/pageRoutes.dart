import 'package:animal_husbandry/objectbox/animal_box.dart';
import 'package:animal_husbandry/report/individualEvent_Report.dart';
import 'package:animal_husbandry/report/notification_History.dart';
import 'package:animal_husbandry/production/display_production.dart';
import 'package:animal_husbandry/production/fattening_entry.dart';
import 'package:animal_husbandry/production/production_entry.dart';
import 'package:animal_husbandry/report/ai_report.dart';
import 'package:animal_husbandry/report/byAnimalReport.dart';
import 'package:animal_husbandry/report/cattle_report.dart';
import 'package:animal_husbandry/report/mainReportPage.dart';
import 'package:animal_husbandry/report/mass_ReportHistory.dart';
import 'package:animal_husbandry/report/milk_report.dart';
import 'package:animal_husbandry/report/treatment_report.dart';
import 'package:animal_husbandry/report/vaccination_report.dart';
import 'package:animal_husbandry/report/weight_report.dart';
import 'package:animal_husbandry/services/payment_service.dart';
import 'package:animal_husbandry/view/changeanimalstage.dart';
import 'package:animal_husbandry/view/animal_entry.dart';
import 'package:animal_husbandry/view/display_event.dart';
import 'package:animal_husbandry/view/display_animal.dart';
import 'package:animal_husbandry/view/login.dart';
import 'package:animal_husbandry/view/main_screen.dart';
import 'package:animal_husbandry/view/registerPage.dart';
import 'package:animal_husbandry/view/view_animaldetails.dart';
import 'package:animal_husbandry/widget/cattleSettings.dart';
import 'package:flutter/material.dart';
import 'package:hyper_object_box/model/ai.dart';
import 'package:hyper_object_box/model/animal.dart';
import 'package:hyper_object_box/model/production.dart';

Animal animal = Animal();
AI event = AI();
final AnimalBox animalBox = AnimalBox();
Production production = Production();

Map<String, WidgetBuilder> myRoutes = {
  '/animalEntry': (BuildContext context) => const AnimalNewEntry(),
  '/viewEventEntry': (BuildContext context) => const DisplayEventEntry(
        tagNo: '',
      ),
  '/viewAnimalEntry': (BuildContext context) => const DisplayAnimalEntry(),
  '/animaldetails': (BuildContext context) => const AnimalDetails(
        tagNo: '',
      ),
  '/changeAnimalStage': (BuildContext context) => ChangeAnimalStage(
        animal: animal,
        event: event,
      ),

  '/mainReport': (BuildContext context) => const MainReportScreen(),
  '/cattleReport': (BuildContext context) => const CattleReport(),
  '/insReport': (BuildContext context) => InseminationReport(),
  '/aiReport': (BuildContext context) => const AIReport(),
  '/milkEntry': (BuildContext context) => const MilkRecordEntry(),
  '/displayMilk': (BuildContext context) => DisplayProduction(
        production: production,
      ),
  '/weightReport': (BuildContext context) => const WeightReport(),
  '/milkReport': (BuildContext context) => const MilkReport(),
  '/mainScreen': (BuildContext context) =>   MainScreen(),
  '/fatteningEntry': (BuildContext context) => FatteningEntry(animal: animal),
  '/treatmentReport': (BuildContext context) => TreatmentReport(),
  '/vaccineReport': (BuildContext context) => VaccinatedReport(),
  '/massReport': (BuildContext context) => const MassReportHistory(),
  '/report': (BuildContext context) => const NotificationList(),
  '/homeScreen': (BuildContext context) =>   MainScreen(),
  '/reportHomeScreen': (BuildContext context) => const MainReportScreen(),
  'register': (BuildContext context) => const RegisterDetails(),
  'login': (BuildContext context) => const Login(),
  'individualReports': (BuildContext context) => const IndividualReports(),
  'paymentScreen': (BuildContext context) => const PaymentService(),
  '/cattleSettings':(BuildContext context)=> const CattleSettings(),
  '/paymentHistory':(BuildContext context)=> PaymentHistory(),
  '/forgetPassword' : (BuildContext context) => const ForgetPassword(),
};
