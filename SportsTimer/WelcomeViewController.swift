//
//  WelcomeViewController.swift
//  SportsTimer
//
//  Created by Caleb Rudnicki on 5/10/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var player1TextField: UITextField!
    @IBOutlet weak var player2TextField: UITextField!
    @IBOutlet weak var sportsSegmentedController: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    
    let imagesListArray = [#imageLiteral(resourceName: "SoccerBackground"), #imageLiteral(resourceName: "BasketballBackground"), #imageLiteral(resourceName: "BaseballBackground"), #imageLiteral(resourceName: "HockeyBackground"), #imageLiteral(resourceName: "FootballBackground")]
    
    //This functions animates the background images and pulls info from the UserDefaults
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.animationImages = imagesListArray
        self.imageView.animationDuration = 10
        self.imageView.startAnimating()
        if let player1Name = UserDefaults.standard.object(forKey: "player1") as? String {
            player1TextField.text = player1Name
        }
        if let player2Name = UserDefaults.standard.object(forKey: "player2") as? String {
            player2TextField.text = player2Name
        }
        if let selectedSport = UserDefaults.standard.object(forKey: "selectedSport") as? String {
            if selectedSport == "Basketball" {
                sportsSegmentedController.selectedSegmentIndex = 0
            } else if selectedSport == "Hockey" {
                sportsSegmentedController.selectedSegmentIndex = 1
            } else if selectedSport == "Soccer" {
                sportsSegmentedController.selectedSegmentIndex = 2
            } else if selectedSport == "Baseball" {
                sportsSegmentedController.selectedSegmentIndex = 3
            } else {
                sportsSegmentedController.selectedSegmentIndex = 4
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(WelcomeViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WelcomeViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        PhoneSession.sharedInstance.startSession()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Actions

    //This functions handles setting UserDefaults when the Let's Play button is tapped
    @IBAction func letsPlayButtonTapped(_ sender: Any) {
        if player1TextField.text != "" {
            UserDefaults.standard.set(player1TextField.text, forKey: "player1")
        } else {
            UserDefaults.standard.set("Player 1", forKey: "player1")
        }

        if player2TextField.text != "" {
            UserDefaults.standard.set(player2TextField.text, forKey: "player2")
        } else {
            UserDefaults.standard.set("Player 2", forKey: "player2")
        }

        if sportsSegmentedController.selectedSegmentIndex == 0 {
            UserDefaults.standard.set("Basketball", forKey: "selectedSport")
        } else if sportsSegmentedController.selectedSegmentIndex == 1 {
            UserDefaults.standard.set("Hockey", forKey: "selectedSport")
        } else if sportsSegmentedController.selectedSegmentIndex == 2 {
            UserDefaults.standard.set("Soccer", forKey: "selectedSport")
        } else if sportsSegmentedController.selectedSegmentIndex == 3 {
            UserDefaults.standard.set("Baseball", forKey: "selectedSport")
        } else if sportsSegmentedController.selectedSegmentIndex == 4 {
            UserDefaults.standard.set("Football", forKey: "selectedSport")
        }
        
        if (UserDefaults.standard.value(forKey: "name") as? String) == nil {
            UserDefaults.standard.set("User", forKey: "name")
            performSegue(withIdentifier: "showScoreboardSegue", sender: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
        
        PhoneSession.sharedInstance.tellWatchPlayerNames(player1TextField.text!, player2Name: player2TextField.text!)
    }
    
    //MARK: Keyboard Functions
    
    //This function shows the keyboard when the text field is tapped
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    //This function hides the keyboard when anything but the text field is tapped
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
}
