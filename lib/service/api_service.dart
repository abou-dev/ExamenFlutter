import 'package:retrofit/http.dart';
import 'package:dio/dio.dart';
import 'package:examflutter2/models/post_model.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: 'https://api.openweathermap.org/data/2.5/')
abstract class WeatherService {
  factory WeatherService(Dio dio, {String baseUrl}) = _WeatherService;

  @GET('weather')
  Future<WeatherData> getWeatherData(
      @Query('q') String city,
      @Query('appid') String apiKey,
      @Query('units') String units,
      );
}
