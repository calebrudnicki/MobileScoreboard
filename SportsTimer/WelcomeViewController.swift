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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func letsPlayButtonTapped(_ sender: Any) {
        UserDefaults.standard.set(player1TextField.text, forKey: "player1")
        UserDefaults.standard.set(player2TextField.text, forKey: "player2")
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
    }
    
}
