import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:subhasinghe/inventry.dart';
import 'package:subhasinghe/report.dart';
import 'package:subhasinghe/settings.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config.dart';
import 'dbHelper.dart';
import 'models/productModel.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController textEditingControllerSearch =
      new TextEditingController();
  List<TextEditingController> textEditingControllerQty = new List();
  List<TextEditingController> textEditingControllerPrice = new List();

  DBHelper dbHelper = DBHelper();
  List<GlobalKey<FormState>> formKey = new List();

  List<double> total = new List();
  bool isAll = false;
  int index = 0, selectCategory = 0;
  String category = "All";

  @override
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        {
          MoveToBackground.moveTaskToBack();
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: buidAppBar(),
        body: index == 0
            ? buidBody()
            : (index == 1
                ? Inventory(
                    search: textEditingControllerSearch.text,
                  )
                : (index==2?Report(
                    search: textEditingControllerSearch.text,
                    isAll: isAll,
                  ): Settings())),
        drawer: buildDrawer(),
      ),
    );
  }

  Widget buidBody() {
    return Column(
      children: [
        buildCategory(),
        Expanded(
          child: FutureBuilder(
              future: textEditingControllerSearch.text.isEmpty
                  ? (category == "All"
                      ? dbHelper.getProduct()
                      : dbHelper.getProductByCategory(category))
                  : dbHelper.searchProduct(textEditingControllerSearch.text),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data.length > 0) {
                  double width = MediaQuery.of(context).size.width;

                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: KPaddingHorizontal,
                            right: KPaddingHorizontal,
                            top: KPaddingVertical,
                            bottom: 50),
                        child: ListView.builder(
                          padding: EdgeInsets.only(top: 15.0),
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            var data = snapshot.data[index];
                            textEditingControllerPrice
                                .add(new TextEditingController());
                            textEditingControllerQty
                                .add(new TextEditingController());
                            formKey.add(GlobalKey<FormState>());
                            total.add(0);
                            textEditingControllerPrice[index].text =  data.salePrice!=null?data.salePrice.toStringAsFixed(2):"0.00";
                            return builtCard(index, data);
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FutureBuilder(
                                future: dbHelper.getCartSum(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Container(
                                      width: width * 0.6,
                                      height: 50,
                                      alignment: Alignment.center,
                                      color: Colors.blue,
                                      // ignore: deprecated_member_use
                                      child: Text(
                                        "Rs. ${snapshot.data.toStringAsFixed(2)}",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      width: width * 0.6,
                                      height: 50,
                                      alignment: Alignment.center,
                                      color: Colors.blue,
                                      // ignore: deprecated_member_use
                                      child: Text(
                                        "Rs. 0.00",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }
                                }),
                            Container(
                              width: width * 0.2,
                              height: 50,
                              color: Colors.red,
                              // ignore: deprecated_member_use
                              child: IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    textEditingControllerPrice.clear();
                                    textEditingControllerQty.clear();
                                    total.clear();
                                    dbHelper.deleteCart();
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              height: 56,
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: width * 0.2,
                                      height: 50,
                                      color: Colors.green,
                                      // ignore: deprecated_member_use
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.done,
                                          color: Colors.white,
                                        ),
                                        onPressed: () async {
                                          List<OrderProduct> product =
                                              await dbHelper.getCartProduct();
                                          double profit =
                                              await dbHelper.getCartProfit();
                                          double sum =
                                              await dbHelper.getCartSum();

                                          if (product.isNotEmpty) {
                                            buildCheckoutBox(
                                                context, product, sum, profit);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  FutureBuilder(
                                      future: dbHelper.getItemCount(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.data != 0) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            child: Align(
                                              alignment: Alignment.topRight,
                                              child: Badge(
                                                badgeColor: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                badgeContent: Text(
                                                    snapshot.data.toString(),
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ),
                                          );
                                        } else {
                                          return SizedBox();
                                        }
                                      })
                                ],
                              ),
                            ),
                          ],
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
                            'Empty List !',
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
              }),
        ),
      ],
    );
  }

  Future<dynamic> buildCheckoutBox(BuildContext context,
      List<OrderProduct> product, double sum, double profit) {
    List<TextEditingController> textEditingControllerQtyCheck = new List();
    List<TextEditingController> textEditingControllerPriceCheck = new List();
    List<double> totalCheck = new List();
    List<GlobalKey<FormState>> formKeyCheck = new List();
    double width = MediaQuery.of(context).size.width;
    bool isAdd = true;

    int orderID;
    for (int i = 0; i < product.length; i++) {
      totalCheck.add(product[i].salePrice * product[i].qty);
      textEditingControllerPriceCheck.add(new TextEditingController());
      textEditingControllerQtyCheck.add(new TextEditingController());
      formKeyCheck.add(GlobalKey<FormState>());
    }

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () => null,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              titlePadding: EdgeInsets.only(left: 16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Checkout",
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.red,
                      ))
                ],
              ),
              content: SingleChildScrollView(
                child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setStat) {
                  sum = totalCheck.fold(
                      0, (previousValue, element) => previousValue + element);
                  return SizedBox(
                    width: width,
                    child: Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: ListView.builder(
                            padding: EdgeInsets.only(top: 15.0),
                            shrinkWrap: true,
                            itemCount: product.length,
                            itemBuilder: (BuildContext context, int index) {
                              var data = product[index];
                              print(textEditingControllerPriceCheck.length);

                              try {
                                if (data.salePrice > 0 &&
                                    textEditingControllerPriceCheck[index]
                                        .text
                                        .isEmpty) {
                                  textEditingControllerPriceCheck[index].text =
                                      data.salePrice.toString();
                                }
                                if (data.qty > 0 &&
                                    textEditingControllerQtyCheck[index]
                                        .text
                                        .isEmpty) {
                                  textEditingControllerQtyCheck[index].text =
                                      data.qty.toString();
                                }
                              } catch (e) {}

                              return index != product.length - 1
                                  ? buidCheckCard(
                                      index,
                                      formKeyCheck,
                                      data,
                                      textEditingControllerQtyCheck,
                                      textEditingControllerPriceCheck,
                                      totalCheck,
                                      setStat)
                                  : Column(
                                      children: [
                                        buidCheckCard(
                                            index,
                                            formKeyCheck,
                                            data,
                                            textEditingControllerQtyCheck,
                                            textEditingControllerPriceCheck,
                                            totalCheck,
                                            setStat),
                                        SizedBox(
                                          height: 350,
                                        )
                                      ],
                                    );
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Items"),
                            Text("${product.length}")
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Net Total"),
                            Text("Rs. ${sum.toStringAsFixed(2)}")
                          ],
                        )
                      ],
                    ),
                  );
                }),
              ),
              actions: [
                SizedBox(
                  width: 100,
                  // ignore: deprecated_member_use
                  child: FlatButton(
                      height: 40,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      color: kPrimaryColor,
                      onPressed: () async {
                        List<OrderProduct> products = [];
                        double profit = 0.0;
                        sum = 0;
                        for (int i = 0; i < product.length; i++) {
                          if (totalCheck[i] != 0) {
                            int qty = int.parse(
                                textEditingControllerQtyCheck[i].text);
                            double salePrice = double.parse(
                                textEditingControllerPriceCheck[i].text);
                            sum += salePrice * qty;
                            profit += (salePrice - product[i].price) * qty;
                            products.add(OrderProduct(
                                product[i].productID,
                                product[i].name,
                                product[i].price,
                                qty,
                                salePrice));
                          }
                        }
                        if (products.isNotEmpty) {
                          orderID =
                              await dbHelper.addOrder(products, sum, profit);

                          startPrint(products, sum, orderID);
                          setState(() {
                            dbHelper.deleteCart();
                            total.clear();
                            textEditingControllerPrice.clear();
                            textEditingControllerQty.clear();
                          });
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        "Print",
                        style: TextStyle(color: Colors.white),
                      )),
                )
              ],
            ),
          );
        });
  }

  Container buidCheckCard(
      int index,
      List<GlobalKey<FormState>> formKeyCheck,
      OrderProduct data,
      List<TextEditingController> textEditingControllerQtyCheck,
      List<TextEditingController> textEditingControllerPriceCheck,
      List<double> totalCheck,
      StateSetter setStat) {
    return Container(
        padding: EdgeInsets.all(6),
        margin: EdgeInsets.only(bottom: 8),
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: index % 2 == 0 ? Colors.blue[200] : Colors.blue[100],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: kPrimaryColor.withOpacity(0.23),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.name.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 8,
                ),
                Container(
                  width: 120,
                  height: 30,
                  child: TextFormField(
                    autofocus: false,
                    keyboardType: TextInputType.number,
                    controller: textEditingControllerQtyCheck[index],
                    maxLength: 8,
                    onChanged: (text) {
                      if (text.isEmpty) {
                        setStat(() {
                          data.qty = 0;
                          totalCheck[index] = 0;
                        });
                      } else if (textEditingControllerPriceCheck[index]
                          .text
                          .isNotEmpty) {
                        int num1 = int.parse(text);
                        double num2 = double.parse(
                            textEditingControllerPriceCheck[index].text);
                        setStat(() {
                          data.qty = num1;
                          data.salePrice = num2;
                          totalCheck[index] = num1 * num2;
                        });
                      }
                    },
                    decoration: InputDecoration(
                        labelText: "Quentity",
                        counterText: "",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black87)),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 8)),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Container(
                  width: 120,
                  height: 30,
                  child: TextField(
                    autofocus: false,
                    keyboardType: TextInputType.number,
                    controller: textEditingControllerPriceCheck[index],
                    maxLength: 8,
                    onChanged: (text) {
                      if (text.isEmpty) {
                        setStat(() {
                          data.salePrice = 0;
                          totalCheck[index] = 0;
                        });
                      } else if (textEditingControllerQtyCheck[index]
                          .text
                          .isNotEmpty) {
                        double num1 = double.parse(text);
                        int num2 = int.parse(
                            textEditingControllerQtyCheck[index].text);
                        setStat(() {
                          data.salePrice = num1;
                          data.qty = num2;
                          totalCheck[index] = num1 * num2;
                        });
                      }
                    },
                    decoration: InputDecoration(
                        labelText: "Price",
                        counterText: "",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black87)),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 8)),
                  ),
                )
              ],
            ),
            (Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    "Total",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                      width: 120,
                      child:
                          Text("Rs. ${totalCheck[index].toStringAsFixed(2)}")),
                )
              ],
            ))
          ],
        ));
  }

  Future<dynamic> buildCategoryBox(BuildContext context, StateSetter setState) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Select Category"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: FutureBuilder(
                future: dbHelper.getCategory(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width - 4,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.length - 1,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: SizedBox(
                                width: double.maxFinite,
                                // ignore: deprecated_member_use
                                child: FlatButton(
                                    color: (index + 1) % 2 == 0
                                        ? Colors.blue[200]
                                        : Colors.blue[100],
                                    child: Text(snapshot.data[index + 1]
                                        ["categoryName"]),
                                    onPressed: () {
                                      setState(() {
                                        category = snapshot.data[index + 1]
                                            ["categoryName"];
                                        selectCategory = index + 1;
                                      });
                                      Navigator.of(context).pop();
                                    }),
                              ),
                            );
                          }),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
          );
        });
  }

  Container builtCard(int index, data) {
    return Container(
        padding: EdgeInsets.all(KPaddingHorizontal),
        margin: EdgeInsets.symmetric(vertical: 8),
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: index % 2 == 0 ? Colors.blue[200] : Colors.blue[100],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: kPrimaryColor.withOpacity(0.23),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Form(
              autovalidateMode: AutovalidateMode.always,
              key: formKey[index],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.name.toUpperCase(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    width: 120,
                    height: 30,
                    child: TextFormField(
                      autofocus: false,
                      enabled: data.qty > 0 ? true : false,
                      keyboardType: TextInputType.number,
                      controller: textEditingControllerQty[index],
                      maxLength: 8,
                      validator: (text) {
                        if (text.isNotEmpty) {
                          double enterQty = double.parse(text);
                          if (enterQty > data.qty) {
                            return 'Not available';
                          }
                        }
                        return null;
                      },
                      onChanged: (text) {
                        if (text.isNotEmpty &&
                            textEditingControllerPrice[index].text.isNotEmpty) {
                          double num1 = double.parse(text);
                          double num2 = double.parse(
                              textEditingControllerPrice[index].text);
                          setState(() {
                            total[index] = num1 * num2;
                          });
                        } else {
                          setState(() => total[index] = 0);
                        }
                      },
                      decoration: InputDecoration(
                          labelText: "Quentity",
                          counterText: "",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.black87)),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 8)),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    width: 120,
                    height: 30,
                    child: TextField(
                      autofocus: false,
                      enabled: data.qty > 0 ? true : false,
                      keyboardType: TextInputType.number,
                      controller: textEditingControllerPrice[index],
                      maxLength: 8,
                      onChanged: (text) {
                        if (text.isNotEmpty &&
                            textEditingControllerQty[index].text.isNotEmpty) {
                          double num1 = double.parse(text);
                          double num2 = double.parse(
                              textEditingControllerQty[index].text);
                          setState(() {
                            total[index] = num1 * num2;
                          });
                        } else {
                          setState(() => total[index] = 0);
                        }
                      },
                      decoration: InputDecoration(
                          labelText: "Price",
                          counterText: "",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.black87)),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 8)),
                    ),
                  )
                ],
              ),
            ),
            data.qty > 0
                ? (Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SizedBox(
                            width: 120,
                            child: Text(
                              " Rs. ${total[index].toStringAsFixed(2)}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          color: Colors.orange,
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            OrderProduct orderProduct = new OrderProduct(
                                data.productID,
                                data.name,
                                data.price,
                                textEditingControllerQty[index].text.isNotEmpty
                                    ? int.parse(
                                        textEditingControllerQty[index].text)
                                    : 0,
                                textEditingControllerPrice[index]
                                        .text
                                        .isNotEmpty
                                    ? double.parse(
                                        textEditingControllerPrice[index].text)
                                    : 0);
                            bool isUpdate =
                                await dbHelper.addCart(orderProduct);

                            if (isUpdate) {
                              Flushbar(
                                message: 'Cart item updated !',
                                messageColor: Colors.green,
                                icon: Icon(
                                  Icons.info,
                                  color: Colors.green,
                                ),
                                duration: Duration(seconds: 3),
                              ).show(context);
                            }
                            textEditingControllerPrice[index].clear();
                            textEditingControllerQty[index].clear();
                            total[index] = 0;
                            setState(() {});
                          },
                          child: Text("Add")),
                    ],
                  ))
                : Text(
                    "Out Of Stock",
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  )
          ],
        ));
  }

  Drawer buildDrawer() {
    return Drawer(
        child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: CircleAvatar(
                      radius: 64,
                      backgroundColor: kPrimaryColor,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage("assets/logo.jpg"),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "සුභසිංහ සංචාරක වෙළෙන්දෝ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  // ignore: deprecated_member_use
                  FlatButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.point_of_sale),
                              SizedBox(
                                width: 4,
                              ),
                              Text('POS',
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                          Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.arrow_forward_ios)),
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          textEditingControllerSearch.clear();
                          index = 0;
                        });
                      }),

                  // ignore: deprecated_member_use
                  FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.inventory),
                            SizedBox(
                              width: 4,
                            ),
                            Text('Inventery',
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Align(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.arrow_forward_ios)),
                      ],
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        textEditingControllerSearch.clear();
                        index = 1;
                      });
                    },
                  ),

                  // ignore: deprecated_member_use
                  FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.analytics),
                            SizedBox(
                              width: 4,
                            ),
                            Text('Report',
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Align(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.arrow_forward_ios)),
                      ],
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        textEditingControllerSearch.clear();
                        index = 2;
                      });
                    },
                  ),

                  FlatButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.settings),
                              SizedBox(
                                width: 4,
                              ),
                              Text('Settings',
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                          Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.arrow_forward_ios)),
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          textEditingControllerSearch.clear();
                          index = 3;
                        });
                      }),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  await launch('https://www.linkedin.com/in/thakshara/',
                      forceSafariVC: false, forceWebView: false);
                },
                child: Text(
                  'Developed By Thakshara',
                  style: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.w700),
                ),
              )
            ]),
      ),
    ));
  }

  Row buildCategory() {
    return Row(
      children: [
        Container(
          height: 30.0,
          width: MediaQuery.of(context).size.width - 50,
          child: FutureBuilder(
              future: dbHelper.getCategory(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      var data = snapshot.data[index];

                      if (index == selectCategory) {
                        return Container(
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                            width: 120,
                            height: 10,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(18.0)),
                            child: Center(
                                child: AutoSizeText(
                              data['categoryName'],
                              maxLines: 1,
                              maxFontSize: 16,
                              style: TextStyle(color: Colors.white),
                            )));
                      } else {
                        return GestureDetector(
                          onTap: () {
                            textEditingControllerSearch.clear();

                            setState(() {
                              category = (data['categoryName']);
                              selectCategory = index;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                            width: 100,
                            height: 10,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(18.0)),
                            child: Center(
                                child: Text(
                              data['categoryName'],
                              style: TextStyle(color: Colors.black),
                            )),
                          ),
                        );
                      }
                    },
                  );
                }
                return SizedBox();
              }),
        ),
        IconButton(
          onPressed: () => buildCategoryBox(context, setState),
          icon: Icon(Icons.more),
          tooltip: "More",
        )
      ],
    );
  }

  AppBar buidAppBar() {
    return AppBar(
      backgroundColor: kBackgroundColor,
      foregroundColor: Colors.black,
      elevation: 0,
      title: index!=3? Padding(
        padding: const EdgeInsets.only(top: 13.0),
        child: Container(
          decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.15),
              //color : Colors.red,
              borderRadius: BorderRadius.circular(15.0)),
          child: TextField(
            controller: textEditingControllerSearch,
            onChanged: (text) {
              setState(() {
                textEditingControllerPrice.clear();
                textEditingControllerQty.clear();
                total.clear();
                category = "All";
                selectCategory = 0;
              });
            },
            onSubmitted: (text) {
              setState(() {
                textEditingControllerPrice.clear();
                textEditingControllerQty.clear();
                total.clear();
                category = "All";
                selectCategory = 0;
              });
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Search ...",
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
      ) : null,
      actions: [
        Visibility(
          visible: index == 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 4, right: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isAll) {
                    isAll = false;
                  } else {
                    isAll = true;
                  }
                });
              },
              child: CircleAvatar(
                radius: 14,
                child: Text(
                  isAll ? "A" : "D",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<void> startPrint(
      List<OrderProduct> product, double total, int orderID) async {
    String date =
        "${DateTime.now().year}-${DateTime.now().month < 10 ? '0' + DateTime.now().month.toString() : DateTime.now().month}-${DateTime.now().day < 10 ? '0' + DateTime.now().day.toString() : DateTime.now().day} | ${DateTime.now().hour < 10 ? '0' + DateTime.now().hour.toString() : DateTime.now().hour}:${DateTime.now().minute < 10 ? '0' + DateTime.now().minute.toString() : DateTime.now().minute}";

    String htmlContent = """
    <!DOCTYPE html>
    <html>
      <head>
        <style>
       
        th, td{
  
          text-align: left;
          font-size:12px
   
        }

        tr.spaceUnder>td {
  style='vertical-align: text-bottom;'
}
       
        .total{
          text-align: right;
          padding-right:4px;
        }
      .net{
        border-top:1pt solid black; 
        font-size:13px; 
        font-weight:bold
      }
}
        
        </style>
      </head>
      <body>
      <center>
        <div style='font-size:14px'>සුභසිංහ සංචාරක වෙළෙන්දෝ<br></div>
             <div style='font-size:12px'>
            Fonseka Mawatha,<br>
            Haldaduwana,<br>
           Dankotuwa<br>
            <div style='margin-bottom:5px'>Tel:  0777-042198</div><div>
       </center>
        <table style="width:100%">
          <tr>
          <td style="border-bottom:1pt solid black;">#$orderID
          </td>
          <td style="border-bottom:1pt solid black; text-align:right">$date
          </td>
          </tr>
  
    """;

    for (int i = 0; i < product.length; i++) {
      htmlContent += """
          <tr class="spaceUnder"> <td colspan='2'><b>${product[i].name}</b></td></tr>
          <tr style='vertical-align: text-top;'><td> ${(product[i].salePrice).toStringAsFixed(2)} X ${product[i].qty}<br></td><td class='total'>${(product[i].salePrice * product[i].qty).toStringAsFixed(2)}<br></td></tr>
          """;
    }
    htmlContent += """
          <tr >
            <td class="net">Net Total</td>
            <td class="net" style='text-align: right'>${total.toStringAsFixed(2)}</td>
          </tr>
          <tr >
            <td colspan='2' style='font-size:14px'><center>Thank You !</center></td>
          </tr>
          <tr >
            <td colspan='2' style='font-size:11px'><center>System By Thakshara. 0776591828</cnter></td>
          </tr>
        </table>       
      </body>
      </html>
      """;

    await Printing.layoutPdf(
        format: PdfPageFormat.roll80,
        onLayout: (PdfPageFormat format) async => await Printing.convertHtml(
              format: format,
              html: htmlContent,
            ));
  }

/*
  Future<void> generateDocument(
      List<OrderProduct> product, double total, int orderID) async {
    String date =
        "${DateTime.now().year}-${DateTime.now().month < 10 ? '0' + DateTime.now().month.toString() : DateTime.now().month}-${DateTime.now().day < 10 ? '0' + DateTime.now().day.toString() : DateTime.now().day} | ${DateTime.now().hour < 10 ? '0' + DateTime.now().hour.toString() : DateTime.now().hour}:${DateTime.now().minute < 10 ? '0' + DateTime.now().minute.toString() : DateTime.now().minute}";

    String htmlContent = """
    <!DOCTYPE html>
    <html>
      <head>
        <style>
       
        th, td{
          padding: 5px;
          text-align: left;
          font-size:18px
        }
        h2{
          margin-bottom:5px
        }
        .total{
          text-align: right;
        }
      .net{
        border-top:1pt solid black; 
        font-size:20px; 
        font-weight:bold
      }

        
        </style>
      </head>
      <body>
        <center>
        <h2>සුභසිංහ සංචාරක වෙළෙන්දෝ<br></h2>
              0777-042198<br>
            Fonseka Mawatha,<br>
            Haldaduwana,<br>
            <div style='margin-bottom:5px'>Dankotuwa.</div>
       </center>
   
        <table style="width:100%">
          <tr>
          <td style="border-bottom:1pt solid black;">#$orderID<br><br>
          </td>
          <td style="border-bottom:1pt solid black; text-align:right">$date
          <br><br></td>
          </tr>
  
    """;

    for (int i = 0; i < product.length; i++) {
      htmlContent += """
          <tr> <td colspan='2'><b>${product[index].name}</b></td></tr>
          <tr><td> ${(product[i].salePrice).toStringAsFixed(2)} X ${product[index].qty}</td><td class='total'>${(product[i].salePrice * product[i].qty).toStringAsFixed(2)}</td></tr>
          """;
    }
    htmlContent += """
          <tr >
            <td class="net"><br>Net Total</td>
            <td class="net" style='text-align: right'><br>${total.toStringAsFixed(2)}</td>
          </tr>
          <tr >
            <td colspan='2' style='font-size:20px'><br><br><center>Thank You !</center><br></td>
          </tr>
          <tr >
            <td colspan='2' style='font-size:14px'><center>System By Thakshara. 0776591828</cnter></td>
          </tr>
        </table>       
      </body>
      </html>
      """;

    String targetPath = "/storage/emulated/0/Subasinghe";
    final path = Directory(targetPath);
    final targetFileName = "#$orderID-$date";
    if (!(await path.exists())) {
      path.create();
    }

    await FlutterHtmlToPdf.convertFromHtmlContent(
        htmlContent, targetPath, targetFileName);
  }*/
}
