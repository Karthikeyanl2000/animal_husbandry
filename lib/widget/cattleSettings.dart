import 'package:animal_husbandry/objectbox/dateCycle_Box.dart';
import 'package:flutter/material.dart';
import 'package:hyper_object_box/model/cycle.dart';

class CattleSettings extends StatefulWidget {
  const CattleSettings({Key? key}) : super(key: key);

  @override
  State<CattleSettings> createState() => _CattleSettingsState();
}

class _CattleSettingsState extends State<CattleSettings> {
  bool isHeatCycleEditing = false;
  bool isDeliveryCycleEditing = false;
  bool isVaccineDateEditing = false;

  TextEditingController heatCycleController = TextEditingController();
  TextEditingController deliveryCycleController = TextEditingController();
  TextEditingController vaccineCycleController = TextEditingController();

  final cycle = Cycle();

  @override
  void initState() {
    super.initState();
    // Fetch the Cycle object from ObjectBox and update the widget state
    getCycleData();
  }

  Future<void> getCycleData() async {
    try {
      final CycleBox cycleBox = CycleBox();
      final List<Cycle> cycles = cycleBox.list();

      if (cycles.isNotEmpty) {
        cycle.id = cycles[0].id;
        cycle.heatCycle = cycles[0].heatCycle;
        cycle.deliveryCycle = cycles[0].deliveryCycle;
        cycle.vaccineCycle = cycles[0].vaccineCycle;
        heatCycleController.text = cycles[0].heatCycle.toString();
        deliveryCycleController.text = cycles[0].deliveryCycle.toString();
        vaccineCycleController.text = cycles[0].vaccineCycle.toString();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              _buildSettingItem(
                title: "Cow's Heat Cycle",
                value: "${cycle.heatCycle} days",
                onEditPressed: () {
                  setState(() {
                    isHeatCycleEditing = true;
                  });
                },
              ),
              _buildSettingItem(
                title: "Cow's Delivery Cycle",
                value: "${cycle.deliveryCycle} days",
                onEditPressed: () {
                  setState(() {
                    isDeliveryCycleEditing = true;
                  });
                },
              ),
              _buildSettingItem(
                title: "Cow's Monthly Vaccine Notification",
                value: "Day:${cycle.vaccineCycle}",
                onEditPressed: () {
                  setState(() {
                    isVaccineDateEditing = true;
                  });
                },
              ),

              if (isHeatCycleEditing)
                buildEditableField(
                  heatCycleController,
                  "Edit Heat Cycle",
                  isHeatCycleEditing,
                      () {
                    setState(() {
                      isHeatCycleEditing = false;
                      // Update the Cycle object with the new value
                      cycle.heatCycle = int.parse(heatCycleController.text);
                      // Save the updated Cycle data to ObjectBox
                      saveCycleData();
                    });
                  },
                ),
               if(isDeliveryCycleEditing)
                 buildEditableField(
                   deliveryCycleController,
                   "Edit Delivery Cycle",
                   isDeliveryCycleEditing,
                       () {
                     setState(() {
                       isDeliveryCycleEditing = false;
                       // Update the Cycle object with the new value
                       cycle.deliveryCycle = int.parse(deliveryCycleController.text);
                       // Save the updated Cycle data to ObjectBox
                       saveCycleData();
                     });
                   },
                 ),
              if(isVaccineDateEditing)
                buildEditableField(
                  vaccineCycleController,
                  "Edit Monthly Notification",
                  isVaccineDateEditing,
                      () {
                    setState(() {
                      isVaccineDateEditing = false;
                      // Update the Cycle object with the new value
                      cycle.vaccineCycle = int.parse(vaccineCycleController.text);
                      // Save the updated Cycle data to ObjectBox
                      saveCycleData();
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveCycleData() async {
    try {
      final CycleBox cycleBox = CycleBox();
      // Create a Cycle object with the updated data
      Cycle updatedCycle = Cycle(
        id: cycle.id,
        heatCycle: cycle.heatCycle,
        deliveryCycle: cycle.deliveryCycle,
        vaccineCycle: cycle.vaccineCycle
      );
      // Update the data in ObjectBox
      await cycleBox.create(updatedCycle.toJson());
    } catch (e) {
      print(e.toString());
    }
  }

  Widget _buildSettingItem({
    required String title,
    required String value,
    required VoidCallback onEditPressed,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: onEditPressed,
      ),
    );
  }

  Widget buildEditableField(
      TextEditingController controller,
      String labelText,
      bool isEditing,
      VoidCallback onPressed,
      ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: labelText,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: onPressed,
            // Use the provided callback
          ),
        ],
      ),
    );
  }

}
