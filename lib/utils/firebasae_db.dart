import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class MyData extends StatefulWidget {
  const MyData({super.key});

  @override
  State<MyData> createState() => _MyDataState();
}

class _MyDataState extends State<MyData> {
  @override
  Widget build(BuildContext context) {
    var myData = [];
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('user').snapshots(),
          builder: (context, snapshot) {
            myData.clear();
            if (snapshot.hasData) {
              final data = snapshot.data?.docs;
              for (var i in data!) {
                // debugPrint("----");
                // print(i.data());
                myData.add(i.data());
                dev.log(jsonEncode(i.data()));
                //debugPrint("----");
              }

              // print("-----${myData}------------");
            }
            return ListView.builder(
              itemBuilder: (context, index) {
                return Text("Name: ${myData[index]["name"]}");
              },
              itemCount: myData.length,
            );
          }),
    );
  }
}
