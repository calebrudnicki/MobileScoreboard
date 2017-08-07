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
    /**Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session started")
    }

    //MARK: Outlets
    
    @IBOutlet var timer: WKInterfaceTimer!
    @IBOutlet var player1Name: WKInterfaceLabel!
    @IBOutlet var player2Name: WKInterfaceLabel!
    @IBOutlet var player1Score: WKInterfaceButton!
    @IBOutlet var player2Score: WKInterfaceButton!
    
    //MARK: Variables
    
    var countdown: TimeInterval = 600
    var backingTimer: Timer?
    var score1 = 0
    var score2 = 0
    var gameIsPaused = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let val: String = context as? String {
            self.convertClockFormatToSeconds(val)
        }
        self.newGame()
        self.addMenuItems(newButton: "Pause")
        player1Score.setTitle(String(score1))
        player2Score.setTitle(String(score2))
        
        WatchSession.sharedInstance.startSession()
        WatchSession.sharedInstance.askPhoneForDefaults()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardInterfaceController.receivedTellWatchPlayerNamesNotification(_:)), name:NSNotification.Name(rawValue: "tellWatchPlayerNames"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardInterfaceController.receivedTellWatchSportsThemeNotification(_:)), name:NSNotification.Name(rawValue: "tellWatchSportsTheme"), object: nil)
        
    }
    
    override func willActivate() {
        super.willActivate()
        WatchSession.sharedInstance.tellPhoneWatchIsTiming(true)
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    override func willDisappear() {
        NotificationCenter.default.removeObserver(self)
    }
    
    //This functions sets the back button's text
    override init () {
        super.init ()
        self.setTitle("End Game")
    }
    
    //MARK: Phone Communication Functions
    
    //This function runs when the phone sends the names of the players
    func receivedTellWatchPlayerNamesNotification(_ notification: Notification) {
        let dataDict = notification.object as? [String : AnyObject]
        player1Name.setText((dataDict?["Player1Name"]!)! as? String)
        player2Name.setText((dataDict?["Player2Name"]!)! as? String)
    }
    
    //This function runs when the phone sends the sports theme
    func receivedTellWatchSportsThemeNotification(_ notification: Notification) {
        let dataDict = notification.object as? [String : AnyObject]
        if dataDict?["Sport"]! as? String! == "Basketball" {
            self.changeScoreboard(red: 101, green: 0, blue: 0)
        } else if dataDict?["Sport"]! as? String! == "Hockey" {
            self.changeScoreboard(red: 11, green: 34, blue: 15)
        } else if dataDict?["Sport"]! as? String! == "Soccer" {
            self.changeScoreboard(red: 0, green: 9, blue: 69)
        } else if dataDict?["Sport"]! as? String! == "Baseball" {
            self.changeScoreboard(red: 169, green: 124, blue: 80)
        } else {
            self.changeScoreboard(red: 10, green: 10, blue: 10)
        }
    }

    //MARK: Starting a New Game
    
    //This function that is called when the start game button is chosen
    func newGame() {
        WatchSession.sharedInstance.tellPhoneToStartGame(Int(countdown))
        let date = Date(timeIntervalSinceNow: countdown)
        timer.setDate(date)
        timer.start()
        backingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScoreboardInterfaceController.secondTimerFired), userInfo: nil, repeats: true)
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
        WKInterfaceDevice().play(.failure)
        if score1 > score2 {
            player1Score.setTitle("W")
            player1Score.setBackgroundColor(UIColor.green)
            player2Score.setTitle("L")
            player2Score.setBackgroundColor(UIColor.red)
        } else if score2 > score1 {
            player2Score.setTitle("W")
            player2Score.setBackgroundColor(UIColor.green)
            player1Score.setTitle("L")
            player1Score.setBackgroundColor(UIColor.red)
        } else {
            player1Score.setTitle("T")
            player1Score.setBackgroundColor(UIColor.blue)
            player2Score.setTitle("T")
            player2Score.setBackgroundColor(UIColor.blue)
        }
        player1Score.setEnabled(false)
        player2Score.setEnabled(false)
    }
    
    //This function converts a clock format to an amount of seconds
    func convertClockFormatToSeconds(_ clock: String) {
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
    
    //MARK: Menu Actions
    
    func playPauseButtonTapped() {
        if gameIsPaused == true {
            WatchSession.sharedInstance.tellPhoneToPlayGame()
            gameIsPaused = false
            self.newGame()
            self.addMenuItems(newButton: "Pause")
        } else if gameIsPaused == false {
            WatchSession.sharedInstance.tellPhoneToPauseGame()
            gameIsPaused = true
            timer.stop()
            backingTimer?.invalidate()
            self.addMenuItems(newButton: "Play")
        }
    }
    
    //This function subtracts a goal from player 1 when tapped
    func trashPlayer1GoalButtonTapped() {
        if score1 > 0 {
            score1 -= 1
            player1Score.setTitle(String(score1))
            WatchSession.sharedInstance.tellPhoneScoreData(score1, score2: score2)
        }
    }
    
    //This function subtracts a goal from player 2 when tapped
    func trashPlayer2GoalButtonTapped() {
        if score2 > 0 {
            score2 -= 1
            player2Score.setTitle(String(score2))
            WatchSession.sharedInstance.tellPhoneScoreData(score1, score2: score2)
        }
    }
    
    //MARK: Helper Functions
    
    //This function changes the actual objects on the screen based on what sport was selected
    func changeScoreboard(red: CGFloat, green: CGFloat, blue: CGFloat) {
        timer.setTextColor(UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1))
        player1Name.setTextColor(UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1))
        player2Name.setTextColor(UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1))
        player1Score.setBackgroundColor(UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1))
        player2Score.setBackgroundColor(UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1))
    }
    
    //This functon refreshes the menu items
    func addMenuItems(newButton: String) {
        clearAllMenuItems()
        addMenuItem(with: .trash, title: "-P1 Goal", action: #selector(ScoreboardInterfaceController.trashPlayer1GoalButtonTapped))
        addMenuItem(with: .trash, title: "-P2 Goal", action: #selector(ScoreboardInterfaceController.trashPlayer2GoalButtonTapped))
        if newButton == "Play" {
            addMenuItem(with: .play, title: "Play", action: #selector(ScoreboardInterfaceController.playPauseButtonTapped))
        } else {
            addMenuItem(with: .pause, title: "Pause", action: #selector(ScoreboardInterfaceController.playPauseButtonTapped))
        }
    }
    
}
