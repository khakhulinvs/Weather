//
//  User.swift
//  Weather
//
//  Created by Viacheslav Khakhulin on 12.02.2024.
//

import Foundation
import SwiftData

@Model
class User {
    var latitude: Double
    var longitude: Double
    var cityName: String
    var isLocationMode: Bool
    
    var temperature: Float
    var summary: String
    @Attribute(.externalStorage) var iconPngData: Data?

    init(latitude: Double, longitude: Double, cityName: String, isLocationMode: Bool, temperature: Float, summary: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.cityName = cityName
        self.isLocationMode = isLocationMode
        self.temperature = temperature
        self.summary = summary
    }
}
