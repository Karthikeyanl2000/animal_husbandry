class DropdownListItems {
  //Animal Entry DropDownList Items

  static List<String> animalCategoryItems=[
    'Indigenous',
    'Exotic Cross',
    'Buffaloes',
    ''
  ];

  static List<String> indigenousBreedItems = [
    'Select Breed',
    'Country Cow',
    '',
  ];
  static List<String> exoticBreedItems=[
    'Select Breed',
    'HF',
    'HF Cross',
    'Jersey',
    'Jersey Cross',
    '',
  ];
  static List<String> buffaloBreedItems=[
    'Select Breed',
    'Murrah',
    'Jafarabadi',
    'Country Buffalo',
    '',
  ];

  static List<String> maleItems = [
    'Select Cattle Stage',
    'Calf',
    'Weaner',
    'Steer',
    'Bull',
    '',
  ];

  static List<String> femaleItems = [
    'Select Cattle Stage',
    'Calf',
    'Weaner',
    'Heifer',
    'Cow',
    '',
  ];

  static List<String> sourceOfCattle = [
    'Select how cattle was obtained.*',
    'Born on Farm',
    'Purchased',
    'Others',
    '',
  ];

  static List<String> genderItems = ['Select gender', 'Male', 'Female', ''];

  static List<String> cattleGroupItems = [
    'Select Cattle Group',
    'Babies',
    'Adults',
    'Others',
    '',
  ];

  static List<String> massEventItems = [
    'Select Cattle Group',
    'All',
    'Babies',
    'Adults',
    'Others',
    ''
  ];


//Event DropDown List Items
  static List<String> typeOfEventItems = <String>[
    'Select Type Of Event',
    'Individual Events',
    'Mass Events'
  ];
  static List<String> eventTypeFemaleItems = <String>[
    'Select Event Type',
    'Dry Off',
    'Treated/Medicated',
    'Inseminated/Mated',
    'Gives Birth',
    'Pregnant',
    'Vaccinated',
    'Deworming',
    'Aborted Pregnancy',
    'Other'
  ];

  static List<String> eventTypeMassItems = <String>[
    'Select Event Type Mass',
    'Vaccination/Injection',
    'Herd spraying',
    'Deworming',
    'Hoof Trimming',
    'Treatment/Medication',
    'Other'
  ];

  static List<String> eventTypeMaleItems = <String>[
    'Select Event Type',
    'Treated/Medicated',
    'Weaned',
    'Castrated',
    'Vaccinated',
    'Deworming',
    'Other'
  ];


  //Change Animal Stage DropDown List Items
  static List<String> updateMaleCattleStage = <String>[
    '',
    'Select Cattle Stage',
    'Calf',
    'Weaner',
    'Steer',
    'Bull'
  ];

  static List<String> updateFemaleCattleStage = <String>[
    '',
    'Select Cattle Stage',
    'Calf',
    'Weaner',
    'Heifer',
    'Cow'
  ];

  static List<String> updateFemaleCattleStatus = <String>[
    "",
    'Lactating',
    'Pregnant',
    'Lactating&Pregnant',
    'Non Lactating'
  ];
  static List<String> archivedReasonItems = <String>[
    '',
    'Reason for archived',
    'Lost',
    'Sold',
    'Dead',
    'Other'
  ];
}