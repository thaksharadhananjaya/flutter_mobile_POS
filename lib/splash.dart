import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Splash extends StatelessWidget {
  const Splash({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child:Stack(
      children: [
        Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/logo.jpg", width: 200, height: 200,),
            CircularProgressIndicator(
              backgroundColor: Colors.white,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            Text("සුභසිංහ සංචාරක වෙළෙන්දෝ", style: TextStyle(fontWeight: FontWeight.bold),)
          ],
        )),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: GestureDetector(
              onTap: () async {
                await launch('https://www.linkedin.com/in/thakshara',
                    forceSafariVC: false, forceWebView: false);
              },
              child: Text(
                'Devoloped By Thakshara',
                style: TextStyle(
                    fontSize: 17,
                    color: Colors.black54,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        )
      ],
    ),
      ),
    );
  }
}