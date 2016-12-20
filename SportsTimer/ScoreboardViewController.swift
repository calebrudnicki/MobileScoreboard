//
//  ScoreboardViewController.swift
//  SportsTimer
//
//  Created by Caleb Rudnicki on 7/6/16.
//  Copyright © 2016 Caleb Rudnicki. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class ScoreboardViewController: UIViewController {
    
//MARK: Outlets
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var player1TitleLabel: UILabel!
    @IBOutlet weak var player2TitleLabel: UILabel!
    @IBOutlet weak var player1ScoreButton: UIButton!
    @IBOutlet weak var player2ScoreButton: UIButton!
    @IBOutlet weak var tutorialStack: UIStackView!
    
//MARK: Variables
    
    let speechSynthesizer = AVSpeechSynthesizer()
    var timer: NSTimer!
    var startingGameTime: Int! = 600
    var currentTime: Int! = 600
    var player1Score: Int! = 0
    var player2Score: Int! = 0
    var timerIsOn: Bool = false
    var canScoreFromPhone = true
    
    
//MARK: Boilerplate Functions
    
    //This function creates an instance of a shared session, establishes this class as an observer of the tellPhoneToBeTheScoreboard, tellPhoneToBeTheController, tellPhoneToStartGame, tellPhoneToStopGame, tellPhoneScoreData, and tellPhoneTheTime notifications, and calls addSwipe()
    override func viewDidLoad() {
        super.viewDidLoad()
        PhoneSession.sharedInstance.startSession()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneToBeTheControllerNotification(_:)), name:"tellPhoneToBeTheController", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneToBeTheScoreboardNotification(_:)), name:"tellPhoneToBeTheScoreboard", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneToStartGameNotification(_:)), name:"tellPhoneToStartGame", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneToStopGameNotification(_:)), name:"tellPhoneToStopGame", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneScoreDataNotification(_:)), name:"tellPhoneScoreData", object: nil)
        self.addSwipe()
        self.eliminateTutorial(10)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //This function removes itself as an observer when the view disappears
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    

//MARK: Layout Functions
    
    //This function formats the screen to show that it is active
    func activatePhone() {
        canScoreFromPhone = true
        self.restartGame()
        view.backgroundColor = UIColor(red: 22/255, green: 160/255, blue: 133/255, alpha: 1)
        timerLabel.textColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        player1TitleLabel.textColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        player2TitleLabel.textColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        player1ScoreButton.setTitleColor(UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1), forState: .Normal)
        player2ScoreButton.setTitleColor(UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1), forState: .Normal)
        self.layoutWithTutorial()
    }
    
    //This function formats the screen to show that it is inactive
    func deactivatePhone() {
        canScoreFromPhone = false
        self.restartGame()
        view.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        timerLabel.textColor = UIColor(red: 22/255, green: 160/255, blue: 133/255, alpha: 1)
        player1TitleLabel.textColor = UIColor(red: 22/255, green: 160/255, blue: 133/255, alpha: 1)
        player2TitleLabel.textColor = UIColor(red: 22/255, green: 160/255, blue: 133/255, alpha: 1)
        player1ScoreButton.setTitleColor(UIColor(red: 22/255, green: 160/255, blue: 133/255, alpha: 1), forState: .Normal)
        player2ScoreButton.setTitleColor(UIColor(red: 22/255, green: 160/255, blue: 133/255, alpha: 1), forState: .Normal)
        self.layoutWithoutTutorial()
    }
    
    //This function changes the layout of the labels when the tutorial is on
    func layoutWithTutorial() {
        tutorialStack.hidden = false
        timerLabel.alpha = 0.25
        player1TitleLabel.alpha = 0.25
        player2TitleLabel.alpha = 0.25
        player1ScoreButton.alpha = 0.25
        player2ScoreButton.alpha = 0.25
    }
    
    //This function changes the layout of the labels when the tutorial is off
    func layoutWithoutTutorial() {
        tutorialStack.hidden = true
        timerLabel.alpha = 1
        player1TitleLabel.alpha = 1
        player2TitleLabel.alpha = 1
        player1ScoreButton.alpha = 1
        player2ScoreButton.alpha = 1
    }
    
    //This function eliminates the tutorial from the screen
    func eliminateTutorial(delay: Int) {
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(delay) * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            UIView.performSystemAnimation(.Delete, onViews: [self.tutorialStack], options: .BeginFromCurrentState, animations: {
                self.tutorialStack.alpha = 0
                self.layoutWithoutTutorial()
                }, completion: nil)
        }
    }
    
    
