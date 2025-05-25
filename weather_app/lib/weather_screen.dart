import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/Additional_info.dart';
import 'package:weather_app/weather_forcast.dart';

class weather_screen extends StatefulWidget {
  const weather_screen({super.key});

  @override
  State<weather_screen> createState() => _weather_screenState();
}

class _weather_screenState extends State<weather_screen> {


  late Future<Map<String, dynamic>> w_data;



  Future<Map<String,dynamic>> getWeatherData() async {
    // Simulate a network call
    try {

      final res = await http.get(
          Uri.parse(
              'http://api.weatherstack.com/forecast?access_key=8db231d05d0321473e603b979ed06a2f&query=kolkata')
      );
      final data= jsonDecode(res.body);
      if (res.statusCode != 200) {
        throw Exception('Failed to load weather data');

      }
      return data;
    }
    catch(e)
    {
      throw e.toString();
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    w_data=getWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [IconButton(onPressed: () {
          setState(() {
            w_data= getWeatherData();
          });
        }, icon: Icon(Icons.refresh))],
      ),
      body:
      FutureBuilder(
        future: w_data,
        builder:(context,snapshot) {
          if (snapshot.connectionState==ConnectionState.waiting)
            {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
          if (snapshot.hasError)
            {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
           }
          final data = snapshot.data;
          final forecastMap = snapshot.data!['forecast'] as Map<String, dynamic>;
          final forecastEntries = forecastMap.entries.toList();
          final current_tmp = data ?['current']['temperature'];
          final current_sky = data ?['current']['weather_descriptions'][0];
          final current_humidity = data ?['current']['humidity'];
          final current_wind_speed = data ?['current']['wind_speed'];
          final current_pressure = data ?['current']['pressure'];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: Colors.grey.withOpacity(0.2),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              '$current_tmp °C',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Icon(current_sky=='Cloud'|| current_sky=='Rain'?
                                  Icons.cloud:
                                  Icons.sunny
                                , size: 64),
                            const SizedBox(height: 8),
                            Text(
                              '$current_sky',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Weather Forecast',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                /*
                using loop
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for(int i=0; i<1; i++)
                        hourlyForcast(
                          day: ,
                          icon: Icons.cloud,
                          temperature: '300.12',
                        ),


                    ],
                  ),
                ),*/

                SizedBox(
                  height: 120,
                  child: ListView.builder(
                  itemCount: forecastEntries.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context,index) {

                    final entry = forecastEntries[index];
                    final date = entry.key;
                    final dayData = entry.value;

                    return hourlyForcast(
                        day: date,
                        icon:  dayData['avgtemp'] > 30
                            ? Icons.sunny
                            : dayData['avgtemp'] > 20
                                ? Icons.hail
                                : Icons.cloud,
                        temperature: '${dayData['avgtemp']} °C');
                  }
                  ),
                ),

                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Additional Information',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfo(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: '$current_humidity %',
                    ),
                    AdditionalInfo(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: '$current_wind_speed km/h',
                    ),
                    AdditionalInfo(
                      icon: Icons.thermostat,
                      label: 'Pressure',
                      value: '$current_pressure hPa',
                    ),
                  ],
                ),
              ],
            ),
          );

        }
      ),
    );
  }
}
