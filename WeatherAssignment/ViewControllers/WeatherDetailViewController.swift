//
//  WeatherDetailViewController.swift
//  WeatherAssignment
//
//  Created by Arjun on 07/03/22.
//

import UIKit
import GooglePlaces

class WeatherDetailViewController: UIViewController {

    @IBOutlet weak var LoadingSpiiner: UIActivityIndicatorView!
    @IBOutlet weak var CurrentWeatherView: UIView!
    @IBOutlet weak var CityNameLabel: UILabel!
    @IBOutlet weak var CurrentWeatherIcon: UIImageView!
    @IBOutlet weak var WeatherConditionLabel: UILabel!
    @IBOutlet weak var DegreeLabel: UILabel!
    @IBOutlet weak var SunriseTimeLabel: UILabel!
    @IBOutlet weak var SunetTimeLabel: UILabel!
    @IBOutlet weak var FavouritesButton: UIBarButtonItem!
    @IBOutlet weak var SevenDaysButton: UIButton!

    var weatherData : WeatherData? = nil
    
    var currentPlace: GMSPlace? = nil {
        didSet {
            //handleFavouritesBtnIcon()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()

    }
    
    func initializeUI() -> Void {
        
        if (weatherData == nil) {
            return
        }
        
        self.navigationItem.backButtonTitle = ""
        self.navigationItem.title = "Weather Details"
        CurrentWeatherView.isHidden = true
        CityNameLabel.text = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        //use device default?
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+10")
        let sunriseDate = Date(timeIntervalSince1970: Double(self.weatherData!.current.sunrise))
        let sunsetDate = Date(timeIntervalSince1970: Double(self.weatherData!.current.sunset))
        self.CityNameLabel.text = currentPlace?.name
        self.WeatherConditionLabel.text = self.weatherData?.current.weather[0].main
        self.DegreeLabel.text = String(format: "%.0f", self.weatherData!.current.temp) + "°C"
        self.CurrentWeatherIcon.image = UIImage(named: (self.weatherData!.current.weather[0].icon))
        self.SunriseTimeLabel.text = dateFormatter.string(from: sunriseDate)
        self.SunetTimeLabel.text = dateFormatter.string(from: sunsetDate)
        self.CurrentWeatherView.isHidden = false
        
        
    }

    

}


extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        return scaledImage
    }
}