//MARK: Watch Communication Functions
    
    //This function that gets called everytime a tellPhoneToBeTheController notification is posted calls activatePhone()
    func receivedTellPhoneToBeTheControllerNotification(notification: NSNotification) {
        self.activatePhone()
    }
    
    //This function that gets called everytime a tellPhoneToBeTheScoreboard notification is posted calls deactivatePhone()
    func receivedTellPhoneToBeTheScoreboardNotification(notification: NSNotification) {
        self.deactivatePhone()
    }
    
    //This function that gets called everytime a tellPhoneToStartGame notification is posted calls startTimer()
    func receivedTellPhoneToStartGameNotification(notification: NSNotification) {
        let dataDict = notification.object as? [String : AnyObject]
        self.startTimer(dataDict!)
    }
    
    //This function that gets called everytime the tellPhoneToStopGame notification is posted calls restartGame()
    func receivedTellPhoneToStopGameNotification(notification: NSNotification) {
        self.restartGame()
    }
    
    //This function that gets called everytime a tellPhoneScoreData notification is posted calls displayLabels()
    func receivedTellPhoneScoreDataNotification(notification: NSNotification) {
        let dataDict = notification.object as? [String : AnyObject]
        self.displayLabels(dataDict!)
    }
    

//MARK: Swipe Functions
    
    //This funtions creates the swipe gestures and then adds them to the view
    func addSwipe() {
        let directions: [UISwipeGestureRecognizerDirection] = [.Down, .Up]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(ScoreboardViewController.handleSwipe(_:)))
            gesture.direction = direction
            self.view.addGestureRecognizer(gesture)
        }
    }
    
    //This functions handles each swipe and its functionality within the app
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        if sender.direction.rawValue == 8 && canScoreFromPhone == true && timerIsOn == false {
            self.beginClock()
            self.layoutWithoutTutorial()
        } else if sender.direction.rawValue == 4 && canScoreFromPhone == true && timerIsOn == true {
            self.restartGame()
            self.layoutWithTutorial()
        }
    }
    
//MARK: Actions
    
    //This function adds one to player 1 when the button is tapped
    @IBAction func player1ButtonTapped(sender: AnyObject) {
        player1Score = player1Score + 1
        player1ScoreButton.setTitle(String(player1Score), forState: .Normal)
    }
    
    //This function adds one to player 2 when the button is tapped
    @IBAction func player2ButtonTapped(sender: AnyObject) {
        player2Score = player2Score + 1
        player2ScoreButton.setTitle(String(player2Score), forState: .Normal)
    }
    
    
