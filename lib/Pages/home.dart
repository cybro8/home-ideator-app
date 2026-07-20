import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:home_ideator_app/model/board.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

// BUG FIX 1: Removed the erroneous top-level `void main()` that would
// re-run the app as a standalone widget when this file was imported.
// Home is used as a tab widget inside Dashboard — it must NOT be a full app.

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // BUG FIX 2: Removed nested MaterialApp. Wrapping a tab widget in another
    // MaterialApp breaks navigation (Navigator.of(context) becomes a new,
    // isolated navigator that cannot pop back to the parent route tree).
    return MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State&lt;MyHomePage&gt; {
  List&lt;Board&gt; boardMessages = [];
  Board board;
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final GlobalKey&lt;FormState&gt; formKey = GlobalKey&lt;FormState&gt;();
  DatabaseReference databaseReference;
  bool _loading = true;
  String _error;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // BUG FIX 3: Board primary constructor now requires key as first argument.
    board = Board('', '', '', '', '', '');
    _inputData();
  }

  Future&lt;void&gt; _inputData() async {
    try {
      final FirebaseUser user = await _auth.currentUser();
      if (user == null) {
        setState(() {
          _error = 'No user signed in.';
          _loading = false;
        });
        return;
      }
      final String uid = user.uid;
      databaseReference =
          database.reference().child('user').child(uid);
      databaseReference.onChildAdded.listen(_onEntryAdded);
      databaseReference.onChildChanged.listen(_onEntryChanged);
      setState(() => _loading = false);
    } catch (e) {
      // BUG FIX 4: `e.print("Fine")` is not a valid Dart method on Exception.
      // Replaced with `print(e.toString())` and stored the error for the UI.
      print(e.toString());
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // BUG FIX 5: `_onEntryChanged` would throw a StateError if the key was not
  // found (singleWhere throws when no element matches). Added orElse guard.
  void _onEntryAdded(Event event) {
    setState(() {
      boardMessages.add(Board.fromSnapshot(event.snapshot));
    });
  }

  void _onEntryChanged(Event event) {
    final Board oldEntry = boardMessages.firstWhere(
      (entry) =&gt; entry.key == event.snapshot.key,
      orElse: () =&gt; null,
    );
    if (oldEntry == null) return;
    setState(() {
      boardMessages[boardMessages.indexOf(oldEntry)] =
          Board.fromSnapshot(event.snapshot);
    });
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
    if (databaseReference == null) {
      return const Center(child: Text('No data reference available.'));
    }

    return Scaffold(
      body: Column(
        children: &lt;Widget&gt;[
          const SizedBox(height: 20),
          Flexible(
            child: FirebaseAnimatedList(
              query: databaseReference,
              itemBuilder: (_, DataSnapshot snapshot,
                  Animation&lt;double&gt; animation, int index) {
                final Board item = boardMessages.length &gt; index
                    ? boardMessages[index]
                    : Board.fromSnapshot(snapshot);

                // BUG FIX 6: The percent values for the circular indicators
                // were hardcoded (0.25, 0.5, 0.01). They must be clamped 0–1
                // and derived from the actual sensor readings.
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
                      children: &lt;Widget&gt;[
                        Text(
                          item.name,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: &lt;Widget&gt;[
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
                            // BUG FIX 7: url_launcher `launch()` is deprecated.
                            // Replaced with canLaunch guard + launch pattern
                            // to avoid unchecked URL opens.
                            onPressed: () async {
                              final String url = item.website;
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Could not open link.')),
                                );
                              }
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

  /// Parses a numeric string and returns a fraction clamped to [0.0, 1.0].
  double _parsePercent(String value, {double maxValue = 100}) {
    if (value == null || value.isEmpty) return 0.0;
    final double parsed = double.tryParse(value) ?? 0.0;
    return (parsed / maxValue).clamp(0.0, 1.0);
  }
}

