import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'api/api_const.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController inputText = TextEditingController();
  final String apikey = apiKey;
  final String url = baseUrl;
  String? image;
  bool isLoading = false;

  void getAIImage() async {
    if (inputText.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("Please enter some text to generate an image."),
            actions: <Widget>[
              TextButton(
                child: const Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() => isLoading = true);

    var data = {
      "prompt": inputText.text,
      "n": 1,
      "size": "256x256",
    };

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $apikey",
          "Content-Type": "application/json"
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          image = jsonResponse['data'][0]['url'];
          isLoading = false;
        });
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Image Generator"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (isLoading) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                  ],
                  if (image != null)
                    Image.network(image!, width: 256, height: 256),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              inputText.clear();
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: inputText,
                decoration: const InputDecoration(
                  hintText: "Enter Text to Generate AI Image",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getAIImage();
          inputText.clear();
        },
        tooltip: 'Generate AI Image',
        child: const Icon(Icons.send),
      ),
    );
  }
}
