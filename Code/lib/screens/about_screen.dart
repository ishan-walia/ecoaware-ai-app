import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About"), backgroundColor: Colors.green),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.eco, size: 80, color: Colors.green),

              SizedBox(height: 20),

              Text(
                "EcoAware AI",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              Text(
                "AI Environmental Awareness App",
                style: TextStyle(fontSize: 18),
              ),

              SizedBox(height: 30),

              Text("Student Name:", style: TextStyle(fontSize: 18)),

              Text(
                "Ishan Walia",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 20),

              Text("Project:", style: TextStyle(fontSize: 18)),

              Text(
                "EcoAware AI",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
