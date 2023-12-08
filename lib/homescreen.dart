import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'constants.dart' as k;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoaded = false;
  num? temp;
  num? press;
  num? hum;
  num? cover;
  String? cityname;

  final cityController =TextEditingController();

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: EdgeInsets.all(20),
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:[
                Color(0xFF0093E9),
                Color(0xFF80D0C7),
              ] ,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter
              )
              

          ),
          child: Visibility(
            visible: isLoaded,
            replacement: Center(child: CircularProgressIndicator()),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width* .85,
                  height:  MediaQuery.of(context).size.height * .09,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20)
                  ),

                  child: Center(
                    child: TextFormField(
                      onFieldSubmitted: (String s) {
                        setState(() {
                          cityname = s;
                          getCityWeather(cityname ?? "no result");
                          isLoaded = false;
                          cityController.clear();
                        });
                      },
                      controller: cityController,
                      cursorColor: Colors.white,
                      style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600,color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search City',
                        prefixIcon:Icon( Icons.search_rounded,
                        color: Colors.white,),
                        hintStyle: TextStyle(
                          color: Colors.white),
                          border: InputBorder.none
                          ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pin_drop,color: Colors.red,size: 40,),
                      Text(cityname ?? "no result",style: TextStyle(fontSize: 18),overflow: TextOverflow.ellipsis,)
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                Container(
                  padding: EdgeInsets.only(left: 20),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height* 0.12,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(1, 2),blurRadius: 3,spreadRadius: 1
                    )
                  ]
                  ),
                  
                  child: Row(
                    children: [
                      Image(image: AssetImage('images/thermometer.png'),width: MediaQuery.of(context).size.width* .09 ,),
                      SizedBox(width: 20,),
                      Text('Temperature: ${temp!.toInt()} °C')
                    ],
                  ),
                ),
                 Container(
                  padding: EdgeInsets.only(left: 20),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height* 0.12,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(1, 2),blurRadius: 3,spreadRadius: 1
                    )
                  ]
                  ),
                  
                  child: Row(
                    children: [
                      Image(image: AssetImage('images/barometer.png'),width: MediaQuery.of(context).size.width* .09 ,),
                      SizedBox(width: 20,),
                      Text('Pressure: ${press!.toStringAsFixed(2)} hpa')
                    ],
                  ),
                ),
                 Container(
                  padding: EdgeInsets.only(left: 20),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height* 0.12,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(1, 2),blurRadius: 3,spreadRadius: 1
                    )
                  ]
                  ),
                  
                  child: Row(
                    children: [
                      Image(image: AssetImage('images/drop.png'),width: MediaQuery.of(context).size.width* .09 ,),
                      SizedBox(width: 20,),
                      Text('Humidity: ${hum!.toInt()} %')
                    ],
                  ),
                ),
                 Container(
                  padding: EdgeInsets.only(left: 20),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height* 0.12,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(1, 2),blurRadius: 3,spreadRadius: 1
                    )
                  ]
                  ),
                  
                  child: Row(
                    children: [
                      Image(image: AssetImage('images/eclipse.png'),width: MediaQuery.of(context).size.width* .09 ,),
                      SizedBox(width: 20,),
                      Text('Colud Cover: ${cover!.toInt()} %')
                    ],
                  ),
                )
                
              ],
            )),
        ),
      ),
    );
  }
  getCurrentLocation()async{
    var p = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      forceAndroidLocationManager: true);
      print("Latitude:  ${p.latitude} , Longitude: ${p.longitude}");
      getCurrentCityWeather(p);
  }

  getCityWeather(String cityname) async{
    var client = http.Client();
 var uri = '${k.domain}q=$cityname&appid=${k.apiKey}';
 var url = Uri.parse(uri);
 var response = await client.get(url);
 if (response.statusCode == 200) {
   var data = response.body;
   var decodedData = json.decode(data);
   print(data);
   updateUI(decodedData);
   setState(() {
     isLoaded =true;
   });
 }else{
  print(response.statusCode);
 }
  }

  getCurrentCityWeather(Position position)async{
 var client = http.Client();
 var uri = '${k.domain}lat=${position.latitude}&lon=${position.longitude}&appid=${k.apiKey}';
 var url = Uri.parse(uri);
 var response = await client.get(url);
 if (response.statusCode == 200) {
   var data = response.body;
   var decodedData = json.decode(data);
   print(data);
   updateUI(decodedData);
   setState(() {
     isLoaded =true;
   });
 }else{
  print(response.statusCode);
 }
  }

  updateUI(var decodedData){
    setState(() {
      if (decodedData == null) {
      temp = 0 ;
      press = 0;
      hum = 0;
      cover = 0;
      cityname = 'not Available';
    }else{
      temp = decodedData['main']['temp']-273;
      press = decodedData['main']['pressure'];
      hum = decodedData['main']['humidity'];
      cover =decodedData['clouds']['all'];
      cityname = decodedData['name'];
    }
    });
    
  }
  @override
  void dispose() {
    // TODO: implement dispose
    cityController.dispose();
    super.dispose();
  }
}