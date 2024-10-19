import 'package:flutter/material.dart';
import 'package:guitabify/record_page.dart';
import 'buttons.dart';
import 'constants.dart';

class HomePage extends StatefulWidget {

  static String id='homePage';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false, // Remove the leading back button
          actions: const [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 8,
                    child: SizedBox(),
                  ),
                  Text(
                    'Login/SignUp',
                    style: kAppBarActionStyle,
                  ),
                  Expanded(
                    flex: 61,
                    child: SizedBox(),
                  ),
                  Text(
                    'Home',
                    style: kAppBarActionStyle,
                  ),
                  Expanded(
                    flex: 4,
                    child: SizedBox(),
                  ),
                  Text(
                    'Recordings',
                    style: kAppBarActionStyle,
                  ),
                  Expanded(
                    flex: 4,
                    child: SizedBox(),
                  ),
                  Text(
                    'Tabs',
                    style: kAppBarActionStyle,
                  ),
                  Expanded(
                    flex: 4,
                    child: SizedBox(),
                  ),
                  Text(
                    'About Me',
                    style: kAppBarActionStyle,
                  ),
                  Expanded(
                    flex: 9,
                    child: SizedBox(),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Container(
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 80,),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 220,),
                  const Image(
                    image: AssetImage('guitabify.png',),
                    height: 50,
                    width: 360,
                    alignment: Alignment.centerLeft,
                  ),


                  const SizedBox(height: 30,),
                  RichText(
                    text: const TextSpan(
                      style: kSubtitleStyle,
                      children: [
                        TextSpan(
                          text: 'Unleash the power of AI to transcribe your\n',
                        ),
                        TextSpan(
                          text: 'Acoustic Guitar',
                          style: TextStyle(color: Color(0xFFD4722B)),
                        ),
                        TextSpan(
                          text: ' melodies into easy-to-\nread tabs!',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100,),
                  Row(
                    children: [
                      Button1(
                        buttonText: 'Start Recording',
                        onPressed: () {
                          Navigator.pushNamed(context, RecordPage.id);
                        },
                      ),
                      const SizedBox(width:30,),
                      Button2(
                        buttonText: ' How it works? ',
                        onPressed: () {
                          // Your onPressed logic here
                        },
                      ),
                    ],
                  ),


                ],
              ),
              const Expanded(child: SizedBox()),
              const Image(
                image: AssetImage('guitar_image.png'),
                height: double.infinity,
              ),
              const SizedBox(width: 162,)
            ],
          ),
        ),
      ),
    );
  }
}



