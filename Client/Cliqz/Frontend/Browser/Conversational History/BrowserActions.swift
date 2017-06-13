//
//  ReactHomeViewController.swift
//  Client
//
//  Created by Sahakyan on 5/18/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import Foundation
import React

@objc(BrowserActions)
public class BrowserActions: NSObject {
	
	@objc(openLink:)
	public func openLink(url: NSString) {
		print("Hello React")
		if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate, u = NSURL(string:url as String) {
			appDelegate.openUrlInWebView(u)
		}
	}
	
	@objc(queryCliqz:)
	public func queryCliqz(url: NSString) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.searchInWebView((url as String) ?? "")
        }
	}

	@objc(getOpenTabs:reject:)
	public func getOpenTabs(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
		let openTabs = NSMutableArray()
		if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
			for tab in appDelegate.tabManager.tabs {
                if let id = tab.webView?.uniqueId, url = tab.url?.absoluteString {
                    let tabData = NSMutableDictionary()
                    tabData["id"] = NSInteger(id)
                    tabData["url"] = NSString(string: url)
                    tabData["title"] = NSString(string: tab.displayTitle)
                    openTabs.addObject(tabData)
                }
			}
		}
		resolve(openTabs)
	}

	@objc(openTab:)
	public func openTab(tabID: NSInteger) {
		if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
			appDelegate.openTab(tabID as Int)
		}
	}
}