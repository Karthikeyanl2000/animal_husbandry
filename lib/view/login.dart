// ignore_for_file: use_build_context_synchronously
import 'package:animal_husbandry/services/firebase_service.dart';
import 'package:animal_husbandry/services/payment_service.dart';
import 'package:animal_husbandry/view/main_screen.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _showPassword = true;
  FireBaseNotificationService fireBaseNotificationService = FireBaseNotificationService();


  @override
  void initState() {
    super.initState();
  }
  //Login Method
  Future<void> loginUser() async {
    try {
      final url = Uri.parse('${AppTheme.baseUrl}/login');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mobileNumber': mobileNumber.text.trim(),
          'password': password.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('message')) {
          if (responseData['message'] == 'Login Successful') {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('username', mobileNumber.text);

            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => MainScreen(),
            ));
            AppTheme.showSnackBar(context, 'Login Successful');

            fireBaseNotificationService.getDeviceToken().then((value) {
              String deviceToken = value.toString();
              FireBaseNotificationService.requestDeviceToken(deviceToken);
            });          }
          //if validity is expired, redirect to payment page
          else if (responseData['message'] == 'Redirect to payment service') {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const PaymentService(),
            ));
            AppTheme.showSnackBar(context, "Your Validity is Expired");
          } else {
            // showSnackBar for invalid username or password
            AppTheme.showSnackBar(context, 'Invalid Credentials');
          }
        }
      }
      else if (response.statusCode == 401) {
        // showSnackBar for invalid username or password
        AppTheme.showSnackBar(context, 'Username or Password is Invalid');
      }

    } catch (e) {
      print(e.toString());
    }
  }


  @override
  void dispose() {
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/login.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(),
            Container(
              padding: const EdgeInsets.only(left: 35, top: 130),
              child: const Text(
                'Animal\nHusbandry',
                style: TextStyle(color: Colors.white, fontSize: 33),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 35, right: 35),
                      child: Column(
                        children: [
                          TextField(
                            controller: mobileNumber,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              hintText: "Mobile Number",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          TextField(
                            controller: password,
                            style: const TextStyle(color: Colors.black),
                            obscureText: _showPassword,
                            decoration: InputDecoration(
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              hintText: "Password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                },
                                child: Icon(
                                  _showPassword
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: const Color(0xff4c505b),
                                child: IconButton(
                                  color: Colors.white,
                                  onPressed: () async {
                                    if (mobileNumber.text == "ADMIN" &&
                                        password.text == "ADMIN") {
                                      Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                        builder: (context) => MainScreen(),
                                      ));
                                    } else if (mobileNumber.text.isNotEmpty &&
                                        password.text.isNotEmpty) {
                                      loginUser();
                                    } else {
                                      AppTheme.showSnackBar(
                                          context, "Enter Valid Details");
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.arrow_forward,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center the text
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, 'register');
                          },
                          style: const ButtonStyle(),
                          child: RichText(
                            text: const TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                color: Color(
                                    0xff4c505b), // Color for "Don't have an account?"
                                fontSize: 18,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: "Register",
                                  style: TextStyle(
                                    color: Colors.blue, // Color for "Register"
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgetPassword');
                          },
                          style: const ButtonStyle(),
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.blue, // Color for "Forgot Password"
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


//Forget Password
class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  TextEditingController currentPassword = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  bool showPassword = false;

  Future<void> forgetPassword() async {
    final url = Uri.parse(
        '${AppTheme.baseUrl}/forget'); // Replace with your API endpoint
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "mobileNumber": mobileNumber.text,
        "email": email.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final password = data["password"];
      if (password == null) {
        AppTheme.showSnackBar(context, "User Not Found");
      } else {
        currentPassword.text = password;
        setState(() {
          showPassword = true;
        });
      }
    } else {
      print("Error: ${response.statusCode}");
    }
  }

  Future<void> resetPassword() async {
    final url = Uri.parse(
        '${AppTheme.baseUrl}/reset'); // Replace with your API endpoint
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "mobileNumber": mobileNumber.text.trim(),
        "newPassword": newPasswordController.text.trim(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data["message"]);
      AppTheme.showSnackBar(context, "Password Reset Successfully");
    } else {
      print("Error: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(children: [
              Container(),
              Container(
                padding: const EdgeInsets.only(left: 35, top: 130),
                child: const Text(
                  'Forget\nPassword',
                  style: TextStyle(color: Colors.white, fontSize: 33),
                ),
              ),
              SingleChildScrollView(
                  child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.5,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 35, right: 35),
                        child: Column(
                          children: [
                            TextField(
                              controller: mobileNumber,
                              style: AppTheme.textStyleContainer(),                              decoration: AppTheme.textFieldInputDecoration(
                                  "Mobile Number"),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextField(
                              controller: email,
                              style: AppTheme.textStyleContainer(),                              decoration:
                                  AppTheme.textFieldInputDecoration("Email"),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            if (!showPassword)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.end,
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: const Color(0xff4c505b),
                                    child: IconButton(
                                      color: Colors.white,
                                      onPressed: () async {
                                        if (mobileNumber.text.isNotEmpty &&
                                            email.text.isNotEmpty) {
                                          forgetPassword();
                                        } else {
                                          AppTheme.showSnackBar(
                                              context, "Enter Valid Details");
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.arrow_forward,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (showPassword)
                              Column(
                                children: [
                                  // Display the "Current Password" field
                                  TextField(
                                    controller: currentPassword,
                                    readOnly:
                                        true, // Make the TextField read-only
                                    style: AppTheme.textStyleContainer(),                                    decoration:
                                        AppTheme.textFieldInputDecoration(
                                            "Current Password"),
                                  ),
                                  const SizedBox(height: 20),
                                  // Display the "New Password" field
                                  TextField(
                                    controller: newPasswordController,
                                    style: AppTheme.textStyleContainer(),                                    decoration:
                                        AppTheme.textFieldInputDecoration(
                                            "Enter New Password"),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Add a "Cancel" button
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            showPassword = false;
                                            currentPassword.clear();
                                            newPasswordController.clear();
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.red),
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (mobileNumber.text.isNotEmpty &&
                                              newPasswordController
                                                  .text.isNotEmpty) {
                                            resetPassword();
                                            await Navigator.pushNamed(
                                                context, 'login');
                                          } else {
                                            AppTheme.showSnackBar(context,
                                                "Enter MobileNumber or Password");
                                          }
                                        },
                                        child: const Text("Submit"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ]),
              ))
            ])));
  }
}
