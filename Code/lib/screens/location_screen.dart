import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'package:ecoaware_ai/services/location_service.dart';
import 'package:ecoaware_ai/services/gemini_service.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String? selectedState;
  String? selectedCity;

  List<String> states = [];

  Map<String, dynamic>? result;
  String? ecoTip;
  bool isLoading = false;

  final TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStates();
  }

  /// 🌍 LOAD STATES
  Future loadStates() async {
    states = await LocationService.getStates();
    setState(() {});
  }

  /// 🚀 FETCH DATA
  Future fetchData() async {
    if (selectedCity == null || selectedCity!.isEmpty) return;

    setState(() => isLoading = true);

    final coords =
    await LocationService.getCoordinates(selectedCity!);

    if (coords == null) {
      setState(() => isLoading = false);
      return;
    }

    final data = await LocationService.getAQI(
      lat: coords["lat"]!,
      lon: coords["lon"]!,
    );

    if (data != null) {
      String tip = "";

      try {
        tip = await GeminiService.getResponse(
          "Give a short eco-friendly tip for AQI ${data['status']}",
        );
      } catch (e) {
        tip = "";
      }

      setState(() {
        result = data;

        /// 🔥 SMART FALLBACK
        ecoTip = (tip.isEmpty || tip.contains("Error"))
            ? getSmartTip(data['aqi'])
            : tip;

        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  /// 🧠 SMART TIP
  String getSmartTip(int aqi) {
    if (aqi <= 2) return "Air is clean 🌿 Enjoy outside!";
    if (aqi == 3) return "Moderate 😐 Avoid long exposure.";
    if (aqi == 4) return "Wear mask 😷 Stay safe.";
    return "Stay indoors ⚠️ Dangerous air!";
  }

  /// 🎨 AQI COLOR
  Color getAQIColor(int aqi) {
    if (aqi <= 2) return Colors.green;
    if (aqi == 3) return Colors.orange;
    if (aqi == 4) return Colors.red;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          /// 🌈 BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF56ab2f), Color(0xFFa8e063)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// 🌍 ANIMATION
          Center(
            child: Opacity(
              opacity: 0.2,
              child: Lottie.asset(
                "lib/assets/animations/Globe.json",
                height: 250,
              ),
            ),
          ),

          /// UI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  const Text(
                    "🌍 Eco Location",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// STATE DROPDOWN
                  DropdownSearch<String>(
                    items: states,
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                    ),
                    dropdownDecoratorProps:
                    const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Select State",
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    onChanged: (value) {
                      selectedState = value;
                    },
                  ),

                  const SizedBox(height: 10),

                  /// CITY INPUT
                  TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: "Enter City",
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      selectedCity = value;
                    },
                  ),

                  const SizedBox(height: 20),

                  /// BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: fetchData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                        "Get AQI Data",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const Spacer(),

                  /// RESULT CARD
                  if (result != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            getAQIColor(result!['aqi'])
                                .withOpacity(0.4),
                            getAQIColor(result!['aqi'])
                                .withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Column(
                        children: [

                          /// 📍 CITY NAME
                          Text(
                            selectedCity ?? "",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "AQI ${result!['aqi']}",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(result!['status']),

                          const SizedBox(height: 10),

                          Text(
                            "💡 ${ecoTip ?? ""}",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}