//
//  AvailableManosViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/19/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseMessaging
class AvailableManosViewController: UIViewController {

    let graphics = GraphicsClient()
    
    @IBOutlet weak var mapDetailView: RoundViewWithBorder!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pickupLabel: UILabel!
    @IBOutlet weak var dropOffLabel: UILabel!
    
    
    private var locationManager = CLLocationManager()
    
    var selectedRide: Ride!

    private var userLocation = CLLocation()
    
    var filteredRides = [Ride]() {
        didSet {
            DispatchQueue.main.async {
                self.manoListView.manosListTableView.reloadData()
                self.addMarkers()
            }
        }
    }
    var filtering = false
    var rides = [Ride]() {
        didSet {
            DispatchQueue.main.async {
                self.manoListView.manosListTableView.reloadData()
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
    lazy var filterView =  Bundle.main.loadNibNamed("FilterView", owner: self, options: nil)?.first as! FilterView
    lazy var filterButton: RoundedButton  = {
       var button = RoundedButton()
        button.addTarget(self, action: #selector(filterButtonPressed), for: .touchUpInside)
        button.setTitle("Filter", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.1607843137, green: 0.1725490196, blue: 0.1843137255, alpha: 0.5148223459)
        button.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 17)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    private var subViews = [UIView]()
    @IBOutlet weak var manoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMap()
        fetchRides()
        setupMapViewSubViews()
        mapView.addSubview(mapDetailView)
    }

    override func viewDidAppear(_ animated: Bool) {
       fetchRides()
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
    }
    
    func addMarkers() {
        var index = 0
        mapView.clear()
        if filtering {
            for ride in filteredRides {
                let location = CLLocationCoordinate2D(latitude: ride.pickupLat, longitude: ride.pickupLon)
                let marker = GMSMarker()
                marker.position = location
                marker.title = index.description
                let appointmentDate = ride.appointmentDate.stringToDate()
                let dateRequested = ride.dateRequested.stringToDate()
                print(ride.rideId)
                if appointmentDate.isInSameWeek() {
                    marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1))
                }
                if appointmentDate.isTodayOrTomorrow() {
                    marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0.995932281, green: 0.2765177786, blue: 0.3620784283, alpha: 1))
                }
                if appointmentDate.isOther() {
                    marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0, green: 0.6754498482, blue: 0.9192627668, alpha: 1))
                }
                if dateRequested.isNew() {
                    marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0, green: 0.7077997327, blue: 0, alpha: 1))
                }
                marker.map = mapView
                print("LAT: \(ride.pickupLat) , LON: \(ride.pickupLon)")
                index += 1
            }
        } else {
            for ride in rides {
                let location = CLLocationCoordinate2D(latitude: ride.pickupLat, longitude: ride.pickupLon)
                let marker = GMSMarker()
                marker.position = location
                marker.title = index.description
                let appointmentDate = ride.appointmentDate.stringToDate()
                let dateRequested = ride.dateRequested.stringToDate()
                print(ride.rideId)
                mapView.tintColor = .white
                mapView.backgroundColor = .white
                if appointmentDate.isInSameWeek() {
                    marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1))
                }
                if appointmentDate.isTodayOrTomorrow() {
                    marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0.995932281, green: 0.2765177786, blue: 0.3620784283, alpha: 1))
                }
                if appointmentDate.isOther() {
                    marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0, green: 0.6754498482, blue: 0.9192627668, alpha: 1))
                }
                if dateRequested.isNew() {
                    marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0, green: 0.7077997327, blue: 0, alpha: 1))
                }
                marker.map = mapView
                print("LAT: \(ride.pickupLat) , LON: \(ride.pickupLon)")
                index += 1
            }
        }

        self.mapView.reloadInputViews()
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
    
    func setupMapViewSubViews() {
        mapView.addSubview(filterView)
        mapView.addSubview(filterButton)
        filterView.delegate = self
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterView.translatesAutoresizingMaskIntoConstraints = false
        filterButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 15).isActive = true
        filterButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -12).isActive = true
        filterButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        filterButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        filterButton.layer.borderWidth = 1
        filterButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        filterView.centerXAnchor.constraint(equalTo: filterButton.centerXAnchor, constant: 0).isActive = true
        filterView.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 10).isActive = true
        filterView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        filterView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        filterView.isHidden = true
        filterView.layer.cornerRadius = 10
        filterView.clipsToBounds = true
        filterView.layer.borderWidth = 1
        filterView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

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
        DBService.updateRideToAccepted(ride: selectedRide) { (error) in
            if let error = error {
                self.showAlert(title: "Error updating ride", message: error.localizedDescription)
            }
        }
        mapDetailView.isHidden = true
        let rideAcceptedAlert = RideAcceptedAlertViewController(nibName: nil, bundle: nil, ride: selectedRide)
        rideAcceptedAlert.modalPresentationStyle = .overCurrentContext
        present(rideAcceptedAlert, animated: true)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        mapDetailView.isHidden = true
    }

    @objc func filterButtonPressed() {
        if filterView.isHidden {
            filterView.isHidden = false
            filterButton.setTitle("Cancel", for: .normal)
        } else {
            filteredRides = rides
            filterView.isHidden = true
            filterButton.setTitle("Filter", for: .normal)
        }
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
        
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, zoom: 11.0)
        mapView.animate(to: camera)
        locationManager.stopUpdatingLocation()
    }
}

extension AvailableManosViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapDetailView.isHidden = false
        let position = marker.position
        let camera = GMSCameraPosition.camera(withLatitude: position.latitude, longitude: position.longitude, zoom: 14.0)
        let index = Int(marker.title!)!
        var ride: Ride!
        if filtering {
            ride = filteredRides[index]
        } else {
            ride = rides[index]
        }
        
        selectedRide = ride
        dateLabel.text = ride.appointmentDate
        pickupLabel.text = "Pick-up:\n\(ride.pickupAddress)"
        dropOffLabel.text = "Drop-off:\n\(ride.dropoffAddress)"
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

extension AvailableManosViewController: FilterViewDelegate {
    func thisWeekTapped() {
        filtering = true
        filteredRides = rides.filter({$0.appointmentDate.stringToDate().isInSameWeek()})
    }
    
    func tomorrowTapped() {
        filtering = true
        filteredRides = rides.filter({$0.appointmentDate.stringToDate().isTodayOrTomorrow()})
    }
    
    func otherTapped() {
        filtering = true
       filteredRides = rides.filter({$0.appointmentDate.stringToDate().isOther()})
    }
    
    func newViewTapped() {
        filtering = true
        filteredRides = rides.filter({$0.dateRequested.stringToDate().isNew()})
    }
    
    
}
