import 'dart:async';
import 'package:flutter/material.dart';
import 'screens/allPosts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  @override
  void initState() {
    super.initState();
    Future.delayed(new Duration(seconds: 3), () {
      (() async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Posts(id: null)),
        );
      })();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SpinKitCubeGrid(
            color: Color.fromRGBO(79, 182, 250, 1),
            size: 300,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Loading",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
              )
            ],
          )
        ],
      ),
    ));
  }
}
