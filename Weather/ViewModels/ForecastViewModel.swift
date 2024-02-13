//
//  ForecastViewModel.swift
//  Weather
//
//  Created by Viacheslav Khakhulin on 12.02.2024.
//

import Foundation

@Observable
class ForecastViewModel {
    
    enum State {
        case ready
        case requesting
        case requestSucceed
        case requestFailed
    }
    var state: State

    var user: User
    var forecasts: [Forecast]
    var error: Error?
        
    init() {
        user = try! ModelDataSource.shared.fetchOrCreateUser()
        forecasts = try! ModelDataSource.shared.fetchForecasts()
        state = .ready
    }
    
    private func processRequest(result: Result<ForecastResponse, Error> ) {
        switch result {
        case .success(let forecast):
            debugPrint("\(forecast)")
            
            try! ModelDataSource.shared.delete(forecasts: self.forecasts)
            
            guard let list = forecast.list else {
                self.forecasts = []
                state = .requestSucceed
                return
            }
            
            self.forecasts = list.map { listItem in
                let date = Date(timeIntervalSince1970: TimeInterval(listItem.dt))
                let temperature = listItem.main?.temp ?? 0
                let summary = listItem.weather?.first?.main ?? ""
                return Forecast(date: date, temperature: temperature, summary: summary)
            }
            
            try! ModelDataSource.shared.insert(forecasts: self.forecasts)
            
            state = .requestSucceed
        case .failure(let error):
            debugPrint("\(error)")
            self.error = error
            state = .requestFailed
        }
    }
    
    func request() {
        if state == .requesting {
            return
        }
        state = .requesting
        
        if user.isLocationMode {
            WeatherService.shared.requestForecast(latitude: user.latitude,
                                                  longitude: user.longitude) { result in
                self.processRequest(result: result)
            }
        } else {
            WeatherService.shared.requestForecast(cityName: user.cityName) { result in
                self.processRequest(result: result)
            }
        }
    }
}
