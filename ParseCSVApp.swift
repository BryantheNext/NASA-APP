//
//  ParseCSVApp.swift
//  ParseCSV
//
//  Created by Allen Norskog on 10/30/23.
//

import SwiftUI

@main
struct ParseCSVApp: App {
    /*
    
    // GlobalStates() is an ObservableObject class
    var globalStates = GlobalStates()
    
    // Device Orientation
    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()
    */
    var body: some Scene {
        WindowGroup {
            //ContentView()
            MoonApp()
            //Space()
                /*
                .environmentObject(globalStates)
                .onReceive(orientationChanged) { _ in
                    // Set the state for current device rotation
                    if UIDevice.current.orientation.isFlat {
                        // ignore orientation change
                    } else {
                        globalStates.isLandscape = UIDevice.current.orientation.isLandscape
                    }*/
            
                }
        }
    }
