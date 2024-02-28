import 'package:animal_husbandry/view/login.dart';
import 'package:flutter/material.dart';

class License extends StatefulWidget {
  const License({Key? key}) : super(key: key);

  @override
  State<License> createState() => _LicenseState();
}

class _LicenseState extends State<License> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        Container(
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          child: TextButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const Login()));
            },
            child: const Text(
                'You trail period has been completed. If you like to be a Premium user please click me'),
          ),
        ),
      ])),
    );
  }
}
