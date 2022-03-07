//
//  CurrentWeatherListViewController.swift
//  WeatherAssignment
//
//  Created by Arjun on 06/03/22.
//

import UIKit
import GooglePlaces

class CurrentWeatherListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var LoadingSpiiner: UIActivityIndicatorView!
    @IBOutlet weak var NavigationItem: UINavigationItem!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var tempRangeLabel: UILabel!
    @IBOutlet weak var CurrentWeatherView: UIView!
    
    @IBAction func favouritesPressHandler(_ sender: UIBarButtonItem) {
        let city: String = (currentPlace?.name)!
        let lat: Double = (currentPlace?.coordinate.latitude)!
        let lon: Double = (currentPlace?.coordinate.longitude)!
        let placeID: String = (currentPlace?.placeID)!
        let temperature: Double = (self.weatherData?.current.temp)!
        let weatherIcon: String = (weatherData?.current.weather[0].icon)!
        
        // Get user defauls
        let defaults = UserDefaults.standard
        var favourites: [String:String] = getFavourites()
        
        if(favourites[placeID] != nil){
            // Remove from favourites
            favourites[placeID] = nil
            defaults.removeObject(forKey: placeID)
            
            let alert = UIAlertController(title: "Favourites", message: "\(city) has been removed from your favourites.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            
            favourites[placeID] = city
            
            let faveObj: [String:Any] = [
                "city": city,
                "longitude": lon,
                "latitude": lat,
                "temperature": temperature,
                "weatherIcon": weatherIcon
            ]
            
            defaults.set(faveObj, forKey: placeID)
            
            let alert = UIAlertController(title: "Favourites", message: "\(city) added to favourites!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
        defaults.set(favourites, forKey: "favourites")
        
        handleFavouritesBtnIcon()
        
    }
    
    // Global variables
    var weatherData: WeatherData? = nil {
        didSet {
            // Dispatch UI updates back to the Main thread as this didSet{} is triggered by Async background thread
            DispatchQueue.main.async {
                self.cityNameLabel.text = self.currentPlace?.name
                self.degreeLabel.text = String(format: "%.0f", self.weatherData!.current.temp) + "°C"
                self.weatherConditionLabel.text = self.weatherData?.current.weather[0].main
                self.tempRangeLabel.text = String(format: "%.0f", self.weatherData!.current.temp) + "°C"
                self.tableView.isHidden = false
                self.tableView.reloadData()
                self.CurrentWeatherView.isHidden = false
                self.LoadingSpiiner.stopAnimating()
            }
        }
    }
    var currentPlace: GMSPlace? = nil {
        didSet {
            // Everytime currentPlace gets changed, getWeather() from API
            handleFavouritesBtnIcon()
            getWeather()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        let nib = UINib(nibName: "ListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ListTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        CurrentWeatherView.layer.cornerRadius = 10
        CurrentWeatherView.clipsToBounds = true
//        getWeather()
    }
    
    func initializeUI() {
        // Hide the View initially and only display Loading Spinner
        self.navigationItem.backButtonTitle = ""
        self.NavigationItem.title = "Hourly forecast for 48 hours"
        tableView.isHidden = true
        self.tableView.sectionHeaderHeight = 0
        CurrentWeatherView.isHidden = true
        
        
    }
    
    // Get favourites from UserDefaults
    func getFavourites() -> [String:String] {
        let defaults = UserDefaults.standard
        let favourites: [String:String] = defaults.object(forKey: "favourites") as? [String:String] ?? [:]
        return favourites
    }
    
    func handleFavouritesBtnIcon() {
        let favourites: [String:String] = getFavourites()
        
        let placeID: String = (currentPlace?.placeID)!
        
        if(favourites[placeID] != nil){
            NavigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: UIBarButtonItem.SystemItem.trash,
                target: self,
                action: #selector(favouritesPressHandler)
            )
        } else {
            NavigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: UIBarButtonItem.SystemItem.add,
                target: self,
                action: #selector(favouritesPressHandler)
            )
        }
    }
    
    
    // Get weather information from API call
    func getWeather() {
        let lat: Double = (currentPlace?.coordinate.latitude)!
        let lon: Double = (currentPlace?.coordinate.longitude)!
        
//        let lat:Double = 35
//        let lon:Double = 139
        // Read Open weather Api Key from api-keys.plist
        let apiKey = API.getApiKey(api: "OPEN_WEATHER")
        
        // Form API url
        //let url = "pro.openweathermap.org/data/2.5/forecast/hourly?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&mode=json"
        let url = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&exclude=minutely,daily,alerts&appid=\(apiKey)&units=metric"
        print(url)
        performRequest(urlString: url)
    }
    
    func performRequest(urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let safeData = data {
                    let dataString = String(data: safeData, encoding: .utf8)
                    print(dataString!)
                    self.parseJSON(data: safeData)
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(data: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: data)
            print(decodedData)
            // Set global variable to use to display weather
            weatherData = decodedData
        } catch {
            print(error)
        }
    }
    
}

extension CurrentWeatherListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.weatherData == nil {
            return 0
        }else{
            return self.weatherData!.hourly.count
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let dateTime = Date(timeIntervalSince1970: Double(self.weatherData!.hourly[indexPath.section].dt))
        cell.timeLabel.text = dateFormatter.string(from: dateTime)
        cell.weatherImageView.image = UIImage(named: (self.weatherData!.hourly[indexPath.section].weather[0].icon))?.scalePreservingAspectRatio(targetSize: CGSize(width: 80, height: 80))
        cell.temparatureLabel.text = String(format: "%.0f", self.weatherData!.hourly[indexPath.section].temp) + "°C"
        return cell
    }
}

extension CurrentWeatherListViewController: UITableViewDelegate {
    
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
        
        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "WeatherDetailVC") as! WeatherDetailViewController
            nextViewController.weatherData = self.weatherData
            nextViewController.currentPlace = self.currentPlace
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
        
    }
}
