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
import CoreData

class ScoreboardViewController: UIViewController {
    
//MARK: Outlets
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var player1TitleLabel: UILabel!
    @IBOutlet weak var player2TitleLabel: UILabel!
    @IBOutlet weak var player1ScoreButton: UIButton!
    @IBOutlet weak var player2ScoreButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    
//MARK: Variables
    
    let speechSynthesizer = AVSpeechSynthesizer()
    var timer: Timer!
    var startingGameTimeString: String = ""
    var startingGameTime: Int! = 10
    var currentTime: Int! = 10
    var player1Score: Int! = 0
    var player2Score: Int! = 0
    var timerIsOn: Bool! = false
    var canScoreFromPhone: Bool! = true
    var gameIsInOvertime: Bool! = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
//MARK: Boilerplate Functions
    
    //This function creates an instance of a shared session, checks for low power mode, establishes this class as an observer of the tellPhoneToBeTheScoreboard, tellPhoneToBeTheController, tellPhonePickedTime, tellPhoneToStartGame, tellPhoneToStopGame, tellPhoneScoreData, and tellPhoneTheTime notifications, and calls addSwipe() and layoutWithTutorial()
    override func viewDidLoad() {
        super.viewDidLoad()
//        PhoneSession.sharedInstance.startSession()
//        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneToBeTheControllerNotification(_:)), name:NSNotification.Name(rawValue: "tellPhoneToBeTheController"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneToBeTheScoreboardNotification(_:)), name:NSNotification.Name(rawValue: "tellPhoneToBeTheScoreboard"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhonePickedTimeNotification(_:)), name:NSNotification.Name(rawValue: "tellPhoneTimeFromPicker"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneToStartGameNotification(_:)), name:NSNotification.Name(rawValue: "tellPhoneToStartGame"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneToStopGameNotification(_:)), name:NSNotification.Name(rawValue: "tellPhoneToStopGame"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneScoreDataNotification(_:)), name:NSNotification.Name(rawValue: "tellPhoneScoreData"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //This function removes itself as an observer when the view disappears
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
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
        player1ScoreButton.setTitleColor(UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1), for: UIControlState())
        player2ScoreButton.setTitleColor(UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1), for: UIControlState())
    }
    
    //This function formats the screen to show that it is inactive
    func deactivatePhone() {
        canScoreFromPhone = false
        self.restartGame()
        view.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        timerLabel.textColor = UIColor(red: 22/255, green: 160/255, blue: 133/255, alpha: 1)
        player1TitleLabel.textColor = UIColor(red: 22/255, green: 160/255, blue: 133/255, alpha: 1)
        player2TitleLabel.textColor = UIColor(red: 22/255, green: 160/255, blue: 133/255, alpha: 1)
        player1ScoreButton.setTitleColor(UIColor(red: 22/255, green: 160/255, blue: 133/255, alpha: 1), for: UIControlState())
        player2ScoreButton.setTitleColor(UIColor(red: 22/255, green: 160/255, blue: 133/255, alpha: 1), for: UIControlState())
    }
    

    
    //This function eliminates the tutorial from the screen
//    func eliminateTutorial(_ delay: Int) {
//        let time = DispatchTime.now() + 5.0
//        DispatchQueue.main.asyncAfter(deadline: time) {
//            UIView.perform(.delete, on: [self.tutorialStack], options: .beginFromCurrentState, animations: {
//                self.tutorialStack.alpha = 0
//                self.layoutWithoutTutorial()
//                }, completion: nil)
//        }
//    }
    
    //This function updates the timer label as the time is changed on the watch's picker view
    func changeTimerLabel(_ dataDict: [String : AnyObject]) {
        startingGameTimeString = (dataDict["ChosenTime"]! as? String)!
        timerLabel.text = startingGameTimeString
    }
    
