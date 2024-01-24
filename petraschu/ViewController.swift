//
//  ViewController.swift
//  petraschu_APP
//  Created by 준수김 on 2023/12/15.
//

import UIKit
import WebKit
import CoreLocation
import AdSupport
import AppTrackingTransparency


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var webView: WKWebView!

    var web_URL: URL?
    var loginType: String = ""
    var locationManager: CLLocationManager!
    var firstLogin: Bool = false
    var URL_HOST: String?
    var URL_PATH: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
   
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
       
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    // 사용자에게 추적 권한을 요청합니다.
                    ATTrackingManager.requestTrackingAuthorization { status in
                        switch status {
                        case .authorized:
                            print("Authorized, 사용자가 추적을 허용 함")
                            
                            // 사용자가 추적을 허용을 했으므로, IDFA를 사용 가능 함
                            print(ASIdentifierManager.shared().advertisingIdentifier)
                            // 위치권한 팝업 함수
                            self.locationManager.requestWhenInUseAuthorization()
                        case .denied:
                            print("Denied, 사용자가 추적을 거부 함")
                            self.locationManager.requestWhenInUseAuthorization()
                        case .notDetermined:
                            print("Not Determined, 추적 권한 요청이 나타나지 않음")
                            self.locationManager.requestWhenInUseAuthorization()
                        case .restricted:
                            print("Restricted, 추적 권한 요청이 제한 됨")
                            self.locationManager.requestWhenInUseAuthorization()
                        @unknown default:
                            print("Unknown")
                            self.locationManager.requestWhenInUseAuthorization()
                        }
                    }
                }
        
    
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        loadWebPage("https://www.petraschu.com/")
        webView.allowsBackForwardNavigationGestures = true
        
        
    }

    private func loadWebPage(_ url: String) {
        guard let myUrl = URL(string: url) else {
            return
        }
        let request = URLRequest(url: myUrl)
        webView.load(request)
    }
    
   

}

extension ViewController: WKNavigationDelegate, WKUIDelegate {
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping
    (WKNavigationActionPolicy) -> Void) {
        
        
        
        decisionHandler(.allow)
        
        guard let url = navigationAction.request.url else {
            return
        }
        
        guard let url_Host = navigationAction.request.url?.host() else {
            return
        }
        
        guard let url_Path = navigationAction.request.url?.path() else {
            return
        }
        
        URL_HOST = url_Host
        URL_PATH = url_Path
        
        print("URL: \(url) | \(url_Host) | \(url_Path)")
        
        
        //MARK: - Kakao Login
        
        if url_Host == "kauth.kakao.com" { //처음 로그인 판단 로직
            firstLogin = true
            
        }
        
        if url_Path == "/oauth/code/confirm" {
            loginType = "kakao"
            let loginSheet = UIAlertController(title: "로그인 진행 중...", message: "", preferredStyle: .alert)
            present(loginSheet, animated: true)
            if firstLogin == true {
                webView.goBack()
                
            } else {
                webView.goBack()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.7) {
                    self.dismiss(animated: true)
                }
            }
            
            
            
        }
        
        if url_Path == "/login/simple" {
            webView.goBack()
        }
        
        if url_Host == "www.petraschu.com" && firstLogin == true {
            firstLogin = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.7) {
                self.dismiss(animated: true)
            }
        }
        
        
        //MARK: Naver Login
        
        if url_Host == "nid.naver.com" {
            loginType = "naver"
        }
        
        if url_Host == "www.google.com" {
            if loginType == "naver" {
                let loginSheet = UIAlertController(title: "로그인 진행 중...", message: "", preferredStyle: .alert)
                present(loginSheet, animated: true)
                guard let url = URL(string: "https://www.petraschu.com/") else { return }
                let request = URLRequest(url: url)
                webView.load(request)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) {
                    self.dismiss(animated: true)
                }
                loginType = ""
            }
        }
        //MARK: 빈창 허용
        
        if String(describing: web_URL) == "about:blank" {
              decisionHandler(.allow)
              return
        }
        
        //MARK: Open safari
        //설명: url_Host에 다른 탭으로 전환하는 'mdirect가 있다면 사파리로 다른 탭 전환하기'
        
//        print("pen safari : \(url_Host)")
//        
//        if url_Host.hasPrefix("mdirect") {
//            UIApplication.shared.open(url)
//        }
//        
//        if url_Host.hasPrefix("mstore") {
//            UIApplication.shared.open(url)
//        }
        
    }
    
    
 
    
    
    //MARK: 자바스크립트 처리
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {

        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler()
        }))

        present(alertController, animated: true, completion: nil)
    }


    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {

        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler(true)
        }))

        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(false)
        }))

        present(alertController, animated: true, completion: nil)
    }


    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {

        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.text = defaultText
        }

        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))

        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(nil)
        }))

        present(alertController, animated: true, completion: nil)
    }


    
    
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
            if navigationAction.targetFrame == nil { // 새창이 뜨는 상황
                if URL_HOST == "www.petraschu.com" || URL_HOST == "www.google.com"  { //호스트가 펫트라슈, 구글인 경우 앱 자체에서 URL 전환
                    webView.load(navigationAction.request)
                } else { //이외의 상황에서는 사파리에서 오픈
                    UIApplication.shared.open(navigationAction.request.url!)
                }
            }
            return nil
        
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url?.absoluteString else {
            return
        }
        
        print("리디 \(url)")

    }
    
}

