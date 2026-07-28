import 'dart:async';
import 'package:home_ideator_app/model/board.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:home_ideator_app/services/api_service.dart';
import 'package:home_ideator_app/services/auth_state.dart';
import 'package:home_ideator_app/Setup/signin.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Board> boardMessages = [];
  bool _loading = true;
  String _error;
  Timer _pollingTimer;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initData() async {
    try {
      final isLoggedIn = await AuthState.isLoggedIn();
      if (!isLoggedIn) {
        if (mounted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => LoginPage()));
        }
        return;
      }
      await _fetchDevices();
      _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        _pollDeviceData();
      });
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _fetchDevices() async {
    final devices = await ApiService.getMyDevices();
    List<Board> initialBoards = [];
    for (var device in devices) {
      initialBoards.add(Board.fromJson(device));
    }
    setState(() {
      boardMessages = initialBoards;
    });
    await _pollDeviceData();
  }

  Future<void> _pollDeviceData() async {
    if (boardMessages.isEmpty) return;
    for (int i = 0; i < boardMessages.length; i++) {
      try {
        final data = await ApiService.getDeviceData(boardMessages[i].key, limit: 1);
        if (data.isNotEmpty) {
          final reading = data[0];
          setState(() {
            final merged = Map<String, dynamic>.from(reading);
            merged['device_name'] = boardMessages[i].name;
            boardMessages[i] = Board.fromJson(merged);
          });
        }
      } catch (e) {
        print('Error polling device ${boardMessages[i].key}: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error: $_error',
              style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    if (boardMessages.isEmpty) {
      return const Center(child: Text('No devices found.'));
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          Flexible(
            child: ListView.builder(
              itemCount: boardMessages.length,
              itemBuilder: (_, int index) {
                final Board item = boardMessages[index];

                final double voltagePercent =
                    _parsePercent(item.voltage, maxValue: 240);
                final double currentPercent =
                    _parsePercent(item.current, maxValue: 16);
                final double powerPercent =
                    _parsePercent(item.power, maxValue: 3840);

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          item.name,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            CircularPercentIndicator(
                              radius: 70.0,
                              lineWidth: 7.0,
                              percent: voltagePercent,
                              animation: true,
                              animationDuration: 1000,
                              center: Text('${item.voltage}V',
                                  style: const TextStyle(fontSize: 11)),
                              progressColor: Colors.green,
                              header: const Text('Voltage',
                                  style: TextStyle(fontSize: 11)),
                            ),
                            CircularPercentIndicator(
                              radius: 70.0,
                              lineWidth: 7.0,
                              percent: currentPercent,
                              animation: true,
                              animationDuration: 1000,
                              center: Text('${item.current}A',
                                  style: const TextStyle(fontSize: 11)),
                              progressColor: Colors.redAccent,
                              header: const Text('Current',
                                  style: TextStyle(fontSize: 11)),
                            ),
                            CircularPercentIndicator(
                              radius: 70.0,
                              lineWidth: 7.0,
                              percent: powerPercent,
                              animation: true,
                              animationDuration: 1000,
                              center: Text('${item.power}W',
                                  style: const TextStyle(fontSize: 11)),
                              progressColor: Colors.blueAccent,
                              header: const Text('Power',
                                  style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Go to Shop to find replacements!')),
                              );
                            },
                            child: const Text('Replace Component'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _parsePercent(String value, {double maxValue = 100}) {
    if (value == null || value.isEmpty) return 0.0;
    final double parsed = double.tryParse(value) ?? 0.0;
    return (parsed / maxValue).clamp(0.0, 1.0);
  }
}
