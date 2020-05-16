//
//  AppDelegate.swift
//  gflash
//
//  Created by Prof. Dr. Luigi on 16.05.20.
//  Copyright © 2020 sl-soft.de. All rights reserved.
//

import Cocoa
import LetsMove

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        PFMoveToApplicationsFolderIfNecessary()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

