//
//  WatchSession.swift
//  SportsTimer
//
//  Created by Caleb Rudnicki on 8/7/16.
//  Copyright © 2016 Caleb Rudnicki. All rights reserved.
//

import WatchKit
import WatchConnectivity

class WatchSession: NSObject, WCSessionDelegate {
    
    //MARK: Session Functions
    
    //This function is called when the watch session completes activation
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session started")
    }
  
    //MARK: Variables
    
    static let sharedInstance = WatchSession()
    var session: WCSession!
    var readyToStopTimer: Bool = false
    
    //MARK: Session Creation
    
    //This function creates a session
    func startSession() {
        if WCSession.isSupported() {
            session = WCSession.default()
            session.delegate = self
            session.activate()
        }
        
        if session.isReachable == true {
            print("Its reachable")
            readyToStopTimer = true
        } else {
            print("Its not reachable")
        }
        
    }
    
    //MARK: Data Senders
    
    //This function asks the phone phone for user defaults like players and sports theme
    func askPhoneForDefaults() {
        let actionDictFromWatch = ["Action": "askPhoneForDefaults"]
        session.sendMessage(actionDictFromWatch, replyHandler: nil)
    }
    
    //This function tells the phone that the watch will be the leader for this game
    func tellPhoneWatchIsTiming(_ watchIsOn: Bool) {
        let payloadDictFromWatch = ["WatchIsOn": watchIsOn]
        let actionDictFromWatch = ["Action": "tellPhoneWatchIsTiming", "Payload": payloadDictFromWatch] as [String : Any]
        session.sendMessage(actionDictFromWatch as [String : AnyObject], replyHandler: nil)
    }
    
    //This function tells the phone to start a game
    func tellPhoneToStartGame(_ time: Int) {
        let payloadDictFromWatch = ["Time": time]
        let actionDictFromWatch = ["Action": "tellPhoneToStartGame", "Payload": payloadDictFromWatch] as [String : Any]
        session.sendMessage(actionDictFromWatch as [String : AnyObject], replyHandler: nil)
    }
    
    //This function tells the phone to stop a game
    func tellPhoneToStopGame() {
        let actionDictFromWatch = ["Action": "tellPhoneToStopGame"]
        session.sendMessage(actionDictFromWatch, replyHandler: nil)
    }
    
    //This function tells the phone the updated scoring data
    func tellPhoneScoreData(_ score1: Int, score2: Int) {
        let payloadDictFromWatch = ["Score1": score1, "Score2": score2]
        let actionDictFromWatch = ["Action": "tellPhoneScoreData", "Payload": payloadDictFromWatch] as [String : Any]
        session.sendMessage(actionDictFromWatch as [String : AnyObject], replyHandler: nil)
    }
    
    //This function tells the phone that the watch has entered the background
    func tellPhoneWatchIsInBackground() {
        let actionDictFromWatch = ["Action": "tellPhoneWatchIsInBackground"]
        session.sendMessage(actionDictFromWatch, replyHandler: nil)
    }
    
    //This function updates the phone with the current time on the watch's spinner
    func tellPhonePotentialStartTime(_ time: String) {
        let payloadDictFromWatch = ["Time": time]
        let actionDictFromWatch = ["Action": "tellPhonePotentialStartTime", "Payload": payloadDictFromWatch] as [String : Any]
        session.sendMessage(actionDictFromWatch as [String : AnyObject], replyHandler: nil)
    }
    
    //This function tells the phone to resume the game when the play button is tapped
    func tellPhoneToPlayGame() {
        let actionDictFromWatch = ["Action": "tellPhoneToPlayGame"]
        session.sendMessage(actionDictFromWatch, replyHandler: nil)
    }
    
    //This function tells the phone to pause the game when the pause button is tapped
    func tellPhoneToPauseGame() {
        let actionDictFromWatch = ["Action": "tellPhoneToPauseGame"]
        session.sendMessage(actionDictFromWatch, replyHandler: nil)
    }
    
    //MARK: Data Getters
    
    //This functions receives a message from the phone
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: message["Action"]! as! String), object: message["Payload"])
        }
    }
    
}