//MARK: Watch Communication Functions
    
    //This function that gets called everytime a tellPhoneToBeTheController notification is posted calls activatePhone()
    func receivedTellPhoneToBeTheControllerNotification(_ notification: Notification) {
        self.activatePhone()
    }
    
    //This function that gets called everytime a tellPhoneToBeTheScoreboard notification is posted calls deactivatePhone()
    func receivedTellPhoneToBeTheScoreboardNotification(_ notification: Notification) {
        self.deactivatePhone()
    }
    
    //This function that gets called everytime a receivedTellPhonePickedTime notification is posted calls changeTimerLabel()
    func receivedTellPhonePickedTimeNotification(_ notification: Notification) {
        let dataDict = notification.object as? [String : AnyObject]
        self.changeTimerLabel(dataDict!)
    }
    
    //This function that gets called everytime a tellPhoneToStartGame notification is posted calls startTimer()
    func receivedTellPhoneToStartGameNotification(_ notification: Notification) {
        let dataDict = notification.object as? [String : AnyObject]
        
        self.startTimer(dataDict!)
    }
    
    //This function that gets called everytime the tellPhoneToStopGame notification is posted calls restartGame()
    func receivedTellPhoneToStopGameNotification(_ notification: Notification) {
        self.restartGame()
    }
    
    //This function that gets called everytime a tellPhoneScoreData notification is posted calls displayLabels()
    func receivedTellPhoneScoreDataNotification(_ notification: Notification) {
        let dataDict = notification.object as? [String : AnyObject]
        self.displayLabels(dataDict!)
    }
    
//MARK: Actions
    
    
    @IBAction func playPauseButtonTapped(_ sender: Any) {
        if timerIsOn == false {
            self.beginClock()
            playPauseButton.setTitleColor(UIColor.red, for: .normal)
        } else {
            if timer != nil {
                timer.invalidate()
            }
            timerLabel.text = self.convertSeconds(currentTime)
            timerIsOn = false
            playPauseButton.setTitleColor(UIColor.green, for: .normal)
        }
    }
    
    //This function adds one to player 1 when the button is tapped
    @IBAction func player1ButtonTapped(_ sender: AnyObject) {
        if timerIsOn == true {
            player1Score = player1Score + 1
            player1ScoreButton.setTitle(String(player1Score), for: UIControlState())
        }
    }
    
    //This function adds one to player 2 when the button is tapped
    @IBAction func player2ButtonTapped(_ sender: AnyObject) {
        if timerIsOn == true {
            player2Score = player2Score + 1
            player2ScoreButton.setTitle(String(player2Score), for: UIControlState())
        }
    }
    
    //This function runs when the play button is tapped
    @IBAction func playButtonTapped(_ sender: AnyObject) {
        if timerIsOn == false && canScoreFromPhone == true {
            self.beginClock()
            timerIsOn = true
        }
    }
    
    //This function runs when the pause button is tapped
    @IBAction func pauseButtonTapped(_ sender: AnyObject) {
        if timerIsOn == true && canScoreFromPhone == true {
            
            if timer != nil {
                timer.invalidate()
            }
            timerLabel.text = self.convertSeconds(currentTime)
            timerIsOn = false
        }
    }
    
    
