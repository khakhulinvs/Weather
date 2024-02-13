//
//  WeatherService.swift
//  Weather
//
//  Created by Viacheslav Khakhulin on 12.02.2024.
//

import Foundation
//import Alamofire

// MARK: - Forecast Response

struct ForecastResponseListItemWeather: Decodable {
    var main: String?
    var description: String?
}

struct ForecastResponseListItemMain: Decodable {
    var temp: Float?
    var tempMin: Float?
    var tempMax: Float?
    
    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

struct ForecastResponseListItem: Decodable {
    var dt: Int
    var main: ForecastResponseListItemMain?
    var weather: [ForecastResponseListItemWeather]?
}

struct ForecastResponse: Decodable {
    var list: [ForecastResponseListItem]?
}

// MARK: - Weather Response

struct WeatherResponseWeather: Decodable {
    var main: String?
    var description: String?
    var icon: String?
}

struct WeatherResponseMain: Decodable {
    var temp: Float?
    var tempMin: Float?
    var tempMax: Float?
    
    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

struct WeatherResponse: Decodable {
    var weather: [WeatherResponseWeather]
    var main: WeatherResponseMain?
    var name: String?
}

// MARK: - Service

enum WeatherServiceError: Error {
    case urlFromStringFailed
    case addingPercentEncodingFailed
    case responseDataIsNil
}

struct WeatherService {
    static let shared = WeatherService()
    
    private let apiKey = "575070e6eed6d2e599bf2b46a711eba1"
    private let baseUrl = "https://api.openweathermap.org/data/2.5/"
    private let weather = "weather?"
    private let forecastDaily = "forecast?"
    private let units = "metric"
    private let unit = "C"
    
    // MARK: - Icon
    
    func iconPngData(code: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: "https://openweathermap.org/img/wn/\(code)@2x.png") else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, _ in
            DispatchQueue.main.async {
                completion(data)
            }
        }.resume()
    }
    
    // MARK: - Weather
    
    private func requestWeather(url: String, completion: @escaping (Result<WeatherResponse, Error>)->Void) {
        guard let url = URL(string: url) else {
            completion(.failure(WeatherServiceError.urlFromStringFailed))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(.failure(WeatherServiceError.responseDataIsNil))
                return
            }
            
            do {
                let weather = try JSONDecoder().decode(WeatherResponse.self, from: data)
                debugPrint("[WeatherService] Weather response \(weather)")
                completion(.success(weather))
            } catch let error {
                debugPrint("[WeatherService] Weather error \(error)")
                completion(.failure(error))
            }
        }.resume()

        // Alamofire way
//        AF.request(url).responseDecodable(of: WeatherResponse.self) { response in
//            switch response.result {
//            case .success(let weather):
//                debugPrint("[WeatherService] Weather response \(weather)")
//                completion(.success(weather))
//            case .failure(let error):
//                debugPrint("[WeatherService] Weather error \(error)")
//                completion(.failure(error))
//            }
//        }
    }
    
    func requestWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherResponse, Error>)->Void) {
        let url = "\(baseUrl)\(weather)lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=\(units)"
        debugPrint("[WeatherService] requesting url: \(url)")

        requestWeather(url: url, completion: completion)
    }
    
    func requestWeather(cityName: String, completion: @escaping (Result<WeatherResponse, Error>)->Void) {
        guard let cityName = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(WeatherServiceError.addingPercentEncodingFailed))
            return
        }
        
        let url = "\(baseUrl)\(weather)q=\(cityName)&appid=\(apiKey)&units=\(units)"
        debugPrint("[WeatherService] requesting url: \(url)")
        
        requestWeather(url: url, completion: completion)
    }

    // MARK: - Forecast
    
    private func requestForecast(url: String, completion: @escaping (Result<ForecastResponse, Error>)->Void) {
        guard let url = URL(string: url) else {
            completion(.failure(WeatherServiceError.urlFromStringFailed))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(.failure(WeatherServiceError.responseDataIsNil))
                return
            }
            
            do {
                let forecast = try JSONDecoder().decode(ForecastResponse.self, from: data)
                debugPrint("[WeatherService] Forecast response \(forecast)")
                completion(.success(forecast))
            } catch let error {
                debugPrint("[WeatherService] Forecast error \(error)")
                completion(.failure(error))
            }
        }.resume()

        // Alamofire way
//        AF.request(url).responseDecodable(of: ForecastResponse.self) { response in
//            switch response.result {
//            case .success(let weather):
//                debugPrint("[WeatherService] Forecast response \(weather)")
//                completion(.success(weather))
//            case .failure(let error):
//                debugPrint("[WeatherService] Forecast error \(error)")
//                completion(.failure(error))
//            }
//        }
    }

    func requestForecast(latitude: Double, longitude: Double, completion: @escaping (Result<ForecastResponse, Error>)->Void) {
        let url = "\(baseUrl)\(forecastDaily)lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=\(units)"
        debugPrint("[WeatherService] requesting url: \(url)")

        requestForecast(url: url, completion: completion)
    }

    func requestForecast(cityName: String, completion: @escaping (Result<ForecastResponse, Error>)->Void) {
        guard let cityName = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(WeatherServiceError.addingPercentEncodingFailed))
            return
        }
        
        let url = "\(baseUrl)\(forecastDaily)q=\(cityName)&appid=\(apiKey)&units=\(units)"
        debugPrint("[WeatherService] requesting url: \(url)")
        
        requestForecast(url: url, completion: completion)
    }
}
