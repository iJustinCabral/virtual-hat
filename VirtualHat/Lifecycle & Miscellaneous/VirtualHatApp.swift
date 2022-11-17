//
//  VirtualHatApp.swift
//  VirtualHat
//
//  Created by Justin Cabral on 7/19/20.
//

import SwiftUI
import CoreData

@main
struct VirtualHatApp: App {
    
    let context = PersistentContainer.persistentContainer.viewContext
    
    var body: some Scene {
        return WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, context)
        }
    }
}
