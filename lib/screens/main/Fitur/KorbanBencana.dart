import 'package:flutter/material.dart';


class Korbanbencana extends StatelessWidget {
  const Korbanbencana({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Data Perkiraan Polusi Udara Akan Ditampilkan di Sini',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}