import 'package:flutter/material.dart';

class EmptyEventScreen extends StatelessWidget {
  const EmptyEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF132054),
              Color(0xFF2B478A),
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Event',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
                actions: const [
                  IconButton(
                    icon: Icon(
                      Icons.bookmark_border_outlined,
                      color: Colors.white,
                    ),
                    onPressed: null,
                  ),
                ],
              ),
              // Empty State Content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Calendar Icon
                      Image.asset(
                        'assets/icons/event_calendar.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 24),
                      // Empty Message
                      const Text(
                        'No Upcoming Event',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
