// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:animal_husbandry/app/bovine.dart';
import 'package:animal_husbandry/objectbox/paymentBox.dart';
import 'package:animal_husbandry/view/login.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:flutter/material.dart';
import 'package:hyper_object_box/model/payment.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Override HTTP behavior to accept self-signed SSL certificates (use with caution in production).
  HttpOverrides.global = MyHttpOverrides();
}

class PaymentService extends StatefulWidget {
  const PaymentService({Key? key}) : super(key: key);

  @override
  State<PaymentService> createState() => _PaymentServiceState();
}

class _PaymentServiceState extends State<PaymentService> {
  late Razorpay _razorpay;
  String key = "rzp_test_NBm9rauhbXPqOE"; // Your Razorpay test API key
  String keySecret =
      "1gIVgAv8cyOwm2hrJlW7zTur"; // Your Razorpay test API secret
  String paymentSuccessMessage = "";
  PaymentBox paymentBox = PaymentBox();
  List<Payment> listPaymentDetails = [];
  final payment = objectBox.store.box<Payment>();
  double amountInRupees = 0.0;
  bool showPayment = false;
  String? mobileNumber;
  DateTime paymentDate = DateTime.now();

  void checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    if (savedUsername != null) {
      mobileNumber = savedUsername; // Retrieve the mobile number (username)
    }
  }

  @override
  void initState() {
    _razorpay = Razorpay();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    });
    super.initState();
    checkSession();
  }

  void createOrder(double amountInRupees) async {
    String username = key;
    String password = keySecret;
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    // Convert amount to paise (1 INR = 100 paise)
    int amountInPaise = (amountInRupees * 100).toInt();
    // Ensure the minimum amount is 1 INR (100 paise)
    if (amountInPaise < 99) {
      print("Amount is too low.");
      return;
    }
    // Create the order on Razorpay using the Orders API.
    Map<String, dynamic> body = {
      "amount": (amountInRupees * 100).toInt(),
      "currency": "INR",
      "receipt": "rcptid_11"
    };

    var res = await http.post(
      Uri.https("api.razorpay.com", "v1/orders"),
      headers: <String, String>{
        "Content-Type": "application/json",
        'authorization': basicAuth,
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      // Open the Razorpay payment gateway with the generated order ID.
      openGateway(jsonDecode(res.body)['id'], amountInPaise);
    } else {
      print("Failed to create order: ${res.statusCode}");
    }
    print(res.body);
    this.amountInRupees = amountInRupees;
  }

  void openGateway(String orderId, int amountInRupees) {
    var options = {
      'key': key,
      'amount': amountInRupees, // Amount in the smallest currency sub-unit.
      'name': 'Animal Husbandry',
      'order_id': orderId, // Generated order_id from Razorpay Orders API
      'description': 'Subscription',
      'timeout': 60 * 5, // 5 minutes
      'prefill': {
        'contact': '',
        'email': '',
      }
    };
    // Open the Razorpay payment gateway.
    _razorpay.open(options);
  }

  ///Payment Success Method
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      paymentSuccessMessage =
          "Payment Successful\nPayment ID: ${response.paymentId}\nOrder ID: ${response.orderId}";
      final formattedPaymentDate =
      DateFormat('yyyy-MM-dd').format(paymentDate);
      int validity;
      if (amountInRupees == 99) {
        validity = 30;
      } else if (amountInRupees == 999) {
        validity = 365;
      } else {
        validity = 0;
      }
      // Get the current date and time
      checkSession();

      DateTime? newExpiryDate;

      List<Payment> successfulPayments = paymentBox
          .list()
          .where((element) =>
              element.userName == mobileNumber &&
              element.paymentStatus == "success")
          .toList();
      if (successfulPayments.isNotEmpty) {
        Payment? lastSuccessfulPayment = successfulPayments.last;
        String? lastExpiryDateString = lastSuccessfulPayment.expiryDate;
        if (lastExpiryDateString != null) {
          DateTime lastExpiryDate = DateTime.parse(lastExpiryDateString);
          newExpiryDate = lastExpiryDate.add(Duration(days: validity));
        }
      } else {
        newExpiryDate = paymentDate.add(Duration(days: validity));
      }
     String formattedExpiryDate = DateFormat('yyyy-MM-dd').format(newExpiryDate!);

      Payment payment = Payment(
          paymentId: response.paymentId,
          orderId: response.orderId,
          paymentDate: formattedPaymentDate,
          amount: amountInRupees.toString(),
          validity: validity.toString(),
          expiryDate: formattedExpiryDate,
          paymentStatus: "success",
          userName: mobileNumber);
          paymentBox.create(payment.toJson());
          sendPaymentToAPI(response, validity);
    });
  }

  Future<void> sendPaymentToAPI(
      PaymentSuccessResponse response, int validity) async {
    final url = Uri.parse('${AppTheme.baseUrl}/payment');
    final formattedPaymentDate =
        DateFormat('yyyy-MM-dd').format(paymentDate); // Format the DateTime

    final responses = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'payment_date': formattedPaymentDate, // Use the formatted date
        'payment_Id': response.paymentId,
        'order_Id': response.orderId,
        'user_mobile_number': mobileNumber,
        'amount': amountInRupees,
        'validity': validity,
        'payment_status': "success"
      }),
    );

    if (responses.statusCode == 200) {
      AppTheme.showSnackBar(context, "Payment Successful");
    } else {
      print('API request failed with status code: ${responses.statusCode}');
    }
  }

  ///Payment Failure Method
  void _handlePaymentError(PaymentFailureResponse response) {
    savePaymentFailureDetails(response);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message ?? 'Payment failed.'),
      ),
    );
  }

  Future<void> savePaymentFailureDetails(
      PaymentFailureResponse response) async {
    checkSession();
    final url = Uri.parse('${AppTheme.baseUrl}/payment');
    // String paymentDateString = paymentDate.toUtc().toIso8601String();
    final formattedPaymentDate =
        DateFormat('yyyy-MM-dd').format(paymentDate); // Format the DateTime
    final responses = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'payment_date': formattedPaymentDate,
        'payment_Id': 'N/A',
        'order_Id': response.code,
        'user_mobile_number': mobileNumber,
        'amount': amountInRupees,
        'validity': '0',
        'payment_status': "failure:${response.message}"
      }),
    );
    if (responses.statusCode == 200) {
      AppTheme.showSnackBar(context, "Payment Failed");
    } else {
      // Handle errors or failed API requests here.
      print('API request failed with status code: ${responses.statusCode}');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    final listPayments = payment.getAll();
    String? lastPaymentAmount;
    String? lastPaymentExpiryDate;
    String? validityCountdown;

    if (listPayments.isNotEmpty) {
      listPayments.sort((a, b) {
        DateFormat formatter = DateFormat("yyyy-MM-dd");
        DateTime aTime = formatter.parse(a.paymentDate!);
        DateTime bTime = formatter.parse(b.paymentDate!);
        return aTime.compareTo(bTime);
      });

      // Get the last payment
      final lastPayment = listPayments.last;
      lastPaymentAmount =
          lastPayment.amount == "99.0" ? "Monthly Plan" : "Yearly Plan";
      final expiryDate =
          DateFormat("yyyy-MM-dd").parse(lastPayment.expiryDate!);
      lastPaymentExpiryDate = DateFormat("yyyy-MM-dd").format(expiryDate);

      // Calculate the remaining days
      final formatter = DateFormat("yyyy-MM-dd");
      final currentDate = DateTime.now();
      final expireDate = formatter.parse(lastPaymentExpiryDate!);
      final difference = expireDate.difference(currentDate).inDays;
      validityCountdown = "$difference days left";
    } else if (listPayments.isEmpty) {
      lastPaymentAmount = "Free Plan";
      lastPaymentExpiryDate = "";
      validityCountdown = "7 days left";
    }

    return
      WillPopScope(
        onWillPop: () async {
      Navigator.of(context).pop();
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text("Subscription"),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/paymentHistory');
            },
            icon: const Icon(
              Icons.history, // Add the history icon here
              color: Colors.black54,
              size: 30,
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black54,
            size: 30,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const Login(),
            ));
          },
        ),
      ),
      body: Column(children: [
        // Container(
        //   padding: const EdgeInsets.all(20),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       text("$lastPaymentAmount", Colors.blue),
        //       text("Validity: $validityCountdown", Colors.lightGreen),
        //       text("Expiry Date: $lastPaymentExpiryDate", Colors.teal),
        //     ],
        //   ),
        // ),
        const SizedBox(height: 200), // Add spacing between top and bottom rows
        // Bottom Row (Elevated Buttons)
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Column(
                  children: [
                    container("Plans"),
                    const SizedBox(height: 10),
                    Center(
                      child: elevatedButton("Subscription ₹99", "Monthly Plan",
                          () {
                        createOrder(99);
                      }),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: elevatedButton(
                        "Subscription ₹999",
                        "Yearly plan (2 Month's Free)",
                        () {
                          createOrder(999);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ]),
    ),
    );
  }

  static ElevatedButton elevatedButton(
    String buttonText,
    String planName,
    VoidCallback onPressed, // Change the parameter type to VoidCallback
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(
            10), // Adjust the horizontal and vertical padding equally
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(8.0), // Adjust the border radius as needed
          side: const BorderSide(color: Colors.white, width: 2.0),
          // White border
        ),
        minimumSize: const Size(100, 100),
        // Increase the minimumSize height to maintain the button's size
        primary: Colors.blueGrey, // Gray background
      ),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            color: Colors.blueGrey
            ),
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            // Add spacing between text and bullet point
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.yellow,
                  size: 20,
                ),
                Text(
                  planName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Container container(String text) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.blueGrey,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }

  static Text text(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 24,
        color: color, // Change text color
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // Allow self-signed SSL certificates (use with caution in production).
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

///Payment History Class
class PaymentHistory extends StatefulWidget {
  const PaymentHistory({Key? key}) : super(key: key);

  @override
  State<PaymentHistory> createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  final payment = objectBox.store.box<Payment>();
  @override
  Widget build(BuildContext context) {
    final listPayments = payment.getAll();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment History"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: listPayments.isEmpty
          ? const Center(
              child: Text("No Payment History found!"),
            )
          : ListView.builder(
              itemCount: listPayments.length,
              itemBuilder: (BuildContext ctx, index) {
                final payment = listPayments.reversed.toList()[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: const BorderSide(
                      color: Colors.blueGrey,
                      width: 2,
                    ),
                  ),
                  elevation: 5,
                  child: Container(
                    height: 200, // Adjust the height as needed
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(payment.id.toString()),
                      ),
                      title: AppTheme.sizedBox(
                        "MobileNumber:${payment.userName.toString()}",
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTheme.sizedBox(
                            "Payment Date:${payment.paymentDate.toString()}",
                          ),
                          AppTheme.sizedBox(
                            "Order Id: ${payment.orderId.toString()}",
                          ),
                          AppTheme.sizedBox(
                            "Payment Id: ${payment.paymentId.toString()}",
                          ),
                          AppTheme.sizedBox(
                            "Amount: ${payment.amount.toString()}",
                          ),
                          AppTheme.sizedBox(
                            "Validity:${payment.validity.toString()}days",
                          ),
                          AppTheme.sizedBox(
                            "Expiry Date:${payment.expiryDate.toString()}",
                          ),
                          AppTheme.sizedBox(
                              "Payment Status: ${payment.paymentStatus.toString()}")
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
