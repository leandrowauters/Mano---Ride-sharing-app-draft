//
//  TabBarViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/19/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import CoreLocation
class TabBarViewController: UITabBarController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
            self.tabBar.unselectedItemTintColor = UIColor.white
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DBService.listenForRideAcceptence(passangerId: DBService.currentManoUser.userId) { (error, ride) in
            if let error = error {
                self.showAlert(title: "Error fetching accepted ride", message: error.localizedDescription)
            }
            if let ride = ride {
                let rideAcceptedAlertView = RideAcceptedAlertViewController(nibName: nil, bundle: nil, ride: ride)
                rideAcceptedAlertView.modalPresentationStyle = .overCurrentContext
                self.present(rideAcceptedAlertView, animated: true)
            }
        }
        DBService.listenForDriverOnItsWay { (error, ride) in

            if let error = error {
                self.showAlert(title: "Error updating to onItsWay", message: error.localizedDescription)
            }
            if let ride = ride {
                let location = CLLocation(latitude: ride.originLat, longitude: ride.originLon)
                GoogleHelper.calculateMilesAndTimeToDestination(pickup: true, ride: ride, userLocation: location, completion: { (miles, time) in
                    self.showAlert(title: "Your Driver it's on his way", message: nil, handler: { (okay) in
                        
                        DBService.updatePassangerKnowsDriverOnItsWay(ride: ride, completion: { (error) in
                            if let error = error {
                                print(error.localizedDescription)
                            }
                            
                        })
                        let onItsWayVc = OnItsWayViewController(nibName: nil, bundle: nil, duration: time, distance: miles, ride: ride)
                        self.navigationController?.pushViewController(onItsWayVc, animated: true)
                        
                    })
                })
            }
        }
        DBService.fetchYourMessages { (error, messages) in
            if let messages = messages {
                DBService.messagesRecieved = messages
                let newMessage = messages.filter({$0.read == false})
                self.tabBar.items!.last!.badgeValue = newMessage.count.description
            }
        }
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
            favoritesVC.tabBarItem = UITabBarItem.init(title: "Favorites", image: UIImage(named: "favorites"), tag: 1)
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
            driverProfileVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(named: "account"), tag: 2)
            controllers = [requestRideVC, myLocations, driverProfileVC]
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
