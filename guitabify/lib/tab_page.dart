import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:guitabify/buttons.dart';
import 'package:guitabify/record_page.dart';
import 'package:http/http.dart' as http; // Add this to handle HTTP requests
import 'package:guitabify/constants.dart';

class TabPage extends StatefulWidget {
  static String id = 'tabPage';
  final String fileName;
  const TabPage({super.key, required this.fileName});

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  List<String> tabs = ["e|--", "B|--", "G|--", "D|--", "A|--", "E|--"];

  bool _isLoading = true;

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

  void updateTab(String input) {
    int index = int.parse(input[0]);
    String value = input[1];

    for (int i = 0; i < tabs.length; i++) {
      if (i == index - 1) {
        tabs[i] += value;
      } else {
        tabs[i] += '-';
      }
    }
  }

  void playNotes(List<String> list1, List<int> list2) {
    for (int i = 0; i < list1.length; i++) {
      // Update the tab with the note
      updateTab(list1[i]);

      // If there's a corresponding time gap in list2, append '-' to all tabs
      if (i < list2.length) {
        for (int j = 0; j < tabs.length; j++) {
          tabs[j] += '-' * list2[i];
        }
      }
    }
    for (int i = 0; i < tabs.length; i++) {
      tabs[i] += '--|';
    }
  }

  Future<void> fetchNotesFromServer(String fileName) async {
    try {
      // Replace with your server's endpoint
      final response = await http
          .get(Uri.parse('https://guitabify-backend.onrender.com/notes?file_name=$fileName'));

      if (response.statusCode == 200) {
        // Decode the response JSON
        final data = json.decode(response.body);
        List<String> list1 = List<String>.from(data['list1']);
        List<int> list2 = List<int>.from(data['list2']);
        // Use setState to update the UI when new data is received
        setState(() {
          playNotes(list1, list2); // This will trigger the update to the tabs
        });
      } else {
        print('Failed to load notes');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      // Set loading to false once the request is complete
      setState(() {
        _isLoading =
            false; // <-- Modification: set _isLoading to false after request
      });
    }
  }

  Future<void> deleteAudio(BuildContext context, String fileName) async {
    try {
      // Show loading indicator
      showLoadingDialog(context);

      // Send DELETE request to the server with the file name as a query parameter
      final response = await http.delete(
        Uri.parse('https://guitabify-backend.onrender.com/delete?file_name=$fileName'),
      );

      if (response.statusCode == 200) {
        print('File deleted successfully');
        // Close the loading dialog and display success message
        Navigator.pop(context); // Close the loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File deleted successfully')),
        );
      } else if (response.statusCode == 404) {
        print('File not found');
        Navigator.pop(context); // Close the loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File not found')),
        );
      } else {
        print('Failed to delete file');
        Navigator.pop(context); // Close the loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete file')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close the loading dialog on error
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotesFromServer(
        widget.fileName); // Fetch data from the backend on initialization
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
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 80,
                    ),
                    Text(
                      'Tabs',
                      style: kSubtitleStyle,
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    _isLoading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Container(
                            padding: EdgeInsets.all(24),
                            color: Colors.white,
                            child: Text(tabs.join('\n'), style: kTabStyle),
                          ),
                    SizedBox(
                      height: 32,
                    ),
                    Row(
                      children: [
                        Button2(
                            buttonText: "Record",
                            onPressed: () {
                              deleteAudio(context, widget.fileName);
                              Navigator.pop(context);
                            }),
                        Button1(buttonText: "Save", onPressed: () {})
                      ],
                    )
                  ],
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image(
                    image: AssetImage('guitar_image_faded.png'),
                    height: double.infinity,
                  ),
                  SizedBox(width: 162)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
