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
    
    
    var listenerForAcceptence: ListenerRegistration!
    var listenerForDriverOnItsWay: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            self.tabBar.unselectedItemTintColor = UIColor.white
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        RideStatusManager.shared.navigateToCurrentRideStatus(vc: self)
        listenerForAcceptence = RideStatusManager.shared.listenForRideAcceptence(vc: self)
        listenerForDriverOnItsWay = RideStatusManager.shared.listenForDriverOnItsWay(vc: self)
        
        DBService.fetchYourMessages { [weak self] error, messages in
            if let messages = messages {
                DBService.messagesRecieved = messages
                let newMessage = messages.filter({$0.read == false})
                if !newMessage.isEmpty{
                    self?.tabBar.items!.last!.badgeValue = newMessage.count.description
                } else {
                    self?.tabBar.items!.last!.badgeValue = nil
                }
            }
        }
        DBService.fetchDriverAcceptedRides() { [weak self] error, rides in
            if let error = error {
                self?.showAlert(title: "Error fetching your rides", message: error.localizedDescription)
            }
            if let rides = rides {
                let ridesToday = rides.filter{ Calendar.current.isDateInToday($0.appointmentDate.stringToDate())}
                if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue{
                    if !ridesToday.isEmpty{
                        self?.tabBar.items![2].badgeValue = ridesToday.count.description
                    } else {
                        self?.tabBar.items![2].badgeValue = nil
                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        listenerForDriverOnItsWay.remove()
        listenerForAcceptence.remove()
    }
    
    static func setTabBarVC(typeOfUser: String) -> UITabBarController{
        let availableManoVC = AvailableManosViewController()
        let favoritesVC = FavoritesViewController()
        let driverProfileVC = DriverProfileViewController()
        let requestRideVC = RequestRideViewController()
        let tab = TabBarViewController()
        let myLocations = MyLocationsViewController()
        let driveVC = DriveViewController()
        var controllers = [UIViewController]()
        

        if typeOfUser == TypeOfUser.Driver.rawValue {
            availableManoVC.tabBarItem = UITabBarItem.init(title: "Manos", image: UIImage(named: "hand"), tag: 0)
            favoritesVC.tabBarItem = UITabBarItem.init(title: "Passenger", image: UIImage(named: "favorites"), tag: 1)
            driveVC.tabBarItem = UITabBarItem.init(title: "Today", image: UIImage(named: "car"), tag: 2)
            driverProfileVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(named: "account"), tag: 3)
            controllers = [availableManoVC,favoritesVC,driveVC,driverProfileVC]
            
            UITabBar.appearance().barTintColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1)
            UITabBar.appearance().tintColor = #colorLiteral(red: 0.9882352941, green: 0.5137254902, blue: 0.2039215686, alpha: 1)
        } else {
            UITabBar.appearance().barTintColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
            UITabBar.appearance().tintColor = #colorLiteral(red: 0.9882352941, green: 0.5137254902, blue: 0.2039215686, alpha: 1)
            requestRideVC.tabBarItem = UITabBarItem(title: "Request", image: UIImage(named: "rider"), tag: 0)
            myLocations.tabBarItem = UITabBarItem(title: "My Locations", image: UIImage(named: "favorites"), tag: 1)
            favoritesVC.tabBarItem = UITabBarItem.init(title: "Drivers", image: UIImage(named: "wheel"), tag: 2)
            driverProfileVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(named: "account"), tag: 3)
            controllers = [requestRideVC, myLocations, favoritesVC, driverProfileVC]
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
