//
//  HomeInterfaceController.swift
//  SportsTimer
//
//  Created by Caleb Rudnicki on 8/8/16.
//  Copyright © 2016 Caleb Rudnicki. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class HomeInterfaceController: WKInterfaceController, WCSessionDelegate {
    /**Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session started")
    }
    
    //MARK: Outlets
    
    @IBOutlet var picker: WKInterfacePicker!
    
    //MARK: Variables
    
    var overallTime: String = ""
    var timesArray: [WKPickerItem] = []
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let time1 = WKPickerItem()
        time1.title = "1:00"
        let time5 = WKPickerItem()
        time5.title = "5:00"
        let time6 = WKPickerItem()
        time6.title = "10:00"
        let time7 = WKPickerItem()
        time7.title = "15:00"
        let time8 = WKPickerItem()
        time8.title = "20:00"
        let time9 = WKPickerItem()
        time9.title = "25:00"
        let time10 = WKPickerItem()
        time10.title = "30:00"
        let time11 = WKPickerItem()
        time11.title = "40:00"
        let time12 = WKPickerItem()
        time12.title = "50:00"
        let time13 = WKPickerItem()
        time13.title = "60:00"
        timesArray = [time1, time5, time6, time7, time8, time9, time10, time11, time12, time13]
        picker.setItems(timesArray)
        picker.setSelectedItemIndex(2)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(HomeInterfaceController.receivedTellWatchIfTimerIsOnNotification(_:)), name:NSNotification.Name(rawValue: "tellWatchIfTimerIsOn"), object: nil)
    }
    
    override func willActivate() {
        super.willActivate()
        WatchSession.sharedInstance.startSession()
    }
    
    override func didAppear() {
        WatchSession.sharedInstance.tellPhoneToStopGame()
        WatchSession.sharedInstance.tellPhonePotentialStartTime(overallTime)
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    //MARK: Actions
    
    //This function segues to the ScoreboardInterfaceController when the start run button is tapped
    @IBAction func startGameButtonTapped() {
        self.pushController(withName: "Scoreboard Interface Controller", context: overallTime)
    }

    //This functions changes the variable of overallTime to the current item in the picker
    @IBAction func pickerChanged(_ value: Int) {
        self.overallTime = timesArray[value].title!
        WatchSession.sharedInstance.tellPhonePotentialStartTime(overallTime)
    }
    
    //MARK: Segues
    
    //This function sends the selected time from the picker to the ScoreboardInterfaceController
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        if segueIdentifier == "Scoreboard Interface Controller" {
            return self.overallTime
        }
        return nil
    }
    
}
