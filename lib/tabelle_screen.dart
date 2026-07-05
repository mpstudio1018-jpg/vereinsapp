import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TabelleScreen extends StatefulWidget {
  const TabelleScreen({super.key});

  @override
  State<TabelleScreen> createState() => _TabelleScreenState();
}

class _TabelleScreenState extends State<TabelleScreen> {
  WebViewController? _controller;

  bool get _isWebViewSupported {
    return !kIsWeb && (
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS
    );
  }

  @override
  void initState() {
    super.initState();

    // Hier ist dein exakter Fussball.de-Code eingebaut:
    const String fussballDeHtml = '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          <style>
            body { 
              margin: 0; 
              padding: 8px; 
              font-family: sans-serif; 
              background-color: #ffffff; 
            }
          </style>
        </head>
        <body>

          <!-- DEIN FUSSBALL.DE CODE START -->
          <script 
            type="text/javascript" 
            src="https://www.fussball.de/widgets.js">
          </script>

          <div 
            class="fussballde_widget"
            data-id="3f92fdca-ae7d-413a-88f4-b3e124461771"
            data-type="table"
            style="width: 100%"
          ></div>
          <!-- DEIN FUSSBALL.DE CODE ENDE -->

        </body>
      </html>
    ''';

    if (_isWebViewSupported) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..loadHtmlString(fussballDeHtml);
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('CJGL Kassel Dashboard'),
      backgroundColor: const Color(0xFF1E5631), // Beispiel für ein sattes Fußball-Grün
    ),
    // SafeArea sorgt dafür, dass nichts in die Notch oder Statusleiste rutscht
    body: SafeArea(
      child: Column(
        children: [
          
          // (Header-Container entfernt auf Nutzerwunsch)

          // (Intro text removed to avoid duplicate Live-Tabelle headings)

          // ==========================================
          // BAUSTEIN 3: DIE LIVE-TABELLE (Dynamischer Restplatz)
          // ==========================================
          // Wir packen die WebView in ein Expanded, damit sie den restlichen
          // Bildschirmplatz ausfüllt und innerhalb dieses Bereichs scrollbar ist.
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300), // Schicker Rahmen um die Tabelle
                borderRadius: BorderRadius.circular(8),
              ),
              // Hier drin lebt jetzt das DFBnet-Widget
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8), // Rundet auch die WebView-Ecken ab
                child: _isWebViewSupported && _controller != null
                    ? WebViewWidget(controller: _controller!)
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'WebView wird auf dieser Plattform nicht unterstützt. Bitte nutze ein Android-, iOS- oder macOS-Gerät.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ),
              ),
            ),
          ),

        ],
      ),
    ),
  );
}

}