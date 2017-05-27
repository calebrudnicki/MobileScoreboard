//
//  ExtensionDelegate.swift
//  SportsTimer WatchKit Extension
//
//  Created by Caleb Rudnicki on 6/23/16.
//  Copyright © 2016 Caleb Rudnicki. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        WatchSession.sharedInstance.startSession()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //WatchSession.sharedInstance.tellPhoneToBeTheScoreboard()
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        //print("here3")
        //WatchSession.sharedInstance.tellPhoneToBeTheController()
    }
    
    func applicationDidEnterBackground() {
        print("In background")
        WatchSession.sharedInstance.tellPhoneWatchIsInBackground()
    }

}
