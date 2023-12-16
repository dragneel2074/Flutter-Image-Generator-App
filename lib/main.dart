import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ImageGeneratorPage(),
    );
  }
}

class ImageGeneratorPage extends StatefulWidget {
  const ImageGeneratorPage({super.key});

  @override
  _ImageGeneratorPageState createState() => _ImageGeneratorPageState();
}

class _ImageGeneratorPageState extends State<ImageGeneratorPage> {
  final TextEditingController _controller = TextEditingController();
  Uint8List? _imageData;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> generateImage(String prompt) async {
    const String accountId = 'ddddddddd'; // Replace with your account ID
    const String apiToken = 'ddddddddddddd'; // Replace with your API token
    const String url = 'https://api.cloudflare.com/client/v4/accounts/$accountId/ai/run/@cf/stabilityai/stable-diffusion-xl-base-1.0';

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _imageData = response.bodyBytes;
        });
      } else {
        setState(() {
          _errorMessage = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Generator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Enter text',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : () => generateImage(_controller.text),
              child: _isLoading 
                ? const CircularProgressIndicator()
                : const Text('Generate Image'),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            if (_imageData != null)
              Image.memory(_imageData!),
          ],
        ),
      ),
    );
  }
}
