//
//  MainView.swift
//  Weather
//
//  Created by Viacheslav Khakhulin on 12.02.2024.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @FocusState var cityNameFocused
    @State var viewModel = MainViewModel()

    var body: some View {
        VStack() {
            switch viewModel.state {
            case .locationUnavailable:
                Text("[LocationServiceUnavailable]")
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .padding(16)
                Text("[LocationServiceUnavailableDescription]")
                    .multilineTextAlignment(.center)
                    .padding(16)
                Button {
                    viewModel.openSettings()
                } label: {
                    Text("[OpenSettings]")
                    Image(systemName: "gear")
                        .tint(Color.pink)
                }
                .padding(16)
                Button {
                    viewModel.request()
                } label: {
                    Text("[Refresh]")
                    Image(systemName: "arrow.circlepath")
                        .tint(Color.pink)
                }
            case .ready, .requesting:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            case .requestSucceed:
                if let iconImage = viewModel.iconImage {
                    Image(uiImage: iconImage)
                }
                Group {
                    Text("[Location:]")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    HStack {
                        Button(action: {
                            viewModel.user.isLocationMode = true
                            viewModel.request()
                        }
                               , label: {
                            Image(systemName: "location")
                                .tint(Color.pink)
                        })
                        TextField("[CityName]",
                                  text: $viewModel.user.cityName)
                        .focused($cityNameFocused)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .onSubmit {
                            cityNameFocused = false
                            viewModel.user.isLocationMode = false
                            viewModel.request()
                        }
                        Button(action: {
                            cityNameFocused = true
                        }
                               , label: {
                            Image(systemName: "pencil")
                                .tint(Color.pink)
                        })
                    }
                }
                .padding(16)
                Group {
                    Text("[Temperature:]")
                        .font(.title)
                    Text(String(format: "%.2f℃", viewModel.user.temperature))
                        .font(.title2)
                }
                .padding(16)
                Group {
                    Text("[Summary:]")
                        .font(.title)
                    Text(viewModel.user.summary)
                        .font(.title2)
                }
                .padding(16)
                Spacer()
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
    MainView()
}
