import 'package:firebase_database/firebase_database.dart';

class Board {
  String key;
  String current;
  String power;
  String voltage;
  String website;
  String name;

  // BUG FIX 1: key was missing from the primary constructor — it was only set
  // in fromSnapshot, leaving key == null for direct instantiation.
  Board(this.key, this.current, this.power, this.voltage, this.website, this.name);

  // BUG FIX 2: snapshot values can be null when a Firebase node is incomplete.
  // Added null-aware fallbacks (`?? ''`) to prevent null-dereference crashes at runtime.
  Board.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key ?? '',
        current = (snapshot.value['Current'] ?? '').toString(),
        power = (snapshot.value['Power'] ?? '').toString(),
        voltage = (snapshot.value['Voltage'] ?? '').toString(),
        name = (snapshot.value['Name'] ?? '').toString(),
        website = (snapshot.value['Website'] ?? '').toString();

  Map&lt;String, dynamic&gt; toJson() {
    return {
      'Current': current,
      'Power': power,
      'Voltage': voltage,
      'Website': website,
      'Name': name,
    };
  }

  // IMPROVEMENT: copyWith for clean immutable-style updates in _onEntryChanged.
  Board copyWith({
    String key,
    String current,
    String power,
    String voltage,
    String website,
    String name,
  }) {
    return Board(
      key ?? this.key,
      current ?? this.current,
      power ?? this.power,
      voltage ?? this.voltage,
      website ?? this.website,
      name ?? this.name,
    );
  }

  @override
  String toString() =>
      'Board(key: $key, name: $name, voltage: $voltage, current: $current, power: $power)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Board && key == other.key;

  @override
  int get hashCode => key.hashCode;
}