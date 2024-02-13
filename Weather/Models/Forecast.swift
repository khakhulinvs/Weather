//
//  Forecast.swift
//  Weather
//
//  Created by Viacheslav Khakhulin on 13.02.2024.
//

import Foundation
import SwiftData

@Model
class Forecast {
    var date: Date
    var temperature: Float
    var summary: String
    
    init(date: Date, temperature: Float, summary: String) {
        self.date = date
        self.temperature = temperature
        self.summary = summary
    }
}
