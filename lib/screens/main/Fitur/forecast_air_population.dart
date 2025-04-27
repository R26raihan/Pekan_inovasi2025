import 'package:flutter/material.dart';

class ForecastAirPopulation extends StatelessWidget {
  const ForecastAirPopulation({super.key});

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
