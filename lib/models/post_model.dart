import 'package:json_annotation/json_annotation.dart';

part 'post_model.g.dart';

@JsonSerializable()
class WeatherData {
  final String city;
  final double temperature;
  final String cloudCover;
  final List<Weather> weatherList;

  WeatherData({
    required this.city,
    required this.temperature,
    required this.cloudCover,
    required this.weatherList,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      city: json['name'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble() ?? 0.0,
      cloudCover: json['weather'][0]['main'] ?? '',
      weatherList: (json['weather'] as List<dynamic>?)
          ?.map((e) => Weather.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => _$WeatherDataToJson(this);
}

@JsonSerializable()
class Weather {
  final String main;

  Weather({required this.main});

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherToJson(this);
}
