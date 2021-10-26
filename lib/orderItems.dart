import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:subhasinghe/dbHelper.dart';

import 'config.dart';
import 'models/productModel.dart';

class OrderItem extends StatelessWidget {
  final int orderID;
  OrderItem({Key key, @required this.orderID}) : super(key: key);

  DBHelper dbHelper = DBHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          foregroundColor: Colors.black,
          backgroundColor: kBackgroundColor,
          elevation: 0,
        ),
        body: buidBody());
  }

  Widget buidBody() {
    return FutureBuilder(
        future: dbHelper.getOrderItem(orderID),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.length > 0) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: KPaddingHorizontal,
                      right: KPaddingHorizontal,
                      bottom: 50),
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 15.0),
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      var data = snapshot.data[index];

                      return builtCard(data['productName'], data['qty'],
                          data['price'], data['salePrice'], index);
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 150,
                 
                    color: kPrimaryColor,
                    child: FutureBuilder(
                        future: dbHelper.getOrderItemProfit(orderID),
                        builder: (context, snapst) {
                          if (snapst.hasData) {
                            String total =
                                snapst.data['total'].toStringAsFixed(2);
                            String cost =
                                snapst.data['cost'].toStringAsFixed(2);
                            String profit =
                                snapst.data['profit'].toStringAsFixed(2);
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  child: Row(
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
                                        child: Text("Rs. $total",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                      )
                                    ],
                                  ),
                                ),
                               
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Cost",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      SizedBox(
                                        width: 180,
                                        child: Text("Rs. $cost",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                      )
                                    ],
                                  ),
                                ),
                                
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  child: Row(
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
                                        child: Text("Rs. $profit",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: double.maxFinite,
                                  height: 45,
                                  // ignore: deprecated_member_use
                                  child: FlatButton.icon(
                                    icon: Icon(Icons.print, color: Colors.white,),
                                    color: Colors.green,
                                    label: Text("Print", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),),
                                    onPressed: () => startPrint(
                                        snapshot.data, total, cost, profit),
                                  ),
                                )
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
        });
  }

  Container builtCard(
      String name, int qty, double price, double salePrice, int index) {
    return Container(
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.toUpperCase(),
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                Text("Rs. ${price.toString()}"),
              ],
            ),
            Text("$qty X ${salePrice.toStringAsFixed(2)}"),
            SizedBox(
                width: 100,
                child: Text("Rs. ${(salePrice * qty).toStringAsFixed(2)}"))
          ],
        ));
  }

  Future<void> startPrint(
      var data, String total, String cost, String profit) async {
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

    for (int i = 0; i < data.length; i++) {
      htmlContent += """
          <tr class="spaceUnder"> <td colspan='2'><b>${data[i]['productName']}</b></td></tr>
          <tr style='vertical-align: text-top;'><td> ${(data[i]['salePrice']).toStringAsFixed(2)} X ${data[i]['qty']}<br></td><td class='total'>${(data[i]['qty'] * data[i]['salePrice']).toStringAsFixed(2)}<br></td></tr>
          """;
    }
    htmlContent += """
          <tr >
            <td class="net" style='border-top:1pt solid black'>Total</td>
            <td class="net" style='text-align: right; border-top:1pt solid black'>$total</td>
          </tr>
          <tr >
            <td class="net">Cost</td>
            <td class="net" style='text-align: right'>$cost</td>
          </tr>
          <tr >
            <td class="net">Profit</td>
            <td class="net" style='text-align: right'>$profit</td>
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
}
