//
//  FavouritesViewController.swift
//  WeatherAssignment
//
//  Created by Arjun on 06/03/22.
//

import UIKit
import GooglePlaces

class FavouritesViewController: UIViewController {

    @IBOutlet weak var myTableView: UITableView!
    var faveCities = [String]()
    var favePlaceID = [String]()
    var faveTemps = [Double]()
    var faveIcons = [String]()
    var currentPlace: GMSPlace? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        let nib = UINib(nibName: "ListTableViewCell", bundle: nil)
        myTableView.register(nib, forCellReuseIdentifier: "ListTableViewCell")
        myTableView.delegate = self
        myTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.backButtonTitle = ""
        self.tabBarController?.tabBar.isHidden = false
        self.navigationItem.title = "Favourites"
        faveCities = [String]()
        favePlaceID = [String]()
        let favourites = getFavourites()
        for (placeID, city) in (Array(favourites).sorted {$0.1 < $1.1}) {
            favePlaceID.append(placeID)
            faveCities.append(city)
            let place : [String:Any] = getFavourite(placeID: placeID)
            faveTemps.append(place["temperature"] as! Double)
            faveIcons.append(place["weatherIcon"] as! String)
        }
        myTableView?.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        myTableView.reloadData()
    }
    
    //Get GMS place from place ID
    func getGMSPlace(placeId: String) -> GMSPlace? {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "CurrentWeatherListVC") as! CurrentWeatherListViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
        //Get GMS Place with parameter city name from Google API to pass this GMSPlace as a input parameter for current weather screen
        let placesClient = GMSPlacesClient.shared()
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) |
            UInt(GMSPlaceField.coordinate.rawValue))
        let placeFound:GMSPlace? = nil
        placesClient.fetchPlace(fromPlaceID: placeId, placeFields: fields, sessionToken: nil, callback: {
            (place: GMSPlace?, error: Error?) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            if let place = place {
                nextViewController.currentPlace = place
            }
        })
        return placeFound
    }
    
    func getFavourites() -> [String:String] {
        //Get list favourite cities from the UserDefaults
        let defaults = UserDefaults.standard
        let favourites: [String:String] = defaults.object(forKey: "favourites") as? [String:String] ?? [:]
        return favourites
    }
    
    func getFavourite(placeID: String) -> [String:Any] {
        //Get favourite city from the UserDefaults
        let defaults = UserDefaults.standard
        let favourite: [String:Any] = defaults.object(forKey: placeID) as? [String:Any] ?? [:]
        return favourite
    }
}

extension FavouritesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return favePlaceID.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        cell.timeLabel.text = faveCities[indexPath.section]
        cell.temparatureLabel.text = "\(faveTemps[indexPath.section])" + "°C"
        cell.weatherImageView.image = UIImage(named: (faveIcons[indexPath.section]))
        return cell
    }
}

extension FavouritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let placeId = favePlaceID[indexPath.section]
        //After click a record, move to the current weather place with the corresponding city
        _ = getGMSPlace(placeId: placeId)
    }
}
    

    

