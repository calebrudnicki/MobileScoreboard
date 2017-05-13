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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func letsPlayButtonTapped(_ sender: Any) {
        UserDefaults.standard.set(player1TextField.text, forKey: "player1")
        UserDefaults.standard.set(player2TextField.text, forKey: "player2")
        UserDefaults.standard.set("User", forKey: "name")
    }
}
