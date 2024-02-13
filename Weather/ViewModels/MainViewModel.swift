//
//  MainViewModel.swift
//  Weather
//
//  Created by Viacheslav Khakhulin on 12.02.2024.
//

import SwiftUI
import SwiftData

@Observable
class MainViewModel {
    @ObservationIgnored
    static let defaultCityName = "Unknown"
    @ObservationIgnored
    static let defaultTemperature: Float = 0
    @ObservationIgnored
    static let defaultSummary = "Empty"
    
    enum State {
        case locationUnavailable
        case ready
        case requesting
        case requestSucceed
        case requestFailed
    }
    var state: State
    
    var user: User
    
    var iconImage: UIImage?
    var error: Error?
    
    private func composeSummary(response: WeatherResponse) -> String {
        var summary = ""
        
        if let temp = response.main?.temp {
            if temp < 0 {
                summary += "- temperature is less than 0"
            } else if 0 <= temp, temp <= 15 {
                summary += "- temperature is from 0 to 15"
            } else {
                summary += "- temperature is more than 15"
            }
            summary += "\n"
        }
        
        if let description = response.weather.first?.description {
            summary += "- \(description)"
        }
        
        if summary.isEmpty {
            summary = MainViewModel.defaultSummary
        }
        
        return summary
    }
    
    private func updateIconImage() {
        guard let iconPngData = self.user.iconPngData else {
            iconImage = nil
            return
        }
        
        iconImage = UIImage(data: iconPngData)
    }
    
    private func processRequest(result: Result<WeatherResponse, Error>) {
        switch result {
        case .success(let response):
            self.user.cityName = response.name ?? MainViewModel.defaultCityName
            self.user.temperature = response.main?.temp ?? MainViewModel.defaultTemperature
            self.user.summary = composeSummary(response: response)
            
            if let icon = response.weather.first?.icon {
                WeatherService.shared.iconPngData(code: icon) { data in
                    self.user.iconPngData = data
                    self.updateIconImage()
                }
            } else {
                self.user.iconPngData = nil
                self.updateIconImage()
            }
                        
            self.state = .requestSucceed
        case .failure(let error):
            self.state = .requestFailed
            self.error = error
        }
    }
    
    init() {
        state = LocationService.shared.isAvailable() ? .ready : .locationUnavailable
        user = try! ModelDataSource.shared.fetchOrCreateUser()
        updateIconImage()
    }
    
    private func requestLocation() {
        guard LocationService.shared.isAvailable() else {
            state = .locationUnavailable
            LocationService.shared.requestWhenInUseAuthorizationIfNotDetermined()
            return
        }
        
        state = .requesting
        LocationService.shared.request { latitude, longitude in
            self.user.latitude = latitude
            self.user.longitude = longitude
            
            WeatherService.shared.requestWeather(latitude: latitude, longitude: longitude) { result in
                self.processRequest(result: result)
            }
        } didFail: { error in
            self.state = LocationService.shared.isAvailable() ? .requestFailed : .locationUnavailable
            debugPrint("\(error)")
        }
    }
    
    private func requestCity() {
        state = .requesting
        WeatherService.shared.requestWeather(cityName: user.cityName) { result in
            self.processRequest(result: result)
        }
    }
    
    func request() {
        if state == .requesting {
            return
        }
        
        if user.isLocationMode {
            requestLocation()
        } else {
            requestCity()
        }
    }
    
    func openSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)                    
    }
}
