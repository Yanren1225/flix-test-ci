import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

class IntroWelcome extends StatelessWidget {
  final VoidCallback onExplorePressed;

  const IntroWelcome({super.key, required this.onExplorePressed});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
        
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
           
              Expanded(
                child: Row(
                  children: [
                   
                    const Expanded(
                      flex: 1,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Flix，\n像聊天一样传文件。',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: 110,
                            height: 110,
                            child: Image.asset(
                              'assets/images/logo.webp',
                              fit: BoxFit.contain, 
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.only(bottom: 70.0),
                child: SizedBox(
                  width: 310,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      onExplorePressed();  
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0, 122, 255, 1),
                      shadowColor: Colors.transparent,
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 15,
                          cornerSmoothing: 0.6,
                        ),
                      ),
                      minimumSize: const Size(100, 50),
                    ),
                    child: const Text(
                      '开始探索',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 22.0, top: 100),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Flix，\n像聊天一样传文件。',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 110,
                    height: 110,
                    child: Image.asset(
                      'assets/images/logo.webp',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 28.0, right: 28.0, bottom: 70.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      onExplorePressed(); 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0, 122, 255, 1),
                      shadowColor: Colors.transparent,
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 15,
                          cornerSmoothing: 0.6,
                        ),
                      ),
                      minimumSize: const Size(100, 50),
                    ),
                    child: const Text(
                      '开始探索',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
