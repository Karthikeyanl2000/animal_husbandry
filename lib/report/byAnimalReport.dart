import 'package:animal_husbandry/report/baseReport_History_Page.dart';

class InseminationReport extends BaseReport {
  InseminationReport({super.key})
      : super(
    pageTitle: 'Insemination Report',
    eventType: 'Inseminated/Mated',
    historyTitle: 'Insemination History',
    historyNotFoundMessage: 'No Insemination History Found!',
    getTitle: (ai) => 'Tag No: ${ai.tagNo ?? ''}',
    listTileDetails: (ai) =>
    'Name: ${ai.name ?? ''}\n'
        'Event Date: ${ai.dateOfEvent ??  ''}\n'
        'Heat Date: ${ai.estimatedHeatDate ?? ''}\n'
        'Technician Name: ${ai.technicianName ?? ''}\n',
  );

}
