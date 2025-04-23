import SwiftUI
@preconcurrency import WebKit

struct PegasusLoginWebView: UIViewRepresentable {
    @ObservedObject var pegasusAuthModel: PegasusAuthModel
    var url: URL
    @Binding var isPresented: Bool
    var onTokenReceived: ((String) -> Void)?

    class Coordinator: NSObject, WKNavigationDelegate {
        var pegasusAuthModel: PegasusAuthModel
        @Binding var isPresented: Bool

        init(pegasusAuthModel: PegasusAuthModel, isPresented: Binding<Bool>) {
            self.pegasusAuthModel = pegasusAuthModel
            self._isPresented = isPresented
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            debugLog("Done loading page.")
            webView.evaluateJavaScript("document.documentElement.outerHTML", completionHandler: { result, error in
                guard let dataHtml = result as? String else {
                   return
                }
                guard dataHtml.contains("<td class=\"logout item\">") else {
                   return
                }
                WKWebsiteDataStore.default().httpCookieStore.getAllCookies() { cookies in
                    for cookie in cookies {
                        if (cookie.domain == "prepa-epita.helvetius.net" && cookie.name == "PHPSESSID") {
                            debugLog("PHPSESSID Cookie: \(cookie.value)")

                            self.pegasusAuthModel.setPhpSessId(newPhpSessId: cookie.value)
                            DispatchQueue.main.async {
                              self.isPresented = false
                            }
                            return
                        }
                    }
                }
            })
        }
        
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(pegasusAuthModel: pegasusAuthModel, isPresented: $isPresented  )
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
