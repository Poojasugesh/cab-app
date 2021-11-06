import 'package:cabs/widgets/make_payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Payment extends StatefulWidget {
  const Payment({Key? key}) : super(key: key);

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String? fullName;
  String? phoneNumber;
  String email = FirebaseAuth.instance.currentUser!.email!;
  final Razorpay _razorpay = Razorpay();
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentFailure);
    super.initState();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(msg: "Payment success.");
    debugPrint("Payment success");
    debugPrint(response.toString());
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment failed.");
    debugPrint('Payment failed');
    debugPrint(response.toString());
  }

  void openCheckout() {
    var options = {
      'key': 'rzp_test_4mlWxz5mCoDpep',
      'amount': 10000,
      'name': fullName!,
      'description': 'Payment for the van',
      'prefill': {
        'contact': phoneNumber!,
        'email': email,
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: users.doc(email).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("There was an error. Try again later"),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          fullName = data["Full Name"];
          phoneNumber = data['phoneNumber'];
          return MakePayment(openCheckout);
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
