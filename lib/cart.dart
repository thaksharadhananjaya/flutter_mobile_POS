import 'package:subhasinghe/config.dart';
import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  Cart({Key key}) : super(key: key);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  Widget build(BuildContext context) {
    double hight = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Container(
        padding: EdgeInsets.only(top: 24),
        child: Column(
          children: [buildCart(hight), buildCheckout(hight, width)],
        ),
      ),
    );
  }

  Container buildCheckout(double hight, double width) {
    return Container(
      height: hight * 0.38-108,
      width: double.maxFinite,
      decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      margin: EdgeInsets.only(top: 20),
      padding:
          EdgeInsets.symmetric(vertical: 20, horizontal: KPaddingHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          
          buildPrice("Total Items", "5"),
          buildNetTotal("Net Total","LKR 600.00"),
          buidCheckoutButton(width)
        ],
      ),
    );
  }

  Padding buildNetTotal(String text, String netTotal) {
    return Padding(
          padding: const EdgeInsets.only(bottom: 26),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                netTotal,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        );
  }

  Padding buildPrice(String text, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          Text(
            price,
            style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ],
      ),
    );
  }

  Container buidCheckoutButton(double width) {
    return Container(
      height: 48,
      width: width * 0.40,
      decoration: BoxDecoration(
          color: Colors.orange, borderRadius: BorderRadius.circular(12)),
      // ignore: deprecated_member_use
      child: FlatButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => null,
              ));
        },
        child: Text(
          "Checkout",
          style: TextStyle(color: kBackgroundColor, fontSize: 19),
        ),
      ),
    );
  }

  Widget buildCart(double height) {
    return Container(
      height: height * 0.62,
      padding:
          EdgeInsets.symmetric(horizontal: KPaddingHorizontal, vertical: 24),
      child: ListView.builder(
          itemCount: 5,
          itemBuilder: (BuildContext context, int index) {
            // var data = snapshot.data[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                height: 80,
                padding: EdgeInsets.all(10),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.5), blurRadius: 9)
                    ],
                    color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Set Product Image
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(
                          "https://images.bewakoof.com/original/pineapple-yellow-full-sleeve-t-shirt-men-s-plain-full-sleeve-t-shirts-231507-1585629668.jpg",
                          width: 40,
                          height: 40,
                          fit: BoxFit.scaleDown,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Sample",
                                style: TextStyle(
                                    color: kPrimaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                            Text(
                              "LKR 2000.00",
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Text("04",
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        SizedBox(
                          width: 30,
                        ),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.red[400]),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
