import 'package:flutter/material.dart';
import 'package:pekan_innovasi/api/openweatherapi.dart';
import 'weathercard/weather_card.dart';
import 'fiturcard/fiturcard.dart';
import 'BNPBCard/FloodCard.dart';
import 'BNPBCard/model.dart';
import 'BNPBCard/getBNPB.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? data;
  bool isLoading = true;
  String errorMessage = '';
  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final fetchedData = await _weatherService.fetchWeatherAndPollutionData();
      setState(() {
        data = fetchedData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blueGrey.shade900,
            Colors.blueGrey.shade200,
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: kToolbarHeight + 50.0),

            // 1. WeatherCard with Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Cuaca',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  WeatherCard(
                    data: data,
                    isLoading: isLoading,
                    errorMessage: errorMessage,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // 2. FloodCardList with Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Bencana',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  FloodCardList(
                    banjirData: fetchBanjirData(), // Fetch data from API
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // 3. FiturCard
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FiturCard(),
            ),
          ],
        ),
      ),
    );
  }
}

// New widget for horizontal scrolling list of FloodCards
class FloodCardList extends StatelessWidget {
  final Future<List<Banjir>> banjirData;

  const FloodCardList({
    super.key,
    required this.banjirData,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Banjir>>(
      future: banjirData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.tealAccent),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No data available',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        }

        final banjirList = snapshot.data!;
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.3, // Adjustable height
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: banjirList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FloodCard(
                  data: banjirList[index],
                  isLoading: false,
                  errorMessage: '',
                ),
              );
            },
          ),
        );
      },
    );
  }
}