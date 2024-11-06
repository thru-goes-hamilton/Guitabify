import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guitabify/buttons.dart';
import 'package:guitabify/tab_page.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'constants.dart';
import 'package:microphone/microphone.dart';

enum AudioState { recording, stop, play }

class RecordPage extends StatefulWidget {
  static String id = 'recordPage';
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  AudioState? audioState;
  late MicrophoneRecorder _recorder;
  late AudioPlayer _audioPlayer;

  IconData getIcon(AudioState? state) {
    switch (state) {
      case AudioState.play:
        return Icons.play_arrow;
      case AudioState.stop:
        return Icons.stop;
      case AudioState.recording:
        return Icons.pause;
      default:
        return Icons.mic;
    }
  }

  String fileName = "";
  void handleAudioState(AudioState? state) {
    setState(() {
      if (audioState == null) {
        // Starts recording
        audioState = AudioState.recording;
        _recorder.start();
        // Finished recording
      } else if (audioState == AudioState.recording) {
        audioState = AudioState.play;
        _recorder.stop();
        // Play recorded audio
      } else if (audioState == AudioState.play) {
        audioState = AudioState.stop;
        _audioPlayer = AudioPlayer();
        _audioPlayer.setUrl(_recorder.value.recording!.url).then((_) {
          return _audioPlayer.play().then((_) {
            setState(() {
              audioState = AudioState.play;
            });
          });
        });
        // Stop recorded audio
      } else if (audioState == AudioState.stop) {
        audioState = AudioState.play;
        _audioPlayer.stop();
      }
    });
  }

  String generateRandomFileName() {
    const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    String randomString =
        List.generate(4, (index) => chars[random.nextInt(chars.length)]).join();
    return 'recording_$randomString.wav';
  }

// Upload Audio with Loading Indicator and Navigation
  Future<void> uploadAudio(BuildContext context) async {
    try {
      // Show loading indicator
      showLoadingDialog(context);

      // Select the audio file using file picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null) {
        // Get the file
        var file = result.files.single;
        fileName = file.name;

        // Create a multipart request
        var request = http.MultipartRequest(
            'POST', Uri.parse('https://guitabify-backend.onrender.com/upload'));

        // Attach file as bytes
        request.files.add(
          http.MultipartFile.fromBytes('audio', file.bytes!,
              filename: file.name),
        );

        // Send the request
        var response = await request.send();
        print('Status Code: ${response.statusCode}');

        if (response.statusCode == 200) {
          print('File uploaded successfully');
          // Navigate to next page
          Navigator.pop(context); // Close the loading dialog
        } else {
          print('Failed to upload file');
          Navigator.pop(context); // Close the loading dialog
        }
      } else {
        Navigator.pop(context); // Close the loading dialog if canceled
      }
    } catch (e) {
      Navigator.pop(context); // Close the loading dialog on error
      print('Error: $e');
    }
  }

// Upload Recorded Audio with Loading Indicator and Navigation
  Future<void> uploadRecordedAudio(BuildContext context) async {
    try {
      // Show loading indicator
      showLoadingDialog(context);

      // Get the recorded bytes
      final bytes = await _recorder.toBytes();

      if (bytes == null || bytes.isEmpty) {
        print("No audio recorded");
        Navigator.pop(context); // Close the loading dialog
        return;
      }

      fileName = generateRandomFileName();
      // Create a multipart request
      var uri = Uri.parse('https://guitabify-backend.onrender.com/upload');
      var request = http.MultipartRequest('POST', uri);

      // Add the audio bytes to the request (using random1 as filename for now)
      var multipartFile = http.MultipartFile.fromBytes(
        'audio',
        bytes,
        filename: fileName,
        contentType: MediaType('audio', 'mpeg'),
      );

      request.files.add(multipartFile);

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        print('Audio uploaded successfully');
        Navigator.pop(context); // Close the loading dialog
      } else {
        print('Failed to upload audio');
        Navigator.pop(context); // Close the loading dialog
      }
    } catch (e) {
      Navigator.pop(context); // Close the loading dialog on error
      print('Error: $e');
    }
  }

// Show Loading Dialog (overlay with dark background and spinner)
  void showLoadingDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false, // Prevent dismissing by tapping outside
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async =>
              false, // Prevent back button press during loading
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _recorder = MicrophoneRecorder()..init();
  }

  @override
  void dispose() {
    super.dispose();
    _recorder.dispose();
  }

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
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(64.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 80,
                            ),
                            const Text(
                              'Record audio',
                              style: kSubtitleStyle,
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            Row(
                              children: [
                                FloatingActionButton(
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    getIcon(audioState),
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    handleAudioState(audioState);
                                  },
                                ),
                                SizedBox(
                                  width: 24,
                                ),
                                if (audioState == AudioState.play ||
                                    audioState == AudioState.stop)
                                  FloatingActionButton(
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.replay,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          audioState = null;
                                          _recorder.dispose();
                                          _recorder = MicrophoneRecorder()
                                            ..init();
                                        });
                                      })
                              ],
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            Button1(
                              buttonText: 'Upload',
                              onPressed: () {
                                uploadRecordedAudio(context);
                                // Navigator.pushNamed(context, TabPage.id);
                              },
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 80,
                            ),
                            Text(
                              'Upload file (.mp3, .wav)',
                              style: kSubtitleStyle,
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            Button1(
                              buttonText: 'Upload audio',
                              onPressed: () {
                                uploadAudio(context);
                              },
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    SizedBox(
                      height: 30,
                    ),
                    Button1(
                        buttonText: "Transcribe",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TabPage(fileName: fileName),
                            ),
                          );
                        })
                  ],
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image(
                    image: AssetImage('images/guitar_image_faded.png'),
                    height: double.infinity,
                  ),
                  SizedBox(
                    width: 162,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
