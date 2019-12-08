import UIKit
import WebKit

class My_CollectionViewCell: UICollectionViewCell {
    
    var url: URL?
    var webview: WKWebView?
    var isMute = true
    
    
    @IBOutlet weak var webviewContent: UIView?
    @IBOutlet weak var speakerSound: UIButton!
    
    @IBAction func pressButton(_ sender: Any) {
        isMute = !isMute
        speakerSound.isHidden = !isMute
        changeSound(mute: isMute)
    }
    
    override func prepareForReuse() {
        webview?.removeFromSuperview()
        webview = nil
    }
    
    func setup(url: URL) {
        self.url = url
    }
    
    private func configWebView(){
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.mediaPlaybackRequiresUserAction = false
        config.allowsInlineMediaPlayback = true
        let source = "document.addEventListener('stopVideoEvent', function(){ window.webkit.messageHandlers.iosListener.postMessage('Did Video Stop'); })"
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        config.userContentController.addUserScript(script)
        config.userContentController.add(self, name: "iosListener")
        print("\(webviewContent!.bounds.width)   :   \(webviewContent!.bounds.height)")
        webview = WKWebView(frame: CGRect(x: 0, y: 0, width: webviewContent!.frame.width, height: webviewContent!.frame.height), configuration: config)
        
        webview?.translatesAutoresizingMaskIntoConstraints = false
        self.webview?.isOpaque = false
        self.webview?.backgroundColor = .clear
        self.webview?.scrollView.backgroundColor = .clear

    }
    public func startVideo(){
        if webview == nil {
            configWebView()
            webview?.loadHTMLString(YouTubeConfigHTML.getConfig(sURL: "https://www.youtube.com/embed/-EMn-ePp7Uw"), baseURL: nil)
            webviewContent?.addSubview(webview!)
        }
    }
    
    public func stopVideo(){
        webview?.removeFromSuperview()
        webview = nil
    }
    
    public func changeSound(mute: Bool){
        let calledSoundJsFuncion = mute ? "muteVideo()" : "unmuteVideo()"
        webview?.evaluateJavaScript(calledSoundJsFuncion) { result, error in
            guard error == nil else {
                print(error)
                return
            }
        }
    }
}



extension My_CollectionViewCell: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("message: \(message.body)")
        webview?.removeFromSuperview()
    }
}

