//
//  ForecastView.swift
//  Weather
//
//  Created by Viacheslav Khakhulin on 12.02.2024.
//

import SwiftUI

struct ForecastView: View {
    @State var viewModel = ForecastViewModel()
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .ready, .requesting:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            case .requestSucceed:
                List {
                    ForEach(viewModel.forecasts) { forecast in
                        HStack {
                            Text(forecast.date.formatted())
                            Spacer()
                            Text(String(format: "%.2f℃", forecast.temperature))
                            Text(forecast.summary)
                        }
                    }
                }
            case .requestFailed:
                Text("[RequestFailed]")
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .padding(16)
                Text(viewModel.error?.localizedDescription ?? "")
                    .multilineTextAlignment(.center)
                    .padding(16)
                Button {
                    viewModel.request()
                } label: {
                    Text("[RequestAgain]")
                    Image(systemName: "arrow.circlepath")
                        .tint(Color.pink)
                }
                .padding(16)
                Button {
                    viewModel.state = .requestSucceed
                } label: {
                    Text("[GoOffline]")
                    Image(systemName: "lightswitch.off")
                        .tint(Color.pink)
                }
            }
        }
        .onAppear {
            viewModel.request()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { (_) in
            viewModel.request()
        }
    }
}

#Preview {
    ForecastView()
}
