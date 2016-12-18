//
//  HomeInterfaceController.swift
//  SportsTimer
//
//  Created by Caleb Rudnicki on 8/8/16.
//  Copyright © 2016 Caleb Rudnicki. All rights reserved.
//

import WatchKit
import Foundation

class HomeInterfaceController: WKInterfaceController {
  
//MARK: Outlets
    
    @IBOutlet var picker: WKInterfacePicker!
    
    
//MARK: Variables
    
    var overallTime: String = ""
    var timesArray: [WKPickerItem] = []
    
    
//MARK: Boilerplate Functions
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        let time1 = WKPickerItem()
        time1.title = "5:00"
        let time2 = WKPickerItem()
        time2.title = "10:00"
        let time3 = WKPickerItem()
        time3.title = "15:00"
        let time4 = WKPickerItem()
        time4.title = "20:00"
        let time5 = WKPickerItem()
        time5.title = "25:00"
        let time6 = WKPickerItem()
        time6.title = "30:00"
        let time7 = WKPickerItem()
        time7.title = "40:00"
        let time8 = WKPickerItem()
        time8.title = "50:00"
        let time9 = WKPickerItem()
        time9.title = "60:00"
        timesArray = [time1, time2, time3, time4, time4, time6, time7, time8, time9]
        picker.setItems(timesArray)
    }
    
    //This function makes a shared instance of watch session
    override func willActivate() {
        super.willActivate()
        WatchSession.sharedInstance.startSession()
        WatchSession.sharedInstance.tellPhoneToBeTheController()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    
//MARK: Actions
    
    //This function segues to the ScoreboardInterfaceController when the start run button is tapped
    @IBAction func startGameButtonTapped() {
        WatchSession.sharedInstance.tellPhoneToBeTheScoreboard()
        self.pushControllerWithName("Scoreboard Interface Controller", context: overallTime)
    }

    //This functions changes the variable of overallTime to the current item in the picker
    @IBAction func pickerChanged(value: Int) {
        self.overallTime = timesArray[value].title!
    }
    
    
//MARK: Segues
    
    override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
        if segueIdentifier == " Scoreboard Interface Controller" {
            return self.overallTime
        }
        return nil
    }
    
}