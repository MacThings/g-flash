//
//  AppDelegate.swift
//  gflash
//
//  Created by Prof. Dr. Luigi on 16.05.20.
//  Copyright © 2020 sl-soft.de. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let userDesktopDirectory:String = NSHomeDirectory()
    let defaults = UserDefaults.standard
    
    func applicationShouldTerminateAfterLastWindowClosed (_
        theApplication: NSApplication) -> Bool {
        return true
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let paths = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)
        let userDownloadDirectory = paths[0]
        
        let download_path_check = UserDefaults.standard.string(forKey: "Download Path")
        if download_path_check == nil{
            UserDefaults.standard.set(userDownloadDirectory, forKey: "Download Path")
        }
        
        LetsMoveIt().ToApps()
        
        check_theme()
        
        UserDefaults.standard.set("0", forKey: "Programmer")
        UserDefaults.standard.removeObject(forKey: "Programmer found")
        UserDefaults.standard.removeObject(forKey: "Successful")
        UserDefaults.standard.removeObject(forKey: "Chip Type")
        UserDefaults.standard.removeObject(forKey: "Chip Types")
        UserDefaults.standard.removeObject(forKey: "Abort")
        UserDefaults.standard.set(false, forKey: "Force Chip Type")
        UserDefaults.standard.removeObject(forKey: "Model")
        defaults.synchronize()
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        UserDefaults.standard.removeObject(forKey: "Successful")
        UserDefaults.standard.removeObject(forKey: "Chip Type")
        UserDefaults.standard.removeObject(forKey: "Chip Types")
        UserDefaults.standard.removeObject(forKey: "Programmer found")
        defaults.synchronize()
        
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



