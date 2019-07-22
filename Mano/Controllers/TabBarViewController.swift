//
//  TabBarViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/19/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    public var typeOfUser = String()
    private var userID: String?
    override func viewDidLoad() {
        super.viewDidLoad()
            self.tabBar.unselectedItemTintColor = UIColor.white
        guard let userID = userID else {return}
        DBService.fetchManoUser(userId: userID) { (error, manoUser) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let manoUser = manoUser {
                DBService.currentManoUser = manoUser
                //TO DO
                
                
                
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    static func setTabBarVC(typeOfUser: String,userId: String?) -> UITabBarController{
        let availableManoVC = AvailableManosViewController()
        let favoritesVC = FavoritesViewController()
        let driverProfileVC = DriverProfileViewController()
        let requestRideVC = RequestRideViewController()
        let tab = TabBarViewController()
        var controllers = [UIViewController]()


        if typeOfUser == TypeOfUser.Driver.rawValue {
            availableManoVC.tabBarItem = UITabBarItem.init(title: "Manos", image: UIImage(named: "car"), tag: 0)
            favoritesVC.tabBarItem = UITabBarItem.init(title: "Favorites", image: UIImage(named: "favorites"), tag: 1)
            driverProfileVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(named: "account"), tag: 2)
            controllers = [availableManoVC,favoritesVC,driverProfileVC]
            tab.typeOfUser = typeOfUser
            UITabBar.appearance().barTintColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1)
            UITabBar.appearance().tintColor = #colorLiteral(red: 0.9882352941, green: 0.5137254902, blue: 0.2039215686, alpha: 1)
        } else {
            UITabBar.appearance().barTintColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
            UITabBar.appearance().tintColor = #colorLiteral(red: 0.9882352941, green: 0.5137254902, blue: 0.2039215686, alpha: 1)
            requestRideVC.tabBarItem = UITabBarItem(title: "Request", image: UIImage(named: "rider"), tag: 0)
            controllers = [requestRideVC]
            tab.typeOfUser = typeOfUser
        }
       

        tab.viewControllers = controllers
        
        
        return tab
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
