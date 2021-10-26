import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import 'config.dart';
import 'dbHelper.dart';
import 'orderItems.dart';

class Report extends StatefulWidget {
  final String search;
  final bool isAll;
  Report({Key key, this.search, this.isAll}) : super(key: key);

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  DBHelper dbHelper = DBHelper();

  @override
  Widget build(BuildContext context) {
    return buidBody();
  }

  Widget buidBody() {
    String date = DateTime.now().year.toString();
    int month = DateTime.now().month;
    int day = DateTime.now().day;
    if (month < 10) {
      date += "-0$month";
    } else {
      date += "-$month";
    }
    if (day < 10) {
      date += "-0$day";
    } else {
      date += "-$day";
    }
    return FutureBuilder(
        future: widget.search == null || widget.search.isEmpty
            ? dbHelper.getOrder(date, widget.isAll)
            : dbHelper.getOrderByID(date, widget.isAll, widget.search),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.length > 0) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: KPaddingHorizontal,
                      right: KPaddingHorizontal,
                      top: KPaddingVertical,
                      bottom: 90),
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 15.0),
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      var data = snapshot.data[index];

                      return builtCard(
                          data['orderID'], data['time'], data['total'], index);
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 70,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    color: kPrimaryColor,
                    child: FutureBuilder(
                        future: widget.search == null || widget.search.isEmpty
                            ? dbHelper.getProfit(date, widget.isAll)
                            : dbHelper.getProfitByID(
                                date, widget.isAll, widget.search),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Total",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                          "Rs. ${double.parse(snapshot.data['total'].toString()).toStringAsFixed(2)}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Profit",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                          "Rs. ${double.parse(snapshot.data['profit'].toString()).toStringAsFixed(2)}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    )
                                  ],
                                ),
                              ],
                            );
                          }
                          return SizedBox();
                        }),
                  ),
                )
              ],
            );
          } else if (snapshot.hasData && snapshot.data.length < 1) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/empty.png',
                    fit: BoxFit.scaleDown,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'No Recode Found !',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            Flushbar(
              message: 'Something went to wrong !',
              messageColor: Colors.red,
              icon: Icon(
                Icons.warning_rounded,
                color: Colors.red,
              ),
              duration: Duration(seconds: 3),
            ).show(context);
          }
          return Center(child: CircularProgressIndicator());
        });
  }

  GestureDetector builtCard(int id, String time, double profit, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderItem(
                      orderID: id,
                    )));
      },
      child: Container(
          padding: EdgeInsets.all(KPaddingHorizontal),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: index % 2 == 0 ? Colors.blue[200] : Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: kPrimaryColor.withOpacity(0.23),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(id.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              Text(time),
              SizedBox(
                  width: 100, child: Text("Rs. ${profit.toStringAsFixed(2)}")),
              IconButton(
                  onPressed: () {
                    setState(() {
                      dbHelper.deleteOrder(id);
                    });
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.red,
                  ))
            ],
          )),
    );
  }
}
