//
//  Preferences.swift
//  G-Flash
//
//  Created by Prof. Dr. Luigi on 17.05.20.
//  Copyright © 2020 Sascha Lamprecht. All rights reserved.
//

import Foundation
import Cocoa

class Preferences: NSViewController {

    @IBOutlet weak var selected_download_path: NSTextField!
    
    override func viewDidLoad() {
           super.viewDidLoad()
        
        //let download_path = UserDefaults.standard.string(forKey: "Download Path")
        //selected_download_path.stringValue = download_path!
       }
    
    @IBAction func browseFile(sender: AnyObject) {
           
           let dialog = NSOpenPanel();
           
           dialog.title                   = NSLocalizedString("Please choose a destination Folder", comment: "");
           dialog.showsResizeIndicator    = true;
           dialog.showsHiddenFiles        = false;
           dialog.canChooseDirectories    = true;
           dialog.canCreateDirectories    = true;
           dialog.allowsMultipleSelection = false;
           //dialog.allowedFileTypes        = ["txt"];
           
           if (dialog.runModal() == NSApplication.ModalResponse.OK) {
               let result = dialog.url // Pathname of the file
               
               if (result != nil) {
                   let path = result!.path
                   selected_download_path.stringValue = path
                   let dlpath = (path as String)
                   UserDefaults.standard.set(dlpath, forKey: "Download Path")
               }
           } else {
               // User clicked on "Cancel"
               return
           }
       }
    
    @objc func cancel(_ sender: Any?) {
        self.view.window?.close()
    }
    
}
