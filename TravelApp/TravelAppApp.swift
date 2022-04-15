//
//  TravelAppApp.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 26.3.2022.
//

import SwiftUI

@main
struct TravelAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
