//
//  ModelDataSource.swift
//  Weather
//
//  Created by Viacheslav Khakhulin on 12.02.2024.
//

import SwiftData

final class ModelDataSource {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    @MainActor
    static let shared = ModelDataSource()
    
    @MainActor
    private init() {
        self.modelContainer = try! ModelContainer(for: User.self, Forecast.self)
        self.modelContext = modelContainer.mainContext
    }
    
    func fetchOrCreateUser() throws -> User {
        guard let user = try modelContext.fetch(FetchDescriptor<User>()).first else {
            let user = User(latitude: 0, longitude: 0, cityName: "", isLocationMode: true, temperature: 0, summary: "")
            modelContext.insert(user)
            try modelContext.save()
            return user
        }
        return user
    }
    
    func fetchForecasts() throws -> [Forecast] {
        return try modelContext.fetch(FetchDescriptor<Forecast>())
    }
    
    func insert(forecasts: [Forecast]) throws {
        forecasts.forEach{
            modelContext.insert($0)
        }
        try modelContext.save()
    }
    
    func delete(forecasts: [Forecast]) throws {
        forecasts.forEach{
            modelContext.delete($0)
        }
    }
}
