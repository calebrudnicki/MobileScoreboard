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
    
    //This functions assigns all the following times to be part of the picker
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let time1 = WKPickerItem()
        time1.title = "1:00"
        let time2 = WKPickerItem()
        time2.title = "2:00"
        let time3 = WKPickerItem()
        time3.title = "3:00"
        let time4 = WKPickerItem()
        time4.title = "4:00"
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
        timesArray = [time1, time2, time3, time4, time5, time6, time7, time8, time9, time10, time11, time12, time13]
        picker.setItems(timesArray)
        picker.setSelectedItemIndex(5)
    }
    
    //This function makes a shared instance of watch session
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    
//MARK: Actions
    
    //This function segues to the ScoreboardInterfaceController when the start run button is tapped
    @IBAction func startGameButtonTapped() {
        WatchSession.sharedInstance.tellPhoneToBeTheScoreboard()
        self.pushController(withName: "Scoreboard Interface Controller", context: overallTime)
    }

    //This functions changes the variable of overallTime to the current item in the picker
    @IBAction func pickerChanged(_ value: Int) {
        self.overallTime = timesArray[value].title!
        WatchSession.sharedInstance.tellPhoneTimeFromPicker(overallTime)
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
