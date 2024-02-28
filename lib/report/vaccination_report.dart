import 'package:animal_husbandry/report/baseReport_History_Page.dart';

class VaccinatedReport extends BaseReport {
  VaccinatedReport({super.key})
      : super(
    pageTitle: 'Vaccinated Report',
    eventType: 'Vaccinated', // Specify the event type here
    historyTitle: 'Vaccination History',
    historyNotFoundMessage: 'No Vaccinated History Found!',
    getTitle: (ai) => 'Tag No: ${ai.tagNo ?? ''}',
    listTileDetails: (ai) =>
        'Name: ${ai.name ?? ''}\n'
        'Event Date: ${ai.dateOfEvent ??  ''}\n'
        'Technician Name: ${ai.technicianName ?? ''}\n'
        'Medicine Name: ${ai.medicineName ?? ''}\n',
  );

}



