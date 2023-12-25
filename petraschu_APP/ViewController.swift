//
//  ViewController.swift
//  petraschu_APP
//
//  Created by 준수김 on 2023/12/15.
//

import UIKit
import WebKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var webView: WKWebView!

    var web_URL: URL?
    var loginType: String = ""
    var locationManager: CLLocationManager!
    var firstLogin: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
          
        // 위치권한 팝업 함수
        locationManager.requestWhenInUseAuthorization()
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
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
        
        guard let url_Host = navigationAction.request.url?.host() else {
            return
        }
        
        guard let url_Path = navigationAction.request.url?.path() else {
            return
        }
        
        print("URL: \(url_Host) \(url_Path)")
        
        
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
            
            print("1 \(firstLogin)")
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
        
    }
    
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
   
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
    }

    
}

