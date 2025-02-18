import SwiftUI
@preconcurrency import WebKit

struct CalendarLoginWebView: UIViewRepresentable {
    @ObservedObject var zeusAuthModel: ZeusAuthModel
    var url: URL
    @Binding var isPresented: Bool
    var onTokenReceived: ((String) -> Void)?

    class Coordinator: NSObject, WKNavigationDelegate {
        var zeusAuthModel: ZeusAuthModel
        @Binding var isPresented: Bool

        init(zeusAuthModel: ZeusAuthModel, isPresented: Binding<Bool>) {
            self.zeusAuthModel = zeusAuthModel
            self._isPresented = isPresented
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            let url = navigationResponse.response.url;
            if (url!.absoluteString.contains("https://zeus.ionis-it.com/officeConnect/#access_token=")) {
                let t = url!.absoluteString.replacingOccurrences(of: "#access_token=", with: "?access_token=")
                debugPrint("FOUND TOKEN !")
                let token = getURLParameterValue(url: t, "access_token")!;
                zeusAuthModel.setOfficeToken(newOfficeToken: token)
                DispatchQueue.main.async {
                    self.isPresented = false
                }
            }
            decisionHandler(.allow)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(zeusAuthModel: zeusAuthModel, isPresented: $isPresented  )
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
