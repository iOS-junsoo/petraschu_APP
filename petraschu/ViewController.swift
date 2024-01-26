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
import FlareLane

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var webView: WKWebView!

    var web_URL: URL?
    var loginType: String = ""
    var locationManager: CLLocationManager!
    var firstLogin: Bool = false
    var URL_ALL: URL?
    var URL_HOST: String?
    var URL_PATH: String?
    var isUrl: String?
    private var popupWebView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        
        //MARK: - 앱 푸쉬 옵저버
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
       
        //MARK: - 알람 허용 비허용
        NotificationCenter.default.addObserver(self, selector: #selector(notificationSettingsDidChange(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
       
        //MARK: - 권한 팝업 순서화
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    // 사용자에게 추적 권한을 요청합니다.
                    ATTrackingManager.requestTrackingAuthorization { status in
                        switch status {
                        case .authorized:
                            print("Authorized, 사용자가 추적을 허용 함")
                            
                            // 사용자가 추적을 허용을 했으므로, IDFA를 사용 가능 함
                            print(ASIdentifierManager.shared().advertisingIdentifier)
                            // 위치권한 팝업 함수
                            self.locationManager.requestWhenInUseAuthorization()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                checkUserCurrentLocationAuthorization(CLLocationManager.authorizationStatus())
                            }
                        case .denied:
                            print("Denied, 사용자가 추적을 거부 함")
                            self.locationManager.requestWhenInUseAuthorization()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                checkUserCurrentLocationAuthorization(CLLocationManager.authorizationStatus())
                            }
                        case .notDetermined:
                            print("Not Determined, 추적 권한 요청이 나타나지 않음")
                            self.locationManager.requestWhenInUseAuthorization()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                checkUserCurrentLocationAuthorization(CLLocationManager.authorizationStatus())
                            }
                        case .restricted:
                            print("Restricted, 추적 권한 요청이 제한 됨")
                            self.locationManager.requestWhenInUseAuthorization()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                checkUserCurrentLocationAuthorization(CLLocationManager.authorizationStatus())
                            }
                        @unknown default:
                            print("Unknown")
                           
                        }
                    }
                }
        
        func checkUserCurrentLocationAuthorization(_ status: CLAuthorizationStatus) {
            switch status {
            
            case .notDetermined:
                print("사용자가 아직 권한을 결정하지 않음.")
                
            case .denied, .restricted:
                print("사용자가 허용 안함")
                FlareLane.subscribe(fallbackToSettings: true) { isSubscribed in
                  // Do Something...
                }
            case .authorizedWhenInUse:
                print("사용자가 앱 사용 시 허용")
                FlareLane.subscribe(fallbackToSettings: true) { isSubscribed in
                  // Do Something...
                }
            case .authorizedAlways:
                print("사용자가 항상 허용")
                FlareLane.subscribe(fallbackToSettings: true) { isSubscribed in
                  // Do Something...
                }
            default:
                print("Default")
               
            }
        }
        
        //MARK: - webview 설정
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.configuration.preferences.javaScriptEnabled = true
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
    
    
    
    
    @objc func appDidBecomeActive() {
        
        FlareLane.setNotificationClickedHandler() { notification in
            print(notification.url)
            if notification.url == nil {
                self.loadWebPage("https://www.petraschu.com/")
            } else {
                self.loadWebPage(notification.url ?? "https://www.petraschu.com/")
            }
        }
          
    }

    
    
    //MARK: 알람 권한이 변경되는 것 감지
    
    @objc func notificationSettingsDidChange(_ notification: Notification) {
            // 알림 권한이 변경될 때 호출되는 메서드
            checkNotificationAuthorization()
        }

        func checkNotificationAuthorization() {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .authorized:
                    print("알림 권한이 허용됨")
                    FlareLane.subscribe(fallbackToSettings: true) { isSubscribed in
                    }
                case .denied:
                    print("알림 권한이 거부됨")
                    FlareLane.unsubscribe() { isSubscribed in
                    }
                case .notDetermined:
                    print("아직 알림 권한을 선택하지 않음")
                case .provisional:
                    print("Provisional 알림 권한이 부여됨")
                case .ephemeral:
                    print("Ephemeral 알림 권한이 부여됨")
                @unknown default:
                    break
                }
            }
        }

        deinit {
            // 옵저버 제거
            NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
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
        
        URL_ALL = url
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
                print("새창이 뜹니다.\(URL_HOST)")
                
                
                if URL_HOST == "www.petraschu.com" || URL_HOST == "www.google.com" || URL_HOST == "wauth.teledit.com" || URL_HOST == "www.youtube.com" { //호스트가 펫트라슈, 구글인 경우 앱 자체에서 URL 전환
//                    webView.load(navigationAction.request) // 회원가입 본인인증 떄문에 바꾼 부분 이전 버전

                    let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets

                    
                    popupWebView = WKWebView(frame: CGRect(x: 0, y: safeAreaInsets?.top ?? 0, width: view.bounds.width, height: view.bounds.height - (safeAreaInsets?.top ?? 0)), configuration: configuration)
                    popupWebView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    popupWebView?.navigationDelegate = self
                    popupWebView?.uiDelegate = self
                    popupWebView?.allowsBackForwardNavigationGestures = true
                    
                    
                    if let newWebview = popupWebView {
                        view.addSubview(newWebview)
                    }
                    
                    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
                    popupWebView?.addGestureRecognizer(panGesture)
                    
                    return popupWebView ?? nil
                    
                } else { //이외의 상황에서는 사파리에서 오픈
                    UIApplication.shared.open(navigationAction.request.url!)
                }
            }
            return nil
            
        
    }
    
    @objc func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
            let translation = gesture.translation(in: popupWebView)

            switch gesture.state {
            case .changed:
                // 제스처의 변화에 따라 팝업 웹뷰를 이동시킴
                popupWebView?.transform = CGAffineTransform(translationX: translation.x, y: 0)

            case .ended:
                // 제스처가 끝날 때, 팝업 웹뷰의 위치에 따라 뒤로가기를 수행 또는 취소
                if translation.x > popupWebView!.bounds.width / 3 {
                    // 팝업 웹뷰가 화면의 반 이상으로 이동하면 뒤로가기 수행
                    popupWebView?.removeFromSuperview()
                    popupWebView = nil
                }

                // 제스처 종료 후 팝업 웹뷰를 원래 위치로 되돌림
                UIView.animate(withDuration: 0.3) {
                    self.popupWebView?.transform = .identity
                }

            default:
                break
            }
        }
    
    func webViewDidClose(_ webView: WKWebView) {
            if webView == popupWebView {
                popupWebView?.removeFromSuperview()
                popupWebView = nil
            }
        }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url?.absoluteString else {
            return
        }

    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Failed to load: \(error.localizedDescription)")
    }
    
    
    
}

