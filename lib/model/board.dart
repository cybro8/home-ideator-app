class Board {
  String key;
  String current;
  String power;
  String voltage;
  String website;
  String name;

  Board(this.key, this.current, this.power, this.voltage, this.website, this.name);

  Board.fromJson(Map<String, dynamic> json)
      : key = json['device_id']?.toString() ?? '',
        current = (json['Current'] ?? 0).toString(),
        power = (json['Power'] ?? 0).toString(),
        voltage = (json['Voltage'] ?? 0).toString(),
        name = (json['device_name'] ?? '').toString(),
        website = '';

  Map<String, dynamic> toJson() {
    return {
      'Current': current,
      'Power': power,
      'Voltage': voltage,
      'device_name': name,
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