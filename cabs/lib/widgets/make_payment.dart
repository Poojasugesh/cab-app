import 'package:flutter/material.dart';

class MakePayment extends StatelessWidget {
  final Function orderCheckout;
  const MakePayment(this.orderCheckout, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: const Text(
            "Make a payment of Rs. 100",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Container(
            height: 50,
            width: 250,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(20)),
            child: TextButton(
              onPressed: () {
                orderCheckout();
              },
              child: const Text(
                'Pay',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
