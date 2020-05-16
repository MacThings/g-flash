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
    let defaults = UserDefaults.standard
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        PFMoveToApplicationsFolderIfNecessary()
        check_theme()
        UserDefaults.standard.set("0", forKey: "Programmer")
        UserDefaults.standard.removeObject(forKey: "Programmer found")
        
        //let force_chip_type = UserDefaults.standard.string(forKey: "Force Chip Type")
        //if force_chip_type == nil{
            UserDefaults.standard.set(false, forKey: "Force Chip Type")
        //}
        defaults.synchronize()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        UserDefaults.standard.removeObject(forKey: "Successful")
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
        defaults.synchronize()
    }
    
}


