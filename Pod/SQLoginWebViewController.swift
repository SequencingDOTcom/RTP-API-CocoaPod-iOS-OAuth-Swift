//
//  SQLoginWebViewController.swift
//  oauthdemoapp-swift
//
//  Created by Bogdan Laukhin on 9/7/16.
//  Copyright © 2016 ua.org. All rights reserved.
//

import UIKit
import WebKit


class SQLoginWebViewController: UIViewController, WKNavigationDelegate {
    
    typealias LoginCompletionBlock = (response: NSMutableDictionary?) -> Void
    
    var completionBlock: LoginCompletionBlock
    var webView: WKWebView?
    var activityIndicator: UIActivityIndicatorView
    var url: NSURL
    
    
    
    // MARK: - Initializer
    init(url: NSURL, completionBlock: LoginCompletionBlock) {
        self.url = url
        self.completionBlock = completionBlock
        self.activityIndicator = UIActivityIndicatorView()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding is not supported")
    }
    
    
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // prepare webView screen
        var rect: CGRect = self.view.bounds
        rect.origin = CGPointZero
        
        let preferences: WKPreferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let configuration: WKWebViewConfiguration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        let webView: WKWebView = WKWebView.init(frame: rect, configuration: configuration)
        webView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        self.view.addSubview(webView)
        self.webView = webView
        
        // add cancel button for WKWebViewController
        let cancelButton: UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(self.actionCancel(_:)))
        self.navigationItem.setRightBarButtonItem(cancelButton, animated: true)
        
        // add activity indicator
        self.activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.navigationItem.titleView = self.activityIndicator
        
        // open login page from url with params
        let request: NSURLRequest = NSURLRequest(URL: self.url)
        self.webView?.navigationDelegate = self
        self.webView?.loadRequest(request)
    }
    
    
    deinit {
        self.webView?.navigationDelegate = nil
    }
    
    
    
    // MARK: - Actions
    func actionCancel(sender: UIBarButtonItem) -> Void {
        self.activityIndicator.stopAnimating()
        self.webView?.navigationDelegate = nil
        let result: NSMutableDictionary = NSMutableDictionary()
        result.setObject(NSNumber(bool: true), forKey: "didCancelAuthorization")
        self.completionBlock(response: result)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    // MARK: - WKNavigationDelegate
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        print(navigationAction.request)
        
        if SQRequestHelper.instance.verifyRequestForRedirectBack(navigationAction.request) {
            self.webView?.navigationDelegate = nil
            self.completionBlock(response: SQRequestHelper.instance.parseRequest(navigationAction.request))
            self.dismissViewControllerAnimated(true, completion: nil)
            decisionHandler(WKNavigationActionPolicy.Cancel)
            
        } else {
            decisionHandler(WKNavigationActionPolicy.Allow)
        }
    }
    
    
    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
        let response = navigationResponse.response as! NSHTTPURLResponse
        let url: NSURL = response.URL!
        let urlString: String = url.absoluteString
        
        if urlString.containsString("sequencing.com/") {
            
            let statusCode = response.statusCode
            print(statusCode)
            if statusCode == 200 || statusCode == 301 || statusCode == 302 {
                
                decisionHandler(WKNavigationResponsePolicy.Allow)
                
            } else {
                self.activityIndicator.stopAnimating()
                self.webView?.navigationDelegate = nil
                
                let result: NSMutableDictionary = NSMutableDictionary()
                result.setObject(NSNumber(bool: true), forKey: "error")
                self.completionBlock(response: result)
                self.dismissViewControllerAnimated(true, completion: nil)
                decisionHandler(WKNavigationResponsePolicy.Cancel)
            }
            
        } else {
            decisionHandler(WKNavigationResponsePolicy.Allow)
        }
    }
    
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.activityIndicator.startAnimating()
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        self.activityIndicator.stopAnimating()
        self.webView?.navigationDelegate = nil
        
        let result: NSMutableDictionary = NSMutableDictionary()
        result.setObject(NSNumber(bool: true), forKey: "error")
        self.completionBlock(response: result)
        self.dismissViewControllerAnimated(true, completion: nil)
        print(error.localizedDescription)
    }
    
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        self.activityIndicator.stopAnimating()
        self.webView?.navigationDelegate = nil
        
        let result: NSMutableDictionary = NSMutableDictionary()
        result.setObject(NSNumber(bool: true), forKey: "error")
        self.completionBlock(response: result)
        self.dismissViewControllerAnimated(true, completion: nil)
        print(error.localizedDescription)
    }
    
    
    
    // MARK: - Memory
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
