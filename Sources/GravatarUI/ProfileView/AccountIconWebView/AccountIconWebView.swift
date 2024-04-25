import UIKit
import WebKit
import Gravatar

class AccountIconWebView: WKWebView, WKNavigationDelegate {
    
    let iconSize: CGSize
    var fillColor: UIColor
    var task: Task<Void, Never>?
    init(frame: CGRect = .zero, iconSize: CGSize, fillColor: UIColor) {
        self.iconSize = iconSize
        self.fillColor = fillColor
        super.init(frame: frame, configuration: WKWebViewConfiguration())
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func load(from url: URL) {
        let text = svgHTMLString(svgString: "", fillColor: "").components(separatedBy: .newlines).joined()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollIndicatorInsets = .zero
   //     scrollView.isScrollEnabled = false
        scrollView.contentInset = .zero
        scrollView.backgroundColor = .clear
        scrollView.contentInsetAdjustmentBehavior = .never
    //    scrollView.contentMode = .scaleAspectFill
        //scrollView.contentSize = .init(width: 32, height: 32)
        loadHTMLString(text, baseURL: nil)
        navigationDelegate = self
    //    sizeToFit()

    //    contentMode = .scaleAspectFill
        //sizeToFit()
       // autoresizesSubviews = false
      /*
       task?.cancel()
       task = Task {
            do {
                let result: (data: Data, response: URLResponse) = try await URLSession.shared.data(for: URLRequest(url: url))
                //guard let svgString = String(data: result.data, encoding: .utf8) else { return }
                //let html = svgHTMLString(svgString: svgString, fillColor: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\\", with: "")
                //if let fileURL = Bundle.module.url(forResource: "icon", withExtension: "html") {
                //    let string = (try String(contentsOf: fileURL)).components(separatedBy: .newlines).joined()
                   // loadFileURL(fileURL, allowingReadAccessTo: fileURL)
                //    loadHTMLString(string, baseURL: nil)
                }
                //load(URLRequest(url: url))
               // loadHTMLString(html, baseURL: nil)
                
            } catch {
                print(String(describing: error))
            }
        }*/
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("height: \(webView.scrollView.contentSize.height)")
        print("width: \(webView.scrollView.contentSize.width)")
        scrollView.backgroundColor = .clear
        webView.invalidateIntrinsicContentSize()
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
        scrollView.contentSize = .init(width: 32, height: 32)
        webView.contentScaleFactor = 0.1
        webView.maximumContentSizeCategory = .small
        webView.contentMode = .center
        
    }
    
    override var intrinsicContentSize: CGSize {
        .init(width: 32, height: 32)
    }
}


func svgHTMLString(svgString: String, fillColor: String) -> String {
"""
<html>
    <head>
    <meta name="viewport" content="width=96px, height=96px, shrink-to-fit=YES">
    <style>
    .icon svg {
        height: 100%;
        width: 100%;
        margin: 0px 0px 0px 0px;
        padding: 0px;
        display:flex;
        align-items:center;
        justify-content:center;
        background-color: rgba(0, 0, 0, 0);
    }
    .icon path {
        fill: rgb(255, 0, 0);
        background-color: rgba(0, 0, 0, 0);
    }
    body {
        margin: 0;
        background-color: rgba(0, 0, 0, 0);
        //background-color: green;
    }
    </style>
    <head/>
<body>

<div class=icon>
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M13.3879 20C10.9774 20 9.18958 18.7646 9.18958 15.8016V11.0609H7V8.48964C9.41055 7.86692 10.4149 5.79787 10.5254 4H13.0264V8.07784H15.9391V11.0609H13.0264V15.189C13.0264 16.4244 13.6491 16.8562 14.6434 16.8562H16.0596V20H13.3879Z" fill="black"/>
    </svg>
</div>

</body>
</html>
"""
}
