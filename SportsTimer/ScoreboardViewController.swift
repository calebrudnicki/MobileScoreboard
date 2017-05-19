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

class ScoreboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Outlets
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var player1TitleLabel: UILabel!
    @IBOutlet weak var player2TitleLabel: UILabel!
    @IBOutlet weak var player1ScoreButton: UIButton!
    @IBOutlet weak var player2ScoreButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var scoreboardContainer: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var settingsIcon: UIButton!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var leftArrowButton: UIButton!
    @IBOutlet weak var rightArrowButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var games: [Games] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreboardContainer.layer.cornerRadius = 10
        scoreboardContainer.layer.shadowColor = UIColor.black.cgColor
        scoreboardContainer.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        scoreboardContainer.layer.shadowOpacity = 1.0
        scoreboardContainer.layer.shadowRadius = 30
        leftArrowButton.alpha = 0
        leftArrowButton.isEnabled = false
        tableView.alpha = 0
        tableView.isEditing = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
//        PhoneSession.sharedInstance.startSession()
//        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneToBeTheControllerNotification(_:)), name:NSNotification.Name(rawValue: "tellPhoneToBeTheController"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneToBeTheScoreboardNotification(_:)), name:NSNotification.Name(rawValue: "tellPhoneToBeTheScoreboard"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhonePickedTimeNotification(_:)), name:NSNotification.Name(rawValue: "tellPhoneTimeFromPicker"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneToStartGameNotification(_:)), name:NSNotification.Name(rawValue: "tellPhoneToStartGame"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneToStopGameNotification(_:)), name:NSNotification.Name(rawValue: "tellPhoneToStopGame"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneScoreDataNotification(_:)), name:NSNotification.Name(rawValue: "tellPhoneScoreData"), object: nil)
    }
    
    //This function updates the scoreboard based on the selected sport when the view appears
    override func viewDidAppear(_ animated: Bool) {
        if let player1Name = UserDefaults.standard.object(forKey: "player1") as? String {
            player1TitleLabel.text = player1Name
        }
        if let player2Name = UserDefaults.standard.object(forKey: "player2") as? String {
            player2TitleLabel.text = player2Name
        }
        if let selectedSport = UserDefaults.standard.object(forKey: "selectedSport") as? String {
            if selectedSport == "Basketball" {
                backgroundImage.image = #imageLiteral(resourceName: "BasketballBackground")
                self.changeScoreboard(boardR: 101, boardG: 0, boardB: 0, elseR: 245, elseG: 245, elseB: 245)
                settingsIcon.setImage(#imageLiteral(resourceName: "SettingsIconWhite"), for: .normal)
            } else if selectedSport == "Hockey" {
                backgroundImage.image = #imageLiteral(resourceName: "HockeyBackground")
                self.changeScoreboard(boardR: 11, boardG: 34, boardB: 15, elseR: 245, elseG: 245, elseB: 245)
                settingsIcon.setImage(#imageLiteral(resourceName: "SettingsIconWhite"), for: .normal)
            } else if selectedSport == "Soccer" {
                backgroundImage.image = #imageLiteral(resourceName: "SoccerBackground")
                self.changeScoreboard(boardR: 0, boardG: 9, boardB: 69, elseR: 245, elseG: 245, elseB: 245)
                settingsIcon.setImage(#imageLiteral(resourceName: "SettingsIconWhite"), for: .normal)
            } else if selectedSport == "Baseball" {
                backgroundImage.image = #imageLiteral(resourceName: "BaseballBackground")
                self.changeScoreboard(boardR: 47, boardG: 48, boardB: 48, elseR: 169, elseG: 124, elseB: 80)
                settingsIcon.setImage(#imageLiteral(resourceName: "SettingsIconWhite"), for: .normal)
            } else {
                backgroundImage.image = #imageLiteral(resourceName: "FootballBackground")
                self.changeScoreboard(boardR: 183, boardG: 175, boardB: 174, elseR: 10, elseG: 10, elseB: 10)
                settingsIcon.setImage(#imageLiteral(resourceName: "SettingsIconBlack"), for: .normal)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //This function removes itself as an observer when the view disappears
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Watch Communication Functions
    
    //This function that gets called everytime a tellPhoneToBeTheController notification is posted calls activatePhone()
//    func receivedTellPhoneToBeTheControllerNotification(_ notification: Notification) {
//        self.activatePhone()
//    }
//    
//    //This function that gets called everytime a tellPhoneToBeTheScoreboard notification is posted calls deactivatePhone()
//    func receivedTellPhoneToBeTheScoreboardNotification(_ notification: Notification) {
//        print("Scoring from watch now")
//        changeScoreboard(boardR: 0, boardG: 0, boardB: 0, elseR: 0, elseG: 0, elseB: 0)
//    }
//    
//    //This function that gets called everytime a receivedTellPhonePickedTime notification is posted calls changeTimerLabel()
//    func receivedTellPhonePickedTimeNotification(_ notification: Notification) {
//        let dataDict = notification.object as? [String : AnyObject]
//        self.changeTimerLabel(dataDict!)
//    }
//
//    //This function that gets called everytime a tellPhoneToStartGame notification is posted calls startTimer()
//    func receivedTellPhoneToStartGameNotification(_ notification: Notification) {
//        let dataDict = notification.object as? [String : AnyObject]
//        
//        self.startTimer(dataDict!)
//    }
//    
//    //This function that gets called everytime the tellPhoneToStopGame notification is posted calls restartGame()
//    func receivedTellPhoneToStopGameNotification(_ notification: Notification) {
//        self.restartGame()
//    }
//    
//    //This function that gets called everytime a tellPhoneScoreData notification is posted calls displayLabels()
//    func receivedTellPhoneScoreDataNotification(_ notification: Notification) {
//        let dataDict = notification.object as? [String : AnyObject]
//        self.displayLabels(dataDict!)
//    }
    
//MARK: Actions
    
    //This function
    @IBAction func playPauseButtonTapped(_ sender: Any) {
        if currentTime == -2 {
            self.restartGame()
        }
        
        if timerIsOn == false {
            self.beginClock()
            updatePlayPauseButton(title: "Pause", color: UIColor.init(red: 158/255, green: 28/255, blue: 0/255, alpha: 1))
        } else {
            if timer != nil {
                timer.invalidate()
            }
            timerLabel.text = self.convertSeconds(currentTime)
            timerIsOn = false
            updatePlayPauseButton(title: "Play", color: UIColor.init(red: 14/255, green: 161/255, blue: 87/255, alpha: 1))
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
    
    //This function changes the scoreboard into a table view full of past scores when the left arrow is tapped
    @IBAction func leftArrowButtonIsTapped(_ sender: Any) {
        leftArrowButton.alpha = 0
        leftArrowButton.isEnabled = false
        rightArrowButton.alpha = 1
        rightArrowButton.isEnabled = true
        tableView.alpha = 0
        tableView.isEditing = false
        pageController.currentPage = 0
    }
    
    //This function changes the scoreboard back into a scoreboard when the right arrow is tapped
    @IBAction func rightArrowButtonIsTapped(_ sender: Any) {
        rightArrowButton.alpha = 0
        rightArrowButton.isEnabled = false
        leftArrowButton.alpha = 1
        leftArrowButton.isEnabled = true
        tableView.alpha = 1
        tableView.isEditing = true
        pageController.currentPage = 1
    }
    
    //MARK: Label Functions
    
    //This function restarts a game by resetting labels and variables while also invalidating the timer
    func restartGame() {
        timerIsOn = false
        if timer != nil {
           timer.invalidate()
        }
        startingGameTimeString = convertSeconds(10)
        currentTime = 10
        timerLabel.text = startingGameTimeString
        player1Score = 0
        player2Score = 0
        player1ScoreButton.setTitle("0", for: UIControlState())
        player2ScoreButton.setTitle("0", for: UIControlState())
        player1ScoreButton.setTitleColor(UIColor.white, for: .normal)
        player2ScoreButton.setTitleColor(UIColor.white, for: .normal)
        self.player1ScoreButton.isEnabled = true
        self.player2ScoreButton.isEnabled = true
        UIApplication.shared.isIdleTimerDisabled = false
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
        if startingGameTime / 2 == currentTime {
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
        updatePlayPauseButton(title: "Start New Game", color: UIColor.init(red: 14/255, green: 161/255, blue: 87/255, alpha: 1))
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        if winner == "Player1" {
            player1ScoreButton.setTitleColor(UIColor.init(red: 14/255, green: 161/255, blue: 87/255, alpha: 1), for: UIControlState())
            player2ScoreButton.setTitleColor(UIColor.init(red: 158/255, green: 28/255, blue: 0/255, alpha: 1), for: UIControlState())
        } else if winner == "Player2" {
            player2ScoreButton.setTitleColor(UIColor.init(red: 14/255, green: 161/255, blue: 87/255, alpha: 1), for: UIControlState())
            player1ScoreButton.setTitleColor(UIColor.init(red: 158/255, green: 28/255, blue: 0/255, alpha: 1), for: UIControlState())
        } else if winner == "Tie" {
            player1ScoreButton.setTitleColor(UIColor.init(red: 48/255, green: 85/255, blue: 165/255, alpha: 1), for: UIControlState())
            player2ScoreButton.setTitleColor(UIColor.init(red: 48/255, green: 85/255, blue: 165/255, alpha: 1), for: UIControlState())
        }
        //This is where all the Core Data stuff currently is
        if #available(iOS 10.0, *) {
            self.addGameToCoreData()
            self.retrieveFromCoreData()
            for i in 0...games.count - 1 {
                print(i)
                print(games[i].player1!)
                print(games[i].player1Score!)
                print(games[i].player2!)
                print(games[i].player2Score!)
                print(games[i].date!)
            }
        } else {
            print("Can't save to core data")
        }
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
                let statusNotice = AVSpeechUtterance(string: "Half of the game has passed. \(player1TitleLabel.text!) is winning \(player1Score!) to \(player2Score!)")
                self.speechSynthesizer.speak(statusNotice)
            } else {
                let statusNotice = AVSpeechUtterance(string: "Half of the game has passed. \(player2TitleLabel.text!) is winning \(player2Score!) to \(player1Score!)")
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
    
    //MARK: Core Data Functions
    
    //This function adds a game to core data
    @available(iOS 10.0, *)
    func addGameToCoreData() {
        let context = appDelegate.persistentContainer.viewContext
        let newGame = NSEntityDescription.insertNewObject(forEntityName: "Games", into: context)
        newGame.setValue(player1TitleLabel.text, forKey: "player1")
        newGame.setValue(player2TitleLabel.text, forKey: "player2")
        newGame.setValue(player1Score, forKey: "player1Score")
        newGame.setValue(player2Score, forKey: "player2Score")
        newGame.setValue(self.getCurrentDate(), forKey: "date")
        do {
            try context.save()
            print("Saved game to CoreData")
        } catch let error as NSError {
            fatalError("Failed to add game to Core Data: \(error)")
        }
    }
    
    //This functions gets the games from core data and saves them in the array games
    @available(iOS 10.0, *)
    func retrieveFromCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Games")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    self.games.append((result as? Games)!)
                }
            }
        } catch let error as NSError {
            fatalError("Failed to retrieve movie: \(error)")
        }
    }
    
    //MARK: Helper Functions
    
    //This function updates the timer label as the time is changed on the watch's picker view
    func changeTimerLabel(_ dataDict: [String : AnyObject]) {
        startingGameTimeString = (dataDict["ChosenTime"]! as? String)!
        timerLabel.text = startingGameTimeString
    }
    
    //This function changes the actual objects on the screen based on what sport was selected
    func changeScoreboard(boardR: CGFloat, boardG: CGFloat, boardB: CGFloat, elseR: CGFloat, elseG: CGFloat, elseB: CGFloat) {
        scoreboardContainer.backgroundColor = UIColor.init(red: boardR/255, green: boardG/255, blue: boardB/255, alpha: 1)
        timerLabel.textColor = UIColor.init(red: elseR/255, green: elseG/255, blue: elseB/255, alpha: 1)
        player1TitleLabel.textColor = UIColor.init(red: elseR/255, green: elseG/255, blue: elseB/255, alpha: 1)
        player1ScoreButton.setTitleColor(UIColor.init(red: elseR/255, green: elseG/255, blue: elseB/255, alpha: 1), for: .normal)
        player2TitleLabel.textColor = UIColor.init(red: elseR/255, green: elseG/255, blue: elseB/255, alpha: 1)
        player2ScoreButton.setTitleColor(UIColor.init(red: elseR/255, green: elseG/255, blue: elseB/255, alpha: 1), for: .normal)
    }
    
    //This functions gets the current date in the MM/DD/YYYY formate
    func getCurrentDate() -> String {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day,], from: date)
        return String(describing: components.month!) + "/" + String(describing: components.day!) + "/" + String(describing: components.year!)
    }
    
    //This function toggles between the play and pause buttons
    func updatePlayPauseButton(title: String, color: UIColor) {
        self.playPauseButton.backgroundColor = color
        self.playPauseButton.setTitle(title, for: .normal)
    }
    
    //This delegate function sets the amount of rows in the table view to 25
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    //This delegate functions sets data in each cell to the appropriate movie rank, name, date, and price
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ViewControllerTableViewCell
        cell.rankLabel.text = String(indexPath.row + 1)
        return cell
    }
    
}
