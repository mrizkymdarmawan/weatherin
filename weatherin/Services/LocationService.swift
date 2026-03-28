//
//  LocationService.swift
//  weatherin
//
//  Created by Muhammad Rizky Maulana Darmawan on 13/03/26.
//

// GPS is deprioritized in this app — city search is the primary way to set a location.
// The deprecated warnings were caused by CLGeocoder (for reverse geocoding lat/lng → city name).
// Since CLGeocoder was deprecated in iOS 26, and GPS is a secondary feature anyway,
// we simply removed the reverse geocoding step and use "My Location" as a generic label.

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()

    var cityName: String = "My Location"
    var latitude: Double = 0.0
    var longitude: Double = 0.0

    func requestLocation() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        latitude  = location.coordinate.latitude
        longitude = location.coordinate.longitude
        // No reverse geocoding — CLGeocoder deprecated in iOS 26.
        // The city name stays as "My Location" when using GPS.
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
