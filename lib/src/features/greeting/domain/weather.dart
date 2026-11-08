import 'package:flutter/foundation.dart';

@immutable
class City {
  const City({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.admin1,
  });

  factory City.fromMap(Map<String, dynamic> m) => City(
    name: m['name'] as String,
    country: (m['country'] as String?) ?? '',
    latitude: (m['latitude'] as num).toDouble(),
    longitude: (m['longitude'] as num).toDouble(),
    admin1: m['admin1'] as String?,
  );

  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String? admin1;

  Map<String, Object?> toMap() => {
    'name': name,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
  };

  @override
  bool operator ==(Object other) =>
      other is City &&
      other.name == name &&
      other.country == country &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.admin1 == admin1;

  @override
  int get hashCode => Object.hash(name, country, latitude, longitude, admin1);
}

@immutable
class WeatherNow {
  const WeatherNow({
    required this.temperatureC,
    required this.weatherCode,
    required this.fetchedAt,
    required this.cityName,
  });

  factory WeatherNow.fromMap(Map<String, dynamic> m) => WeatherNow(
    temperatureC: (m['temperatureC'] as num).toDouble(),
    weatherCode: m['weatherCode'] as int,
    fetchedAt: DateTime.fromMillisecondsSinceEpoch(
      m['fetchedAtEpochMs'] as int,
    ),
    cityName: m['cityName'] as String,
  );

  final double temperatureC;
  final int weatherCode;
  final DateTime fetchedAt;
  final String cityName;

  Map<String, Object?> toMap() => {
    'temperatureC': temperatureC,
    'weatherCode': weatherCode,
    'fetchedAtEpochMs': fetchedAt.millisecondsSinceEpoch,
    'cityName': cityName,
  };

  @override
  bool operator ==(Object other) =>
      other is WeatherNow &&
      other.temperatureC == temperatureC &&
      other.weatherCode == weatherCode &&
      other.fetchedAt == fetchedAt &&
      other.cityName == cityName;

  @override
  int get hashCode =>
      Object.hash(temperatureC, weatherCode, fetchedAt, cityName);
}
