import SwiftUI
import WebKit

struct WebView2: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "buttonClicked")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        // WKWebViewConfiguration has userContentController add WKScriptMessageHandler //
        //userContentController(_ userContentController: WKUserContentController,
        //didReceive message: WKScriptMessage
        
        // HTML with a button
        let html = """
        <html>
        <body style="font-family: -apple-system; text-align:center; margin-top:500px;">
            <button id="myBtn">Click Me</button>
            <script>
              document.getElementById("myBtn").addEventListener("click", function() {
                window.webkit.messageHandlers.buttonClicked.postMessage("Button Pressed in WebView!");
              });
            </script>
        </body>
        </html>
        """
       // webView.loadHTMLString(html, baseURL: nil)
        
        
        let html1 = """
               <html>
               <body style="background:#f2f2f2; margin:0; overflow:hidden;">
               </body>
               </html>
               """
               webView.loadHTMLString(html1, baseURL: nil)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
          // Inject JavaScript to draw a rectangle
          let js = """
          var div = document.createElement('div');
          div.style.width = '150px';
          div.style.height = '100px';
          div.style.backgroundColor = 'red';
          div.style.position = 'absolute';
          div.style.top = '100px';
          div.style.left = '100px';
          div.style.borderRadius = '12px';
          div.innerHTML = "<p style='color:white; text-align:center; padding-top:35px;'>Rectangle</p>";
          document.body.appendChild(div);
          """
          
          uiView.evaluateJavaScript(js, completionHandler: nil)
      }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKScriptMessageHandler {
        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            if message.name == "buttonClicked", let body = message.body as? String {
                print("📩 Swift received:", body)
            }
        }
    }
}
