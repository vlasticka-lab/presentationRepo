//
//  ListView.swift
//  discoverMendelu
//
//  Created by Macek<3 on 29.05.2025.
//

import SwiftUI

struct ListView: View {
    @State private var viewModel: LocationInfoViewModel
    @State private var isNewPlaceViewPresented = false
    
    // Set of location IDs currently animating unlock
    @State private var animatedUnlockLocations = Set<UUID>()

    
    init(viewModel: LocationInfoViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.state.locations) { location in
                    if location.locked {
                        HStack {
                            Text(location.name)
                            Spacer()
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                        }
                    } else if animatedUnlockLocations.contains(location.id) {
                        UnlockingRowView(location: location) {
                            viewModel.markLocationAnimated(id: location.id)
                            animatedUnlockLocations.remove(location.id)
                        }
                    } else {
                        NavigationLink(
                            destination: DetailView(viewModel: DetailViewModel(location: location))
                        ) {
                            Text(location.name)
                        }
                    }
                }
            }
            .navigationTitle("Locations")
            .onAppear {
                viewModel.loadDataIfNeeded()
                viewModel.fetchLocations()
                
                // Start unlock animation
                animatedUnlockLocations = Set(
                    viewModel.state.locations
                        .filter { !$0.locked && !$0.hasAnimated }
                        .map { $0.id }
                )
                
                viewModel.checkIfShouldShowStartupAlert()
            }
        }
        .overlay(
            Group {
                if viewModel.showStartupAlert {
                    CustomAlertView(
                        title: "Welcome, \(viewModel.currentLevel)!",
                        description: "Let’s start exploring Mendelu 💚",
                        buttonTitle: "Let’s go!",
                        onDismiss: {
                            viewModel.showStartupAlert = false
                            viewModel.saveStartupAlertDate()
                        }
                    )
                }
            }
        )
    }
}
