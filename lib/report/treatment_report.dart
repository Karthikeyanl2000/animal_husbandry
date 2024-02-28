import 'package:animal_husbandry/report/baseReport_History_Page.dart';

class TreatmentReport extends BaseReport {

  TreatmentReport({super.key})
      : super(
    pageTitle: 'Treatment Report',
    eventType: 'Treated/Medicated', // Specify the event type here
    historyTitle: 'Treatment History',
    historyNotFoundMessage: 'No Treatment History Found!',
    getTitle: (ai) => 'Tag No: ${ai.tagNo ?? ''}',
    listTileDetails: (ai) =>
    'Name: ${ai.name ?? ''}\n'
        'Event Date: ${ai.dateOfEvent ??  ''}\n'
        'Technician Name: ${ai.technicianName ?? ''}\n'
        'Symptoms: ${ai.symptomsOfSickness ?? ''}\n'
      'Diagnosis: ${ai.diagnosis ?? ''}\n',
  );

}



