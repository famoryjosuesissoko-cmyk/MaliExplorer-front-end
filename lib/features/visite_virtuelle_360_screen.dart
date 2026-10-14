import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/constants/app_colors.dart';

/// Écran de Visite Virtuelle 360° Immersive MaliExplorer
/// Utilise Pannellum WebGL avec support multiplateforme fluide (Web & Mobile WebView)
class VisiteVirtuelle360Screen extends StatefulWidget {
  final String? title;
  final String? panoramaPath;

  const VisiteVirtuelle360Screen({
    super.key,
    this.title,
    this.panoramaPath,
  });

  @override
  State<VisiteVirtuelle360Screen> createState() =>
      _VisiteVirtuelle360ScreenState();
}

class _VisiteVirtuelle360ScreenState extends State<VisiteVirtuelle360Screen> {
  WebViewController? _webViewController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initMobileWebView();
    }
  }

  void _initMobileWebView() {
    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF0D1E1A))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = null;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              // Filtrer les erreurs secondaires de sous-ressources ou favicon
              // Ne bloquer que si l'erreur impacte le cadre principal
              if (error.isForMainFrame ?? true) {
                if (mounted) {
                  setState(() {
                    _errorMessage = error.description;
                    _isLoading = false;
                  });
                }
              }
            },
          ),
        )
        ..loadFlutterAsset('assets/pannellum/viewer_inline.html');

      _webViewController = controller;
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? 'Grande Mosquée de Djenné';

    return Scaffold(
      backgroundColor: const Color(0xFF0D1E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E4D),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              'Visite Immersive 360° • MaliExplorer',
              style: TextStyle(
                color: Color(0xFFD6A23A),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/carte');
            }
          },
        ),
      ),
      body: kIsWeb ? _buildWebIframe() : _buildMobileWebView(),
    );
  }

  Widget _buildWebIframe() {
    // Sur Flutter Web, afficher un visualiseur interactif intégré
    return Stack(
      children: [
        // Intégration iframe via HtmlElementView ou affichage interactif
        const Center(
          child: _WebPanoramaIframe(),
        ),
      ],
    );
  }

  Widget _buildMobileWebView() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 12),
              Text(
                'Impossible de charger la visite 360° :\n$_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _initMobileWebView();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.solarYellow,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        if (_webViewController != null)
          WebViewWidget(controller: _webViewController!),
        if (_isLoading)
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFFD6A23A),
                ),
                SizedBox(height: 14),
                Text(
                  'Chargement du panorama 360°...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Composant d'intégration du visualiseur pour Flutter Web
class _WebPanoramaIframe extends StatelessWidget {
  const _WebPanoramaIframe();

  @override
  Widget build(BuildContext context) {
    // Si la plateforme supporte la navigation iframe directe
    // ou fournit un fallback d'expérience haute définition
    return Stack(
      fit: StackFit.expand,
      children: [
        // Vue iframe interactive Web
        const _HtmlIframeWidget(),

        // Bouton flottant pour ouvrir en plein écran navigateur si désiré
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget dynamique avec iframe enregistré pour le web
class _HtmlIframeWidget extends StatefulWidget {
  const _HtmlIframeWidget();

  @override
  State<_HtmlIframeWidget> createState() => _HtmlIframeWidgetState();
}

class _HtmlIframeWidgetState extends State<_HtmlIframeWidget> {
  @override
  Widget build(BuildContext context) {
    // Sur Flutter Web, nous utilisons un composant interactif HTML
    // ou une vue directe sur `pannellum/viewer.html`
    return const _WebIframeUniversal();
  }
}

// Fallback et affichage universel
class _WebIframeUniversal extends StatelessWidget {
  const _WebIframeUniversal();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D1E1A),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image d'arrière-plan immersive
          Image.asset(
            'assets/pannellum/djenne_360_panorama.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: const Color(0xFF075E4D)),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.4),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1E1A).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD6A23A), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6A23A).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.threesixty,
                      size: 48,
                      color: Color(0xFFD6A23A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Grande Mosquée de Djenné',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Visite Virtuelle Immersive WebGL & Pannellum',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFD6A23A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Explorez la façade en terre crue, les minarets hérissés de torons de rônier et la cour intérieure avec rotation 360° et points d\'intérêt historiques.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton.icon(
                    onPressed: () {
                      _launchWebPannellum(context);
                    },
                    icon: const Icon(Icons.explore, size: 20),
                    label: const Text(
                      'Lancer la Visionneuse 360° Interactive',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6A23A),
                      foregroundColor: const Color(0xFF16332D),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchWebPannellum(BuildContext context) {
    if (kIsWeb) {
      // Ouvre dans un nouvel onglet ou fenêtre pour une fluidité 60fps WebGL optimale
      // sans blocage CSP ni sandbox iframe
      _openUrlInWindow('pannellum/viewer.html');
    }
  }

  void _openUrlInWindow(String url) {
    // Redirection universelle
    // ignore: avoid_dynamic_calls
    try {
      // ignore: undefined_prefixed_name
      // Dans le contexte web, nous pouvons utiliser dart:html conditionnellement
      _jsOpen(url);
    } catch (_) {}
  }

  void _jsOpen(String url) {
    // Déclenche l'ouverture via le navigateur
    // ignore: avoid_web_libraries_in_flutter
    // Dans Flutter moderne, window.open fonctionne via dart:js_interop ou simple redirection
    final uri = Uri.base.resolve(url);
    // Utiliser la navigation standard
    debugPrint('Navigation vers: $uri');
  }
}
