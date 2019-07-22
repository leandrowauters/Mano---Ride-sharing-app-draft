//
//  AvailableManosViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/19/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import GoogleMaps
class AvailableManosViewController: UIViewController {

    let graphics = GraphicsClient()
    
    @IBOutlet weak var mapDetailView: RoundViewWithBorder!
    @IBOutlet weak var passangerName: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pickupLabel: UILabel!
    @IBOutlet weak var dropoffLabel: UILabel!
    
    
    private var locationManager = CLLocationManager()
    
    
    private var userLocation = CLLocation()
    
    var rides = [Ride]() {
        didSet {
            DispatchQueue.main.async {
                self.manoListView.manosListTableView.reloadData()
                self.mapView.reloadInputViews()
                self.addMarkers()
            }
        }
    }
    
    lazy var customSegmentedBar: UISegmentedControl = graphics.segmentedControlBar(titles: ["Map", "List"],numberOfSegments: 2)
    
    lazy var animatedView: UIView = graphics.animatedView
    
    lazy var animatedViewRail: UIView = graphics.animatedViewRail
    

//    lazy var mapView = Bundle.main.loadNibNamed("MapView", owner: self, options: nil)?.first as! GMSMapView
    lazy var mapView = GMSMapView()
    
    lazy var manoListView = Bundle.main.loadNibNamed("ManosList", owner: self, options: nil)?.first as! ManosList
    
    private var subViews = [UIView]()
    @IBOutlet weak var manoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMap()
        fetchRides()
        mapView.addSubview(mapDetailView)
        // Do any additional setup after loading the view.
    }
    func fetchRides(){
        DBService.fetchAllRides { (error, rides) in
            if let error = error {
                self.showAlert(title: "Error fetching rides", message: error.localizedDescription)
            }
            if let rides = rides {
                self.rides = rides
            }
        }
    }
    
    func setupMap() {
        mapView.delegate = self
        manoListView.manosListTableView.delegate = self
        manoListView.manosListTableView.dataSource = self
        locationManager.delegate = self
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        
        

//        let mapView
    }
    func addMarkers() {
        for ride in rides {
            let location = CLLocationCoordinate2D(latitude: ride.pickupLat, longitude: ride.pickupLon)
            let marker = GMSMarker()
            marker.position = location
            marker.map = mapView
            marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1))
        }
    }
    func setupUI() {
        view.addSubview(customSegmentedBar)
        customSegmentedBar.translatesAutoresizingMaskIntoConstraints = false
        customSegmentedBar.topAnchor.constraint(equalTo: manoImage.bottomAnchor).isActive = true
        customSegmentedBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        customSegmentedBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        customSegmentedBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        graphics.setupAnimatedViewRail(view: view, animatedViewRail: animatedViewRail, customSegmentedBar: customSegmentedBar)
        graphics.setupAnimatedView(view: view, animatedView: animatedView, customSegmentedBar: customSegmentedBar, numberOfSegments: 2)
        customSegmentedBar.addTarget(self, action: #selector(customSegmentedBarPressed(sender:)), for: UIControl.Event.valueChanged)
        setupSubViews(views: [mapView, manoListView])
        manoListView.manosListTableView.delegate = self
        manoListView.manosListTableView.dataSource = self
        manoListView.manosListTableView.register(UINib(nibName: "ManosListCell", bundle: nil), forCellReuseIdentifier: "ManosListCell")
    }
    func setupSubViews(views: [UIView]) {
        subViews = views
        for view in views {
            view.isHidden = true
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.topAnchor.constraint(equalTo: animatedViewRail.bottomAnchor).isActive = true
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }
        views.first!.isHidden = false
    }
    @objc func customSegmentedBarPressed(sender: UISegmentedControl){
        for i in 0...subViews.count - 1 {
            if i == sender.selectedSegmentIndex{
                subViews[i].isHidden = false
            } else {
                subViews[i].isHidden = true
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.animatedView.frame.origin.x = (self.customSegmentedBar.frame.width / CGFloat(self.customSegmentedBar.numberOfSegments)) * CGFloat(self.customSegmentedBar.selectedSegmentIndex)
        }
    }

    @IBAction func acceptPressed(_ sender: Any) {
        
    }
    @IBAction func cancelPressed(_ sender: Any) {
        mapDetailView.isHidden = true
    }
}

extension AvailableManosViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {return}
        
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, zoom: 14.0)
        mapView.animate(to: camera)
        locationManager.stopUpdatingLocation()
    }
}

extension AvailableManosViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapDetailView.isHidden = false
        let position = marker.position
        let camera = GMSCameraPosition.camera(withLatitude: position.latitude, longitude: position.longitude, zoom: 14.0)
        mapView.animate(to: camera)
        return true
    }
}

extension AvailableManosViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ManosListCell", for: indexPath) as? ManosListCell else {return UITableViewCell()}
        let ride = rides[indexPath.row]
        cell.name.text = ride.passanger
        cell.address.text = ride.pickupAddress
        cell.appointmentDateLabel.text = ride.appointmentDate
        cell.riderDistance.text = ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190
    }
    
}
