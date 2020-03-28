//
//  TabBarViewController.swift
//  Weekly Lifts
//
//  Created by Kang-hee cho on 5/12/19.
//  Copyright © 2019 Kang-hee Cho. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self;
        UITabBar.appearance().barTintColor = .black
        UITabBar.appearance().tintColor =  .yellow
        
        // Do any additional setup after loading the view.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item.title)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
