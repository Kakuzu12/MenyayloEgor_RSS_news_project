//
//  FeedItemWebViewController.swift
//  News
//
//  Created by Егор Меняйло on 11.10.2020.
//

import UIKit
import WebKit

class FeedItemWebViewController: UIViewController, WKUIDelegate {
//MARK: - PropertyDeclaration
    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    var selectedFeedURL: String?
//MARK: - ViewControllerLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        selectedFeedURL =  selectedFeedURL?.replacingOccurrences(of: " ", with:"")
        selectedFeedURL =  selectedFeedURL?.replacingOccurrences(of: "\n", with:"")
        webView.load(URLRequest(url: URL(string: selectedFeedURL! as String)!))
    }
//MARK: - UISetup
    private func setupUI() {
            self.view.backgroundColor = .white
            self.view.addSubview(webView)
            
            NSLayoutConstraint.activate([
                webView.topAnchor
                    .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                webView.leftAnchor
                    .constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
                webView.bottomAnchor
                    .constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
                webView.rightAnchor
                    .constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
            ])
        }
}
