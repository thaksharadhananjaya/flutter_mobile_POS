import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'config.dart';
import 'dbHelper.dart';
import 'models/productModel.dart';
import 'util/comfirmDailogBox.dart';

class Inventory extends StatefulWidget {
  final String search;
  Inventory({Key key, this.search}) : super(key: key);

  @override
  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  DBHelper dbHelper = DBHelper();
  int selectCategory = 0;
  String category = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: buidBody(),
        backgroundColor: kBackgroundColor,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue[800],
          onPressed: () =>
              buildAddProduct(setState, -1, null, null, null, null, null),
          child: Icon(
            Icons.add,
          ),
        ));
  }

  SizedBox buildDelteButton() {
    return SizedBox(
      width: double.maxFinite,
      // ignore: deprecated_member_use
      child: FlatButton(
          color: Colors.red,
          height: 50,
          onPressed: () {
            buildDeleteMessege(context);
          },
          child: Text(
            'Delete All',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          )),
    );
  }

  Future<dynamic> buildDeleteMessege(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ComfirmDailogBox(
              // ignore: deprecated_member_use
              yesButton: FlatButton(
                child: Text('Yes',
                    style: TextStyle(fontSize: 17, color: Colors.white)),
                onPressed: () {
                  dbHelper.deleteAllProduct();

                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              icon: Icon(
                Icons.delete,
                color: Colors.white,
                size: 48,
              ));
        });
  }

  Widget buidBody() {
    return Column(
      children: [
        buildCategory(setState),
        Expanded(
          child: FutureBuilder(
              future: widget.search == null || widget.search.isEmpty
                  ? (category == "All"
                      ? dbHelper.getProduct()
                      : dbHelper.getProductByCategory(category))
                  : dbHelper.searchProduct(widget.search),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data.length > 0) {
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

                            return builtCard(
                                data.productID,
                                data.name,
                                data.category,
                                data.qty,
                                data.price,
                                data.salePrice,
                                index,
                                context);
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: buildDelteButton(),
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

  GestureDetector builtCard(int id, String name, String category, int qty,
      double price, double salePrice, int index, BuildContext context) {
    return GestureDetector(
      onTap: () => buildOption(name, category, id, qty, price, salePrice),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name.toUpperCase(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  SizedBox(
                    height: 8,
                  ),
                  qty > 0
                      ? Text(qty.toString())
                      : Text("Out Of Stock",
                          style: TextStyle(color: Colors.red)),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Text("Rs. ${price.toStringAsFixed(2)}")),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Text(
                        "Rs. ${salePrice!=null?salePrice.toStringAsFixed(2):'0.00'}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                ],
              )
            ],
          )),
    );
  }

  Row buildCategory(StateSetter setState) {
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
                        return GestureDetector(
                          onLongPress: data['categoryName'].toString() != "All"
                              ? () {
                                  buildDeleteCategory(
                                      data['categoryName'], setState);
                                }
                              : null,
                          child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 15.0),
                              width: 100,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(18.0)),
                              child: Center(
                                  child: Text(
                                data['categoryName'],
                                style: TextStyle(color: Colors.white),
                              ))),
                        );
                      } else {
                        return GestureDetector(
                          onLongPress: data['categoryName'].toString() != "All"
                              ? () {
                                  buildDeleteCategory(
                                      data['categoryName'], setState);
                                }
                              : null,
                          onTap: () {
                            setState(() {
                              setState(() {
                                category = data['categoryName'];
                                selectCategory = index;
                              });
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                            width: 120,
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
          onPressed: () => buildNewCategoryDialogBox(setState),
          icon: Icon(Icons.add),
          tooltip: "Add new category",
        )
      ],
    );
  }

  Future buildNewCategoryDialogBox(StateSetter setState) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController textEditingControllerCategory =
              new TextEditingController();
          return WillPopScope(
            onWillPop: () async => null,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Add New Category",
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                        onPressed: () => Navigator.of(context).pop()),
                  )
                ],
              ),
              titlePadding: EdgeInsets.only(left: 16, top: 0, bottom: 6),
              content: TextField(
                controller: textEditingControllerCategory,
                autofocus: true,
                onSubmitted: (text) {
                  if (text.isNotEmpty) {
                    dbHelper.adCategory(text);
                    setState(() {});
                  }
                },
                decoration: InputDecoration(
                    labelText: "Category",
                    counterText: "",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black87)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 6, vertical: 8)),
                maxLength: 150,
              ),
              actions: [
                SizedBox(
                  height: 36,
                  width: 100,

                  // ignore: deprecated_member_use
                  child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        if (textEditingControllerCategory.text.isNotEmpty) {
                          FocusScope.of(context).unfocus();
                          dbHelper
                              .adCategory(textEditingControllerCategory.text);
                          setState(() {});
                        }
                      },
                      child: Text(
                        "Add",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                )
              ],
            ),
          );
        });
  }

  Future buildDeleteCategory(String category, StateSetter setState) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ComfirmDailogBox(
              // ignore: deprecated_member_use
              yesButton: FlatButton(
                child: Text('Yes',
                    style: TextStyle(fontSize: 17, color: Colors.white)),
                onPressed: () {
                  dbHelper.deleteCategory(category);
                  Navigator.of(context).pop();
                  selectCategory = 0;
                  category = null;
                  setState(() {});
                },
              ),
              icon: Icon(
                Icons.delete,
                color: Colors.white,
                size: 48,
              ));
        });
  }

  Future buildAddProduct(StateSetter setStates, int id, String name,
      String category, int qty, double price, double salePrice) async {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    TextEditingController textEditingControllerName =
        new TextEditingController();
    TextEditingController textEditingControllerQty =
        new TextEditingController();
    TextEditingController textEditingControllerPrice =
        new TextEditingController();
    TextEditingController textEditingControllersalePrice =
        new TextEditingController();

    String categoryDropDown;

    List<String> categoyList = [];
    var data;
    data = await dbHelper.getCategory();
    data = data.toList();
    for (var category in data) {
      if (category["categoryName"] != "All")
        categoyList.add(category["categoryName"]);
    }

    if (category != 'null') categoryDropDown = category;

    if (name != null) textEditingControllerName.text = name;
    if (qty != null) textEditingControllerQty.text = qty.toString();
    if (price != null)
      textEditingControllerPrice.text = price.toStringAsFixed(2);

      if (salePrice != null)
      textEditingControllersalePrice.text = salePrice.toStringAsFixed(2);
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => null,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    id == -1 ? "Add New Product" : "Update Product",
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                  )
                ],
              ),
              titlePadding: EdgeInsets.only(left: 16, top: 0, bottom: 6),
              content: StatefulBuilder(builder: (context, setState) {
                return Form(
                  key: _formKey,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 20,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: TextFormField(
                              validator: (text) {
                                if (text.isEmpty) return 'Enter Product Name';
                                return null;
                              },
                              controller: textEditingControllerName,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                labelText: 'Product Name',
                                counter: Text(''),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.black87)),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 6),
                              ),
                              maxLength: 250,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: DropdownButtonFormField(
                                value: categoryDropDown,
                                onChanged: (newValue) {
                                  categoryDropDown = newValue;
                                  FocusScope.of(context).unfocus();
                                },
                                items: categoyList
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.black87)),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 6),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: TextFormField(
                              validator: (text) {
                                if (text.isEmpty) {
                                  return 'Enter Quantity';
                                }
                                return null;
                              },
                              controller: textEditingControllerQty,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                // ignore: deprecated_member_use
                                new WhitelistingTextInputFormatter(
                                    RegExp("[0-9]")),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Quantity',
                                counter: Text(''),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.black87)),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 6),
                              ),
                              maxLength: 8,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: TextFormField(
                              validator: (text) {
                                if (text.isEmpty) return 'Enter Price';

                                return null;
                              },
                              inputFormatters: [
                                // ignore: deprecated_member_use
                                new WhitelistingTextInputFormatter(
                                    RegExp("[0-9.]")),
                              ],
                              keyboardType: TextInputType.number,
                              controller: textEditingControllerPrice,
                              decoration: InputDecoration(
                                labelText: 'Price (Rs.)',
                                counter: Text(''),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.black87)),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 6),
                              ),
                              maxLength: 8,
                            ),
                          ),
                          TextFormField(
                            validator: (text) {
                              if (text.isEmpty) return 'Enter Sale Price';

                              return null;
                            },
                            inputFormatters: [
                              // ignore: deprecated_member_use
                              new WhitelistingTextInputFormatter(
                                  RegExp("[0-9.]")),
                            ],
                            keyboardType: TextInputType.number,
                            controller: textEditingControllersalePrice,
                            decoration: InputDecoration(
                              labelText: 'Sale Price (Rs.)',
                              counter: Text(''),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: Colors.black87)),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 6),
                            ),
                            maxLength: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              actions: [
                SizedBox(
                  height: 40,
                  width: 100,

                  // ignore: deprecated_member_use
                  child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      color: kPrimaryColor,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          if (id == -1) {
                            Product product = Product(
                                0,
                                double.parse(textEditingControllerPrice.text),
                                double.parse(
                                    textEditingControllersalePrice.text),
                                textEditingControllerName.text,
                                categoryDropDown,
                                int.parse(textEditingControllerQty.text));

                            dbHelper.saveProduct(product);
                          } else {
                            Product product = Product(
                                id,
                                double.parse(textEditingControllerPrice.text),
                                double.parse(
                                    textEditingControllersalePrice.text),
                                textEditingControllerName.text,
                                categoryDropDown,
                                int.parse(textEditingControllerQty.text));

                            dbHelper.updateProduct(product);
                            Navigator.of(context).pop();
                            Flushbar(
                              message: 'Update success !',
                              messageColor: Colors.green,
                              icon: Icon(
                                Icons.info,
                                color: Colors.green,
                              ),
                              duration: Duration(seconds: 3),
                            ).show(context);
                          }

                          setStates(() {
                            category = "All";
                            selectCategory = 0;
                          });
                        } else {
                          return null;
                        }
                      },
                      child: Text(
                        id == -1 ? "Save" : "Update",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                )
              ],
            ),
          );
        });
  }

  Future buildOption(
      String name, String category, int id, int qty, double price, double salePrice) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          double width = MediaQuery.of(context).size.width;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            titlePadding: EdgeInsets.only(left: 16, top: 8, bottom: 6),
            title: Text(
              name,
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width - 20,
              child: SizedBox(
                width: width * 0.7,
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        buildAddProduct(
                            setState, id, name, category, qty, price, salePrice);
                      },
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        dbHelper.deleteProduct(id);
                        Navigator.of(context).pop();
                        setState(() {});
                        Flushbar(
                          message: 'Delete success !',
                          messageColor: Colors.orange,
                          icon: Icon(
                            Icons.delete,
                            color: Colors.orange,
                          ),
                          duration: Duration(seconds: 3),
                        ).show(context);
                      },
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
