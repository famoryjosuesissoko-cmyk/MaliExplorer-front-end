import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_loader.dart';

/// Lecteur immersif de panoramas 360° pour les sites historiques du Mali.
class Galerie360Screen extends StatefulWidget {
  final String panoramaUrl;

  const Galerie360Screen({super.key, required this.panoramaUrl});

  @override
  State<Galerie360Screen> createState() => _Galerie360ScreenState();
}

class _Galerie360ScreenState extends State<Galerie360Screen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) setState(() => _isLoading = false);
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.panoramaUrl));
    } else {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.threesixty, color: AppColors.sahelGold),
            SizedBox(width: 8),
            Text('Visite Panoramique 360°'),
          ],
        ),
        backgroundColor: Colors.black87,
      ),
      body: Stack(
        children: [
          if (!kIsWeb)
            WebViewWidget(controller: _controller)
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.threesixty, size: 80, color: AppColors.sahelGold),
                  const SizedBox(height: 16),
                  const Text(
                    'Visualisation 360°',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      widget.panoramaUrl,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          if (_isLoading)
            const Center(
              child: AppLoader(message: 'Chargement du panorama immersif...'),
            ),
        ],
      ),
    );
  }
}
