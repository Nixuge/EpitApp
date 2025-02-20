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

        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            
            
            if navigationResponse.response.url!.absoluteString == "https://prepa-epita.helvetius.net/pegasus/index.php" {
                WKWebsiteDataStore.default().httpCookieStore.getAllCookies() { cookies in
                    // 1 cookie = only contains Pegasus' original PHPSESSID, not logged in
                    // > 1 = more cookies from eg office login.
                    if (cookies.count > 1) {
                        for cookie in cookies {
                            if (cookie.domain == "prepa-epita.helvetius.net" && cookie.name == "PHPSESSID") {
                                print("PHPSESSID Cookie: \(cookie.value)")
//                                decisionHandler(.cancel)
                                
                                self.pegasusAuthModel.setPhpSessId(newPhpSessId: cookie.value)
                                DispatchQueue.main.async {
                                    self.isPresented = false
                                }
                                return
                            }
                        }
                    }
                }
            }
            decisionHandler(.allow)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(pegasusAuthModel: pegasusAuthModel, isPresented: $isPresented  )
    }

    func makeUIView(context: Context) -> WKWebView {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print("All cookies deleted")

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                //print("Cookie ::: \(record) deleted")
            }
        }
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
