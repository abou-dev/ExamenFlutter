import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'models/post_model.dart';
import 'service/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Examen Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Image de fond
          Image.asset(
            'assets/background_image.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animation
                ScaleTransition(
                  scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                    CurvedAnimation(
                      parent: const AlwaysStoppedAnimation(1),
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 150,
                    height: 150,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Bienvenue !',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  ProgressScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Commencer',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressScreen extends StatefulWidget {


  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  double _progressValue = 0.0;
  Timer? _timer;

  final List<String> _messages = [
    'Nous téléchargeons les données...',
    'C\'est presque fini...',
    'Plus que quelques secondes avant d\'avoir le résultat...',
  ];

  final List<WeatherData> _weatherData = [];
  late WeatherService _weatherService;
  Dio dio = Dio();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoadingComplete = false;
  int _messageIndex = 0;
  ValueSetter<double>? _progressCallback;
  @override
  void initState() {
    super.initState();
    _messages[_messageIndex] = _messages[0];
    _startTimer();
    _weatherService = WeatherService(dio);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _fetchWeatherData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }


  void _startTimer() {
    const duration = Duration(seconds: 6);
    _timer = Timer.periodic(duration, (timer) {
      if (!mounted) {
        timer.cancel(); // Arrêter le temporisateur s'il n'y a plus de widget monté
        return;
      }

        setState(() {
        _messageIndex = (_messageIndex + 1) % _messages.length;
      });

    });
  }

  void _restartLoading() {
    _progressValue = 0.0;
    _messageIndex = 0;
    _weatherData.clear();
    _animationController.reset();
    _startTimer();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    const cities = ['Dubai', 'Paris', 'Washington', 'Dakar', 'Garoua'];
    for (int i = 0; i < cities.length; i++) {
      await Future.delayed(const Duration(seconds: 10), () async {
        try {
          final response = await _weatherService.getWeatherData(
            cities[i],
            'a7d48ce7ccd9931db78a54356beb48e8', // Replace with your OpenWeatherMap API key
            'metric',
          );
          final weatherData = WeatherData(
            city: response.city,
            temperature: response.temperature,
            cloudCover: response.cloudCover,
            weatherList: response.weatherList,
          );
          _weatherData.add(weatherData);
        } catch (e) {
          print('Erreur lors de la récupération des données météo : $e');
        }
        if (mounted) {
          setState(() {
            _progressValue = (i + 1) / cities.length.toDouble();
            _isLoadingComplete = true;
           // Set the progress value to 1.0 when all cities have been fetched
            _animationController.forward();
            _progressCallback?.call(_progressValue);

          });
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    double percentage = _progressValue * 100;
    String progressText = '${percentage.toStringAsFixed(1)}%';



    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45.0),
        child: AppBar(
          title: const Text('Affichage de la météo'),
          backgroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         if(_progressValue<1)
          Container(
            height: 25,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 2000),
                  curve: Curves.easeInOut,
                  width: _progressValue * MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.deepPurpleAccent,
                  ),
                ),
                Center(
                  child: Opacity(
                    opacity: _progressValue == 1.0 ? 0.0 : 1.0,
                    child: Text(
                      progressText,
                      style: const TextStyle(
                        fontSize: 16,
                        //color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if(_progressValue<1)
          Text(
            _messages[_messageIndex],
            style: const TextStyle(fontSize: 18,color : Colors.white),
          ),
          if (_progressValue >= 1.0 && _isLoadingComplete)
            AnimatedOpacity(
              opacity: _fadeAnimation.value,
              duration: const Duration(milliseconds: 500),
              child: const Text(
                'Météo des villes',
                style: TextStyle(
                  fontSize: 24,color : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.builder(
              itemCount: _weatherData.length,
              itemBuilder: (context, index) {
                final weather = _weatherData[index];
                if (weather.weatherList.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: AssetImage(
                            _getWeatherImage(weather.weatherList[0].main),
                          ),
                          fit: BoxFit.cover,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  weather.city,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${weather.temperature.toStringAsFixed(1)}°C',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Cloud cover: ${weather.cloudCover}%',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          if (_progressValue >= 1.0)
            ElevatedButton(
              onPressed: _restartLoading,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Recommencer',
                style: TextStyle(fontSize: 18),
              ),
            ),
        ],
      ),
    );
  }


  String _getWeatherImage(String weather) {
    switch (weather) {
      case 'Clear':
        return 'assets/sunny.jpg';
      case 'Clouds':
        return 'assets/cloudy.jpg';
      case 'Rain':
        return 'assets/rainy.jpg';
      case 'Snow':
        return 'assets/snowy.jpg';
      case 'Thunderstorm':
        return 'assets/thunderstorm.jpg';
      default:
        return 'assets/default.jpg';
    }
  }
}
