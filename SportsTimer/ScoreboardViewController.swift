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
    @IBOutlet weak var watchIcon: UIButton!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var leftArrowButton: UIButton!
    @IBOutlet weak var rightArrowButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Variables
    
    let speechSynthesizer = AVSpeechSynthesizer()
    var timer: Timer!
    var startingGameTimeString: String = ""
    var startingGameTime: Int! = 600
    var currentTime: Int! = 600
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
        watchIcon.alpha = 0
        self.tableView.delegate = self
        self.tableView.dataSource = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.restartGame()
        PhoneSession.sharedInstance.startSession()
        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneWatchIsOnNotification(_:)), name:NSNotification.Name(rawValue: "tellPhoneWatchIsTiming"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneToStartGameNotification(_:)), name:NSNotification.Name(rawValue: "tellPhoneToStartGame"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneScoreDataNotification(_:)), name:NSNotification.Name(rawValue: "tellPhoneScoreData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneToStopGameNotification(_:)), name:NSNotification.Name(rawValue: "tellPhoneToStopGame"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneWatchIsInBackgroundNotification(_:)), name:NSNotification.Name(rawValue: "tellPhoneWatchIsInBackground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhonePotentialStartTimeNotification(_:)), name:NSNotification.Name(rawValue: "tellPhonePotentialStartTime"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneToPlayGameNotification(_:)), name:NSNotification.Name(rawValue: "tellPhoneToPlayGame"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScoreboardViewController.receivedTellPhoneToPauseGameNotification(_:)), name:NSNotification.Name(rawValue: "tellPhoneToPauseGame"), object: nil)
        
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
                watchIcon.setImage(#imageLiteral(resourceName: "WatchIconWhite"), for: .normal)
            } else if selectedSport == "Hockey" {
                backgroundImage.image = #imageLiteral(resourceName: "HockeyBackground")
                self.changeScoreboard(boardR: 11, boardG: 34, boardB: 15, elseR: 245, elseG: 245, elseB: 245)
                settingsIcon.setImage(#imageLiteral(resourceName: "SettingsIconWhite"), for: .normal)
                watchIcon.setImage(#imageLiteral(resourceName: "WatchIconWhite"), for: .normal)
            } else if selectedSport == "Soccer" {
                backgroundImage.image = #imageLiteral(resourceName: "SoccerBackground")
                self.changeScoreboard(boardR: 0, boardG: 9, boardB: 69, elseR: 245, elseG: 245, elseB: 245)
                settingsIcon.setImage(#imageLiteral(resourceName: "SettingsIconWhite"), for: .normal)
                watchIcon.setImage(#imageLiteral(resourceName: "WatchIconWhite"), for: .normal)
            } else if selectedSport == "Baseball" {
                backgroundImage.image = #imageLiteral(resourceName: "BaseballBackground")
                self.changeScoreboard(boardR: 47, boardG: 48, boardB: 48, elseR: 169, elseG: 124, elseB: 80)
                settingsIcon.setImage(#imageLiteral(resourceName: "SettingsIconWhite"), for: .normal)
                watchIcon.setImage(#imageLiteral(resourceName: "WatchIconWhite"), for: .normal)
            } else {
                backgroundImage.image = #imageLiteral(resourceName: "FootballBackground")
                self.changeScoreboard(boardR: 183, boardG: 175, boardB: 174, elseR: 10, elseG: 10, elseB: 10)
                settingsIcon.setImage(#imageLiteral(resourceName: "SettingsIconBlack"), for: .normal)
                watchIcon.setImage(#imageLiteral(resourceName: "WatchIconBlack"), for: .normal)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Watch Communication Functions
    
    //This function runs when the watch has been turned on
    func receivedTellPhoneWatchIsOnNotification(_ notification: NSNotification) {
        let dataDict = notification.object as? [String : AnyObject]
        if (dataDict?["WatchIsOn"]! as? Bool)! {
            watchIcon.alpha = 1
            playPauseButton.isEnabled = false
            player1ScoreButton.isEnabled = false
            player2ScoreButton.isEnabled = false
            settingsIcon.isEnabled = false
        } else {
            watchIcon.alpha = 0
            playPauseButton.isEnabled = true
            player1ScoreButton.isEnabled = true
            player2ScoreButton.isEnabled = true
            settingsIcon.isEnabled = true
        }
    }
    
    //This function runs when the watch starts a game
    func receivedTellPhoneToStartGameNotification(_ notification: Notification) {
        let dataDict = notification.object as? [String : AnyObject]
        self.startTimer(dataDict!)
        updatePlayPauseButton(title: "Playing game...", color: UIColor.init(red: 14/255, green: 161/255, blue: 87/255, alpha: 1))
    }
    
    //This function runs when the score is updated in anyway
    func receivedTellPhoneScoreDataNotification(_ notification: Notification) {
        let dataDict = notification.object as? [String : AnyObject]
        self.displayLabels(dataDict!)
    }
    
    //This function runs when the watch exits a game
    func receivedTellPhoneToStopGameNotification(_ notification: Notification) {
        if timer.isValid {
            self.restartGame()
        }
    }
    
    //This function tuns when the watch enters the background
    func receivedTellPhoneWatchIsInBackgroundNotification(_ notification: Notification) {
        print("Watch is in background")
    }
    
    //This function runs when the watch scrolls thru the potential start times
    func receivedTellPhonePotentialStartTimeNotification(_ notification: Notification) {
        let dataDict = notification.object as? [String : AnyObject]
        timerLabel.text = dataDict?["Time"] as! String?
    }
    
    //This function runs when the play button on the watch is tapped
    func receivedTellPhoneToPlayGameNotification(_ notification: Notification) {
        self.beginClock()
        updatePlayPauseButton(title: "Playing game...", color: UIColor.init(red: 14/255, green: 161/255, blue: 87/255, alpha: 1))
    }
    
    //This function runs when the pause button on the watch is tapped
    func receivedTellPhoneToPauseGameNotification(_ notification: Notification) {
        if timer != nil {
            timer.invalidate()
        }
        timerLabel.text = self.convertSeconds(currentTime)
        timerIsOn = false
        updatePlayPauseButton(title: "Game paused", color: UIColor.init(red: 158/255, green: 28/255, blue: 0/255, alpha: 1))
    }
    
    //MARK: Actions
    
    //This function runs when the play / pause button is tapped
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
        pageController.currentPage = 0
    }
    
    //This function changes the scoreboard back into a scoreboard when the right arrow is tapped
    @IBAction func rightArrowButtonIsTapped(_ sender: Any) {
        rightArrowButton.alpha = 0
        rightArrowButton.isEnabled = false
        leftArrowButton.alpha = 1
        leftArrowButton.isEnabled = true
        tableView.alpha = 1
        pageController.currentPage = 1
        if #available(iOS 10.0, *) {
            self.games = []
            self.retrieveFromCoreData()
            self.tableView.reloadData()
        } else {
            // Fallback on earlier versions
        }
    }
    
    //MARK: Label Functions
    
    //This function restarts a game by resetting labels and variables while also invalidating the timer
    func restartGame() {
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
        updatePlayPauseButton(title: "Start Game", color: UIColor.init(red: 14/255, green: 161/255, blue: 87/255, alpha: 1))
        
        if let selectedSport = UserDefaults.standard.object(forKey: "selectedSport") as? String {
            if selectedSport == "Basketball" {
                self.changeScoreboard(boardR: 101, boardG: 0, boardB: 0, elseR: 245, elseG: 245, elseB: 245)
            } else if selectedSport == "Hockey" {
                self.changeScoreboard(boardR: 11, boardG: 34, boardB: 15, elseR: 245, elseG: 245, elseB: 245)
            } else if selectedSport == "Soccer" {
                self.changeScoreboard(boardR: 0, boardG: 9, boardB: 69, elseR: 245, elseG: 245, elseB: 245)
            } else if selectedSport == "Baseball" {
                self.changeScoreboard(boardR: 47, boardG: 48, boardB: 48, elseR: 169, elseG: 124, elseB: 80)
            } else {
                self.changeScoreboard(boardR: 183, boardG: 175, boardB: 174, elseR: 10, elseG: 10, elseB: 10)
            }
        }
        
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
                let statusNotice = AVSpeechUtterance(string: "One minute remaining. \(player2TitleLabel.text!) is down by \(player1Score! - player2Score!) goals")
                self.speechSynthesizer.speak(statusNotice)
            } else {
                let statusNotice = AVSpeechUtterance(string: "One minute remaining. \(player1TitleLabel.text!) is down by \(player2Score! - player1Score!) goals")
                self.speechSynthesizer.speak(statusNotice)
            }
        } else if occasion == "TimesUp" {
            if player1Score == player2Score {
                let statusNotice = AVSpeechUtterance(string: "Game over. Both sides tied the game with \(player1Score) points")
                self.speechSynthesizer.speak(statusNotice)
            } else if player1Score > player2Score {
                let statusNotice = AVSpeechUtterance(string: "Game over. \(player1TitleLabel.text!) wins \(player1Score!) to \(player2Score!)")
                self.speechSynthesizer.speak(statusNotice)
            } else {
                let statusNotice = AVSpeechUtterance(string: "Game over. \(player2TitleLabel.text!) wins \(player2Score!) to \(player1Score!)")
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
                    self.games = games.reversed()
                }
            }
        } catch let error as NSError {
            fatalError("Failed to retrieve movie: \(error)")
        }
    }
    
    //This function deletes a specific game from CoreData
    @available(iOS 10.0, *)
    func deleteFromCoreData(_ indexPath: IndexPath) {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDelegate.persistentContainer.viewContext
        let gameToBeDeleted = games[(indexPath as NSIndexPath).row]
        context.delete(gameToBeDeleted)
        do {
            try context.save()
        } catch let error as NSError {
            fatalError("Failed to fetch movie: \(error)")
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
    
    //MARK: TableView Delegate Functions
    
    //This delegate function sets the amount of rows in the table view to 25
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    //This delegate functions sets data in each cell to the appropriate movie rank, name, date, and price
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GamesTableViewCell
        cell.player1Label.text = self.games[indexPath.row].player1
        cell.player1ScoreLabel.text = String(describing: self.games[indexPath.row].player1Score!)
        cell.player2Label.text = self.games[indexPath.row].player2
        cell.player2ScoreLabel.text = String(describing: self.games[indexPath.row].player2Score!)
        cell.dateLabel.text = games[indexPath.row].date
        return cell
    }
    
    //This delegate function allows the user to delete a cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if #available(iOS 10.0, *) {
                self.deleteFromCoreData(indexPath)
            } else {
                // Fallback on earlier versions
            }
            self.games.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.reloadData()
            if (self.games.count < 1) {
                
            }
        }
    }
    
}
