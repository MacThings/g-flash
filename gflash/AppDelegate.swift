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

    let userDesktopDirectory:String = NSHomeDirectory()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        PFMoveToApplicationsFolderIfNecessary()
        check_theme()
        UserDefaults.standard.set("0", forKey: "Programmer")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func check_theme() -> Void {
    let path = self.userDesktopDirectory + "/Library/Preferences/.GlobalPreferences.plist"
    let dictRoot = NSDictionary(contentsOfFile: path)
    if let dict = dictRoot{
        if (dict["AppleInterfaceStyle"] as? String) != nil {
            UserDefaults.standard.set("Dark", forKey: "System Theme")
        } else {
            UserDefaults.standard.set("Light", forKey: "System Theme")
        }
    }
        let defaults = UserDefaults.standard
        defaults.synchronize()
    }
    
}


