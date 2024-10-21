import 'package:flutter/material.dart';

class ButtonWidget {
  static Widget elevatedBtn(String btnName,
      {borderColor = Colors.black,
      double height = 60,
      double width = 200,
      bool disabled = false}) {
    return Container(
      width: width, // Adjust width as needed
      height: height, // Adjust height as needed
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
        ),
        gradient: LinearGradient(
          colors: disabled
              ? [
                  const Color.fromARGB(255, 80, 82, 93),
                  const Color.fromARGB(255, 166, 179, 177)
                ]
              : [Colors.indigo.shade400, Colors.tealAccent.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          btnName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
