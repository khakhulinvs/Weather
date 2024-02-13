//
//  ContentView.swift
//  Weather
//
//  Created by Viacheslav Khakhulin on 12.02.2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                MainView()
                    .tabItem {
                        Label("[Main]",
                              systemImage: "sun.max.fill")
                    }
                Spacer()
                    .tabItem {
                        EmptyView()
                    }
                ForecastView()
                    .tabItem {
                        Label("[Forecast]",
                              systemImage: "chart.line.uptrend.xyaxis")
                    }
            }
            .tint(.pink)
            Button {
            } label: {
                Image(systemName: "plus")
                    .tint(Color.white)
            }
            .frame(width: 64, height: 64)
            .background(.pink)
            .clipShape(Circle())
        }
        
    }
}

#Preview {
    ContentView()
}