//MARK: Label Functions
    
    //This function restarts a game by resetting labels and variables while also invalidating the timer
    func restartGame() {
        gameIsInOvertime = false
        timerIsOn = false
        if timer != nil {
           timer.invalidate()
        }
        startingGameTimeString = convertSeconds(600)
        currentTime = 600
        timerLabel.text = startingGameTimeString
        player1Score = 0
        player2Score = 0
        player1ScoreButton.setTitle("0", for: UIControlState())
        player2ScoreButton.setTitle("0", for: UIControlState())
        self.player1ScoreButton.isEnabled = true
        self.player2ScoreButton.isEnabled = true
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    //This function runs when the user wants to play a five minute overtime period
    func startOvertime() {
        gameIsInOvertime = true
        startingGameTimeString = convertSeconds(300)
        currentTime = 300
        timerLabel.text = startingGameTimeString
        UIApplication.shared.isIdleTimerDisabled = false
        self.beginClock()
    }
    
    //This functions updates the score labels to match the watch's data
    func displayLabels(_ dataDict: [String : AnyObject]) {
        player1ScoreButton.setTitle(String(describing: dataDict["Score1"]!), for: UIControlState())
        player2ScoreButton.setTitle(String(describing: dataDict["Score2"]!), for: UIControlState())
        player1Score = Int(String(describing: dataDict["Score1"]!))
        player2Score = Int(String(describing: dataDict["Score2"]!))
    }
    
    //This functions runs once per second until the totalTime variable reaches 0 before it calls timesUp() with the winning player as a parameter
    func eachSecond(_ timer: Timer) {
        if startingGameTime / 2 == currentTime && gameIsInOvertime == false {
            speakGameStatus("HalfwayPoint")
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
    func startTimer(_ dataDict: [String : AnyObject]) {
        UIApplication.shared.isIdleTimerDisabled = true
        DispatchQueue.main.async {
            if self.timerIsOn == false {
                self.currentTime = Int(String(describing: dataDict["Time"]!))!
                self.startingGameTime = Int(String(describing: dataDict["Time"]!))!
                self.beginClock()
                self.player1ScoreButton.isEnabled = true
                self.player2ScoreButton.isEnabled = true
            }
        }
    }
    
    //This function starts the clock
    func beginClock() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScoreboardViewController.eachSecond(_:)), userInfo: nil, repeats: true)
        self.timerIsOn = true
    }
    
    //This function gets called when the time is up and determines which player is the winner
    func timesUp(_ winner: String) {
        self.player1ScoreButton.isEnabled = false
        self.player2ScoreButton.isEnabled = false
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        if winner == "Player1" {
            player1ScoreButton.setTitleColor(UIColor.green, for: UIControlState())
            player2ScoreButton.setTitleColor(UIColor.red, for: UIControlState())
        } else if winner == "Player2" {
            player2ScoreButton.setTitleColor(UIColor.green, for: UIControlState())
            player1ScoreButton.setTitleColor(UIColor.red, for: UIControlState())
        } else if winner == "Tie" {
            player1ScoreButton.setTitleColor(UIColor.blue, for: UIControlState())
            player2ScoreButton.setTitleColor(UIColor.blue, for: UIControlState())
            self.alertUserAboutOvertime()
        }
    }
    
    //This function allows the user to play an optional five minute overtime if the game ends in a tie
    func alertUserAboutOvertime() {
        let alertController = UIAlertController(title: nil, message: "Would you like to play a five minute overtime?", preferredStyle: .actionSheet)
        let playOvertime = UIAlertAction(title: "Let's play overtime", style: .default) { (action) in
            //self.beginClock()
            self.startOvertime()
        }
        let cancelAction = UIAlertAction(title: "End in Tie", style: .cancel, handler: nil)
        alertController.addAction(playOvertime)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //This function converts seconds into the string format minutes:seconds
    func convertSeconds(_ seconds: Int) -> String {
        let secs: Double! = Double(seconds)
        let minutePlace = Int(floor(secs / 60).truncatingRemainder(dividingBy: 60))
        let secondPlace = Int(floor(secs).truncatingRemainder(dividingBy: 60))
        return String(format: "%2d:%02d", minutePlace, secondPlace)
    }
    
//MARK: Speech Functions
    
    //This function sends a voice notification to the user about the status of the game
    func speakGameStatus(_ occasion: String) {
        if occasion == "HalfwayPoint" {
            if player1Score == player2Score {
                let statusNotice = AVSpeechUtterance(string: "At the halfway point of the game, both sides are tied at \(player1Score!)")
                self.speechSynthesizer.speak(statusNotice)
            } else if player1Score > player2Score {
                let statusNotice = AVSpeechUtterance(string: "Half of the game has passed. Player 1 is winning \(player1Score!) to \(player2Score!)")
                self.speechSynthesizer.speak(statusNotice)
            } else {
                let statusNotice = AVSpeechUtterance(string: "Half of the game has passed. Player 2 is winning \(player2Score!) to \(player1Score!)")
                self.speechSynthesizer.speak(statusNotice)
            }
        } else if occasion == "OneMinuteRemaining" {
            if player1Score == player2Score {
                let statusNotice = AVSpeechUtterance(string: "One minute remaining. Both sides are tied at \(player1Score!) a peice")
                self.speechSynthesizer.speak(statusNotice)
            } else if player1Score > player2Score {
                let statusNotice = AVSpeechUtterance(string: "One minute remaining. Player 2 is down by \(player1Score! - player2Score!) goals")
                self.speechSynthesizer.speak(statusNotice)
            } else {
                let statusNotice = AVSpeechUtterance(string: "One minute remaining. Player 1 is down by \(player2Score! - player1Score!) goals")
                self.speechSynthesizer.speak(statusNotice)
            }
        } else if occasion == "TimesUp" {
            if player1Score == player2Score {
                let statusNotice = AVSpeechUtterance(string: "Game over. Both sides tied the game with \(player1Score) points")
                self.speechSynthesizer.speak(statusNotice)
            } else if player1Score > player2Score {
                let statusNotice = AVSpeechUtterance(string: "Game over. Player 1 wins \(player1Score!) to \(player2Score!)")
                self.speechSynthesizer.speak(statusNotice)
            } else {
                let statusNotice = AVSpeechUtterance(string: "Game over. Player 2 wins \(player2Score!) to \(player1Score!)")
                self.speechSynthesizer.speak(statusNotice)
            }
        }
    }
    
}
