import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:vortex_iot_app/RoboController/View/RoboControllerJoystick.dart';
import 'package:vortex_iot_app/RoboController/View/breacher_control.dart';
import 'package:vortex_iot_app/RoboController/View/scout_control.dart';

class RoboControllerHomePage extends StatefulWidget {
  RoboControllerHomePage();

  @override
  State<RoboControllerHomePage> createState() => _RoboControllerHomePageState();
}

class _RoboControllerHomePageState extends State<RoboControllerHomePage> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "VORTEX Control",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: SingleChildScrollView(
          child: Column(
            children: [
              //lottie
              Lottie.network(
                'https://assets10.lottiefiles.com/packages/lf20_jcikwtux.json',
                height: height * 0.3,
                fit: BoxFit.contain,
              ),
              //  Breacher Robot Container
              GestureDetector(
                onTap: () {
                  //Joystick BR01
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BreacherControl()),
                  );
                },
                child: Container(
                  height: height * 0.25, // old => 0.32
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2330),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        height: height * 0.13,
                        child: Image.asset(
                          "assets/breacher_png.png", //
                          // height: height * 0.18,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: .start,
                        children: [
                          SizedBox(height: 24),
                          Text(
                            "Breacher Unit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            child: Text(
                              "clearway 🛠️",
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: height * 0.020,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          //Connected Status Container for breacher-----------------
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              //xhexk and swap true false with actual variables
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: true ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    //variable name
                                    true ? Icons.check_circle : Icons.wifi_off,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    //variable name
                                    true ? "Drive" : "Disconnected",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: height * 0.04),

              // Scout Robot Container ------------------
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ScoutControlPage()),
                  );
                },
                child: Container(
                  height: height * 0.25, // old=>0.32
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2330),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        height: height * 0.25,
                        child: Image.asset(
                          "assets/Gemini_Generated_Image_8t9pts8t9pts8t9p.png", //
                          // height: height * 0.18,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: .start,
                        children: [
                          SizedBox(height: 24),
                          Text(
                            "Scout Unit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            child: Text(
                              "Surveillance 🚀",
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: height * 0.020,
                              ),
                            ),
                          ),

                          SizedBox(height: 20),
                          //Connected Status Container
                          GestureDetector(
                            onTap: () {
                              //
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: false ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    //variable name
                                    false
                                        ? Icons.check_circle
                                        : Icons.car_crash,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    //variable name
                                    false ? "Connected" : "Drive",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
