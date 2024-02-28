// ignore_for_file: use_build_context_synchronously
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:device_information/device_information.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class RegisterDetails extends StatefulWidget {
  const RegisterDetails({Key? key}) : super(key: key);

  @override
  State<RegisterDetails> createState() => RegisterDetailsState();
}

class RegisterDetailsState extends State<RegisterDetails> {
  TextEditingController userName = TextEditingController();
  TextEditingController emailId = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController farmName = TextEditingController();

  bool showPassword = true;
  String imeiNumber = "";

  void showAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Alert"),
          content: const Text("Please enter valid details."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/login.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          ListView(children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 35, top: 0.05),
              child: const Text(
                "Create\n Account",
                style: TextStyle(color: Colors.white, fontSize: 33),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                right: 35,
                left: 35,
                top: (MediaQuery.of(context).size.height * 0.05),
              ),
              child: Column(children: [
                   TextField(
                    controller: userName,
                     style: AppTheme.textStyleContainer(),
                    decoration: AppTheme.textFieldInputDecoration("Name"),
                  ),

                const SizedBox(
                  height: 30,
                ),
                  TextField(
                    controller: farmName,
                    style: AppTheme.textStyleContainer(),
                    decoration: AppTheme.textFieldInputDecoration("Farm Name"),
                  ),
                const SizedBox(
                  height: 30,
                ),
              TextField(
                    controller: emailId,
                style: AppTheme.textStyleContainer(),

                decoration: AppTheme.textFieldInputDecoration("Email ID"),
                  ),

                const SizedBox(
                  height: 30,
                ),
              TextField(
                    controller: mobileNumber,
                style: AppTheme.textStyleContainer(),

                decoration:
                        AppTheme.textFieldInputDecoration("Mobile Number"),
                    keyboardType: TextInputType.number,
                  ),

                const SizedBox(
                  height: 30,
                ),
              TextField(
                    controller: password,
                style: AppTheme.textStyleContainer(),

                obscureText: showPassword,
                    decoration:
                        AppTheme.textFieldInputDecoration("Password").copyWith(
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        child: Icon(
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(
                  height: 40,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xff4c505b),
                    child: IconButton(
                      color: Colors.white,
                      onPressed: () {
                        if (userName.text.isEmpty ||
                            mobileNumber.text.isEmpty ||
                            emailId.text.isEmpty ||
                            password.text.isEmpty ||
                            farmName.text.isEmpty) {
                          showAlert();
                        } else {
                          showConfirmationAlert();
                        }
                      },
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ),
                ]),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the text
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'login');
                      },
                      style: const ButtonStyle(),
                      child: RichText(
                        text: const TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(
                            color: Color(
                                0xff4c505b), // Color for "Don't have an account?"
                            fontSize: 18,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ]),
            ),
          ]),
        ]),
      ),
    );
  }

  void showConfirmationAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Mobile Number"),
          content: Text(
            mobileNumber.text,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
              color: Colors.blue,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                sendDataToAPI();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> sendDataToAPI() async {
    try {
      // final registeredDate = await AppInstallDate().installDate;
      final currentDate = DateTime.now();
      String registerDate = DateFormat('yyyy-MM-dd').format(currentDate);

      final PermissionStatus status = await Permission.phone.request();
      if (status.isGranted) {
        imeiNumber = await DeviceInformation.deviceIMEINumber;
      } else {
        imeiNumber = "unknown";
      }

      final url = Uri.parse('${AppTheme.baseUrl}/register');
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'userName': userName.text,
              'emailId': emailId.text.trim(),
              'mobileNumber': mobileNumber.text.trim(),
              'password': password.text.trim(),
              'farmName': farmName.text,
              'installed_date': registerDate, // Make sure this is correctly set
              'IMEI_Number': imeiNumber,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        Navigator.pushNamed(context, 'login');
        AppTheme.showSnackBar(context, "Registered Successfully");
      }
      else if (response.statusCode == 400) {
        AppTheme.showSnackBar(context, "Email or Mobile number already exists");
      }
      else {
        showAlert();
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
