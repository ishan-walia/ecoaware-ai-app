import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String city = "Detecting...";
  double lat = 0;
  double lon = 0;

  int aqi = 0;
  String status = "";
  String tip = "";

  String temp = "";
  String humidity = "";

  List articles = [];

  bool isLoading = true;
  String lastUpdated = "";

  final String weatherApiKey = "1d9b3c4a9c46b59a751062045edf9308";
  final String newsApiKey = "7a8c4a96fbf04da9be87dc9dc0419116";

  final PageController newsController = PageController();
  Timer? autoScrollTimer;

  @override
  void initState() {
    super.initState();
    loadData();

    /// 🔄 AUTO REFRESH
    Timer.periodic(const Duration(minutes: 5), (timer) {
      loadData();
    });

    /// 📰 AUTO NEWS SLIDE
    autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (newsController.hasClients && articles.isNotEmpty) {
        int next = newsController.page!.toInt() + 1;
        if (next >= articles.length) next = 0;

        newsController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    autoScrollTimer?.cancel();
    newsController.dispose();
    super.dispose();
  }

  /// 📍 LOCATION
  Future<Position?> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      showDialogBox("Turn ON location");
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showDialogBox("Permission denied");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showDialogBox("Enable location in settings");
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  void showDialogBox(String msg) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("⚠️ Location Required"),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openLocationSettings();
              },
              child: const Text("Open Settings"),
            )
          ],
        ),
      );
    });
  }

  /// 🔥 LOAD DATA
  Future loadData() async {
    setState(() => isLoading = true);

    try {
      Position? pos = await _getLocation();
      if (pos == null) return;

      lat = pos.latitude;
      lon = pos.longitude;

      /// CITY
      final geo = await http.get(Uri.parse(
          "https://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$lon&limit=1&appid=$weatherApiKey"));
      final geoData = jsonDecode(geo.body);
      city = geoData.isNotEmpty ? geoData[0]["name"] : "Unknown";

      /// AQI
      final aqiRes = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$weatherApiKey"));
      aqi = jsonDecode(aqiRes.body)['list'][0]['main']['aqi'];

      status = getStatus(aqi);
      tip = getTip(aqi);

      /// WEATHER
      final weather = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$weatherApiKey&units=metric"));
      final w = jsonDecode(weather.body);
      temp = "${w['main']['temp']}°C";
      humidity = "${w['main']['humidity']}%";

      /// NEWS
      final newsRes = await http.get(Uri.parse(
          "https://newsapi.org/v2/everything?"
              "q=climate+pollution+environment+india"
              "&language=en"
              "&sortBy=publishedAt"
              "&apiKey=$newsApiKey"));

      if (newsRes.statusCode == 200) {
        final data = jsonDecode(newsRes.body);
        articles = data['articles'] ?? [];
      }

      lastUpdated = TimeOfDay.now().format(context);

    } catch (e) {
      debugPrint("Error: $e");
    }

    if (mounted) setState(() => isLoading = false);
  }

  Future openUrl(String? url) async {
    if (url == null) return;
    await launchUrl(Uri.parse(url));
  }

  String getStatus(int aqi) {
    switch (aqi) {
      case 1: return "Good 🌿";
      case 2: return "Fair 🙂";
      case 3: return "Moderate 😐";
      case 4: return "Poor 😷";
      case 5: return "Very Poor ☠️";
      default: return "Unknown";
    }
  }

  String getTip(int aqi) {
    if (aqi <= 2) return "Enjoy fresh air 🌳";
    if (aqi == 3) return "Limit outdoor exposure";
    if (aqi == 4) return "Wear mask";
    return "Stay indoors";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text("EcoAware AI"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [

            /// AQI CARD
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF00BFA5)],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  Text("📍 $city",
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text("AQI $aqi",
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(status,
                      style: const TextStyle(color: Colors.white)),
                  Text("Updated: $lastUpdated",
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            /// WEATHER
            _card(Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [
                  const Icon(Icons.cloud),
                  Text(temp),
                  const Text("Temp"),
                ]),
                Column(children: [
                  const Icon(Icons.water_drop),
                  Text(humidity),
                  const Text("Humidity"),
                ]),
              ],
            )),

            /// TIP
            _card(Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.orange),
                const SizedBox(width: 10),
                Expanded(child: Text(tip)),
              ],
            )),

            /// GRAPH
            _card(SizedBox(
              height: 150,
              child: LineChart(LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    spots: const [
                      FlSpot(1, 2),
                      FlSpot(2, 3),
                      FlSpot(3, 4),
                    ],
                  )
                ],
              )),
            )),

            /// NEWS
            const Padding(
              padding: EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Environment News",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),

            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: newsController,
                itemCount: articles.length,
                itemBuilder: (context, i) {
                  final item = articles[i];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Image.network(
                          item['urlToImage'] ??
                              "https://via.placeholder.com/300",
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            item['title'] ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5)
        ],
      ),
      child: child,
    );
  }
}