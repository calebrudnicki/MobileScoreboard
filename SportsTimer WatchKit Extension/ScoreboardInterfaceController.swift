//
//  InterfaceController.swift
//  SportsTimer WatchKit Extension
//
//  Created by Caleb Rudnicki on 6/23/16.
//  Copyright © 2016 Caleb Rudnicki. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class ScoreboardInterfaceController: WKInterfaceController, WCSessionDelegate {
    
//MARK: Outlets
    
    @IBOutlet var timer: WKInterfaceTimer!
    @IBOutlet var player1Score: WKInterfaceButton!
    @IBOutlet var player2Score: WKInterfaceButton!
    
    
//MARK: Variables
    
    var countdown: NSTimeInterval = 600
    var backingTimer: NSTimer?
    var score1 = 0
    var score2 = 0
    var gameIsPaused = false
    
    
//MARK: Boilerplate Functions
    
    //This function sets the amount of time based on what the user picked in the HomeInterfaceController, calls newGame(), and resets each players score to 0
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let val: String = context as? String {
            self.convertClockFormatToSeconds(val)
        }
        self.newGame()
        player1Score.setTitle(String(score1))
        player2Score.setTitle(String(score2))
    }
    
    //This function creates a new game and a shared instance of a session
    override func willActivate() {
        super.willActivate()
        WatchSession.sharedInstance.startSession()
    }
    
    //This function invalidates the backing timer when the end game button is tapped
    override func didDeactivate() {
        super.didDeactivate()
        backingTimer?.invalidate()
    }
    
    //This function calls a shared instance of tellPhoneToStopGame() when the end game button is tapped
    override func willDisappear() {
        WatchSession.sharedInstance.tellPhoneToStopGame()
    }
    
    //This functions sets the back button's text
    override init () {
        super.init ()
        self.setTitle("End Game")
    }

//MARK: Starting a New Game
    
    //This function that is called when the start game button is chosen
    func newGame() {
        let date = NSDate(timeIntervalSinceNow: countdown)
        timer.setDate(date)
        timer.start()
        WatchSession.sharedInstance.tellPhoneToStartGame(countdown)
        //This is a one second timer that calls the secondTimerFired() function everytime it ends, then it repeats
        backingTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScoreboardInterfaceController.secondTimerFired), userInfo: nil, repeats: true)
    }
    
    
//MARK: Timer Functions
    
    //This function subtracts from the countdown variable every second when it is called and then calls the timesUp() function when countdown is less than 0
    func secondTimerFired() {
        countdown -= 1
        if countdown < 0 {
            self.timesUp()
        }
    }
    
    //This function that runs when the countdown variable is less than 0 first disables the backingTimer, then it notifies the user that the game is over while also displaying the result of the game and disabling the buttons
    func timesUp() {
        backingTimer?.invalidate()
        WKInterfaceDevice().playHaptic(.Failure)
        if score1 > score2 {
            player1Score.setTitle("W")
            player1Score.setBackgroundColor(UIColor.greenColor())
            player2Score.setTitle("L")
            player2Score.setBackgroundColor(UIColor.redColor())
        } else if score2 > score1 {
            player2Score.setTitle("W")
            player2Score.setBackgroundColor(UIColor.greenColor())
            player1Score.setTitle("L")
            player1Score.setBackgroundColor(UIColor.redColor())
        } else {
            player1Score.setTitle("T")
            player1Score.setBackgroundColor(UIColor.blueColor())
            player2Score.setTitle("T")
            player2Score.setBackgroundColor(UIColor.blueColor())
        }
        player1Score.setEnabled(false)
        player2Score.setEnabled(false)
    }
    
    //This function converts a clock format to an amount of seconds
    func convertClockFormatToSeconds(clock: String) {
        if clock == "1:00" {
            countdown = 60
        } else if clock == "2:30" {
            countdown = 150
        } else if clock == "5:00" {
            countdown = 300
        } else if clock == "15:00" {
            countdown = 900
        } else if clock == "20:00" {
            countdown = 1200
        } else if clock == "25:00" {
            countdown = 1500
        } else if clock == "30:00" {
            countdown = 1800
        } else if clock == "40:00" {
            countdown = 2400
        } else if clock == "50:00" {
            countdown = 3000
        } else if clock == "60:00" {
            countdown = 3600
        } else {
            countdown = 600
        }
    }
    
    
//MARK: Actions
    
    //This function adds a goal to Player 1's score and sends that info to the phone
    @IBAction func goalButton1() {
        if gameIsPaused == false {
            score1 += 1
            player1Score.setTitle(String(score1))
            WatchSession.sharedInstance.tellPhoneScoreData(score1, score2: score2)
        }
    }
    
    //This functions adds a goal to Player 2's score and sends that info to the phone
    @IBAction func goalButton2() {
        if gameIsPaused == false {
            score2 += 1
            player2Score.setTitle(String(score2))
            WatchSession.sharedInstance.tellPhoneScoreData(score1, score2: score2)
        }
    }
    
    //This function starts the timer when the play button is tapped
    @IBAction func playButtonTapped() {
        if gameIsPaused == true {
            gameIsPaused = false
            countdown -= 2
            self.newGame()
        }
    }
    
    //This function pauses the timer when the pause button is tapped
    @IBAction func pauseButtonTapped() {
        if gameIsPaused == false {
            gameIsPaused = true
            timer.stop()
        }
    }
    
}