//MARK: Label Functions
    
    //This function restarts a game by resetting labels and variables while also invalidating the timer
    func restartGame() {
        timerIsOn = false
        if timer != nil {
           timer.invalidate()
        }
        startingGameTime = 600
        currentTime = 600
        timerLabel.text = "10:00"
        player1Score = 0
        player2Score = 0
        player1ScoreButton.setTitle("0", forState: .Normal)
        player2ScoreButton.setTitle("0", forState: .Normal)
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    //This functions updates the score labels to match the watch's data
    func displayLabels(dataDict: [String : AnyObject]) {
        player1ScoreButton.setTitle(String(dataDict["Score1"]!), forState: .Normal)
        player2ScoreButton.setTitle(String(dataDict["Score2"]!), forState: .Normal)
        player1Score = Int(String(dataDict["Score1"]!))
        player2Score = Int(String(dataDict["Score2"]!))
    }
    
    //This functions runs once per second until the totalTime variable reaches 0 before it calls timesUp() with the winning player as a parameter
    func eachSecond(timer: NSTimer) {
        if startingGameTime / 2 == currentTime && player1Score > player2Score {
            speakGameStatus("HalfWayPoint")
        }
        if currentTime == 60 {
            speakGameStatus("OneMinuteRemaining")
        }
        if currentTime >= 0 {
            timerLabel.text = self.convertSeconds(currentTime)
        } else {
            timer.invalidate()
        }
        if currentTime == 0 {
            if self.player1Score > self.player2Score {
                self.timesUp("Player1")
            } else if self.player2Score > self.player1Score {
                self.timesUp("Player2")
            } else {
                self.timesUp("Tie")
            }
            speakGameStatus("TimesUp")
        }
        currentTime = currentTime - 1
    }
    
    
//MARK: Timer Functions
    
    //This functions sets totalTime to the amount of starting time on the watch and then creates a timer that calls eachSecond()
    func startTimer(dataDict: [String : AnyObject]) {
        UIApplication.sharedApplication().idleTimerDisabled = true
        dispatch_async(dispatch_get_main_queue()) {
            if self.timerIsOn == false {
                self.currentTime = Int(String(dataDict["Time"]!))!
                self.beginClock()
            }
        }
    }
    
    //This function starts the clock
    func beginClock() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScoreboardViewController.eachSecond(_:)), userInfo: nil, repeats: true)
        self.timerIsOn = true
    }
    
    //This functions gets called when the time is up and determines which player is the winner
    func timesUp(winner: String) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        if winner == "Player1" {
            player1ScoreButton.setTitleColor(UIColor.greenColor(), forState: .Normal)
            player2ScoreButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        } else if winner == "Player2" {
            player2ScoreButton.setTitleColor(UIColor.greenColor(), forState: .Normal)
            player1ScoreButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        } else if winner == "Tie" {
            player1ScoreButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
            player2ScoreButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        }
    }
    
    //This function converts seconds into the string format minutes:seconds
    func convertSeconds(seconds: Int) -> String {
        let secs: Double! = Double(seconds)
        let minutePlace = Int(floor(secs / 60) % 60)
        let secondPlace = Int(floor(secs) % 60)
        return String(format: "%2d:%02d", minutePlace, secondPlace)
    }
    
//MARK: Speech Functions
    
    //This function sends a voice notification to the user about the status of the game
    func speakGameStatus(occasion: String) {
        if occasion == "HalfWayPoint" {
            if player1Score == player2Score {
                let statusNotice = AVSpeechUtterance(string: "At the halfway point of the game, both sides are tied at \(player1Score!)")
                self.speechSynthesizer.speakUtterance(statusNotice)
            } else if player1Score > player2Score {
                let statusNotice = AVSpeechUtterance(string: "Half of the game has passed. Player 1 is winning \(player1Score!) to \(player2Score!)")
                self.speechSynthesizer.speakUtterance(statusNotice)
            } else {
                let statusNotice = AVSpeechUtterance(string: "Half of the game has passed. Player 2 is winning \(player2Score!) to \(player1Score!)")
                self.speechSynthesizer.speakUtterance(statusNotice)
            }
        } else if occasion == "OneMinuteRemaining" {
            if player1Score == player2Score {
                let statusNotice = AVSpeechUtterance(string: "One minute remaining. Both sides are tied at \(player1Score!) a peice")
                self.speechSynthesizer.speakUtterance(statusNotice)
            } else if player1Score > player2Score {
                let statusNotice = AVSpeechUtterance(string: "One minute remaining. Player 2 is down by \(player1Score! - player2Score!) goals")
                self.speechSynthesizer.speakUtterance(statusNotice)
            } else {
                let statusNotice = AVSpeechUtterance(string: "One minute remaining. Player 1 is down by \(player2Score! - player1Score!) goals")
                self.speechSynthesizer.speakUtterance(statusNotice)
            }
        } else if occasion == "TimesUp" {
            if player1Score == player2Score {
                let statusNotice = AVSpeechUtterance(string: "Game over. Both sides tied the game with \(player1Score) points")
                self.speechSynthesizer.speakUtterance(statusNotice)
            } else if player1Score > player2Score {
                let statusNotice = AVSpeechUtterance(string: "Game over. Player 1 wins \(player1Score!) to \(player2Score!)")
                self.speechSynthesizer.speakUtterance(statusNotice)
            } else {
                let statusNotice = AVSpeechUtterance(string: "Game over. Player 2 wins \(player1Score!) to \(player2Score!)")
                self.speechSynthesizer.speakUtterance(statusNotice)
            }
        }
    }
    
}