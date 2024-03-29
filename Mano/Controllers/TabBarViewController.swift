//
//  TabBarViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/19/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
class TabBarViewController: UITabBarController {
    
    

    var listenerForDriverOnItsWay: ListenerRegistration!
    var listenerForMessages: ListenerRegistration!
    var listenerForFetchRides: ListenerRegistration!
    var listenerForUserChanges: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            self.tabBar.unselectedItemTintColor = UIColor.white
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Passenger.rawValue {
            listenerForDriverOnItsWay = ListenerHelper.shared.listenForDriverOnItsWay(vc: self)
        }
        ListenerHelper.shared.navigateToCurrentRideStatus(vc: self)
        listenerForMessages = ListenerHelper.shared.fetchMessages(vc: self)
        listenerForFetchRides = ListenerHelper.shared.fetchAcceptedRides(vc: self)
        listenerForUserChanges = ListenerHelper.shared.listenToUserChanges(vc: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Passenger.rawValue {
            listenerForDriverOnItsWay.remove()
        }
        listenerForMessages.remove()
        listenerForFetchRides.remove()
        listenerForUserChanges.remove()
    }
    
    static func setTabBarVC(typeOfUser: String) -> UITabBarController{
        let availableManoVC = AvailableManosViewController()
        let favoritesVC = FavoritesViewController()
        let driverProfileVC = DriverProfileViewController()
        let requestRideVC = RequestRideViewController()
        let tab = TabBarViewController()
        let myLocations = MyLocationsViewController()
        let driveVC = DriveViewController()
        let messagesVC = MessageViewController()
        var controllers = [UIViewController]()
        

        if typeOfUser == TypeOfUser.Driver.rawValue {
            availableManoVC.tabBarItem = UITabBarItem.init(title: "Manos", image: UIImage(named: "hand"), tag: 0)
            favoritesVC.tabBarItem = UITabBarItem.init(title: "Passenger", image: UIImage(named: "favorites"), tag: 1)
            driveVC.tabBarItem = UITabBarItem.init(title: "Today", image: UIImage(named: "car"), tag: 2)
            messagesVC.tabBarItem = UITabBarItem.init(title: "Messages", image: UIImage(named: "envelope"), tag: 3)
            driverProfileVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(named: "account"), tag: 4)
            controllers = [availableManoVC,favoritesVC,driveVC,messagesVC,driverProfileVC]
            
            UITabBar.appearance().barTintColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1)
            UITabBar.appearance().tintColor = #colorLiteral(red: 0.9882352941, green: 0.5137254902, blue: 0.2039215686, alpha: 1)
        } else {
            UITabBar.appearance().barTintColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
            UITabBar.appearance().tintColor = #colorLiteral(red: 0.9882352941, green: 0.5137254902, blue: 0.2039215686, alpha: 1)
            requestRideVC.tabBarItem = UITabBarItem(title: "Request", image: UIImage(named: "rider"), tag: 0)
            myLocations.tabBarItem = UITabBarItem(title: "My Locations", image: UIImage(named: "favorites"), tag: 1)
            favoritesVC.tabBarItem = UITabBarItem.init(title: "Drivers", image: UIImage(named: "wheel"), tag: 2)
            messagesVC.tabBarItem = UITabBarItem.init(title: "Messages", image: UIImage(named: "envelope"), tag: 3)
            driverProfileVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(named: "account"), tag: 4)
            controllers = [requestRideVC, myLocations, favoritesVC,messagesVC, driverProfileVC]
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
