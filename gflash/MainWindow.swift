//
//  MainWindow.swift
//  G-Flash
//
//  Created by Sascha Lamprecht on 16.05.20.
//  Copyright © 2020 sl-soft.de. All rights reserved.
//

import Foundation
import LetsMove

class MainWindow: NSViewController {

    @IBOutlet var output_window: NSTextView!
    @IBOutlet weak var content_scroller: NSScrollView!
    
    let userDesktopDirectory:String = NSHomeDirectory()
 
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!

    @IBAction func list_usb_devices(_ sender: Any) {
        self.syncShellExec(path: self.scriptPath, args: ["_list_usb_devices"])
    }
    
    @IBAction func read_rom(_ sender: Any) {
        self.syncShellExec(path: self.scriptPath, args: ["_read_rom"])
    }
    
    func syncShellExec(path: String, args: [String] = []) {
        let theme_check = UserDefaults.standard.string(forKey: "System Theme")
        if theme_check == "Dark" {
            output_window.textColor = NSColor.white
        } else {
            output_window.textColor = NSColor.black
        }
        
        let fontsize = CGFloat(14)
        let fontfamily = "Menlo"
        output_window.font = NSFont(name: fontfamily, size: fontsize)
        
        output_window.textStorage?.mutableString.setString("")

        let process            = Process()
        process.launchPath     = "/bin/bash"
        process.arguments      = [path] + args
        let outputPipe         = Pipe()
        let filelHandler       = outputPipe.fileHandleForReading
        process.standardOutput = outputPipe
        
        let group = DispatchGroup()
        group.enter()
        filelHandler.readabilityHandler = { pipe in
            let data = pipe.availableData
            if data.isEmpty { // EOF
                filelHandler.readabilityHandler = nil
                group.leave()
                return
            }
            if let line = String(data: data, encoding: String.Encoding.utf8) {
                DispatchQueue.main.sync {
                    self.output_window.string += line
                    self.output_window.scrollToEndOfDocument(nil)
                }
            } else {
                print("Error decoding data: \(data.base64EncodedString())")
            }
        }
        process.launch() // Start process
        process.waitUntilExit() // Wait for process to terminate.
    }

    @IBAction func browseFile(sender: AnyObject) {
          
          let dialog = NSOpenPanel();
          
          dialog.title                   = "Choose a Folder";
          dialog.showsResizeIndicator    = true;
          dialog.showsHiddenFiles        = false;
          dialog.canChooseDirectories    = true;
          dialog.canCreateDirectories    = true;
          dialog.allowsMultipleSelection = false;
          dialog.allowedFileTypes        = ["iso"];
          
          if (dialog.runModal() == NSApplication.ModalResponse.OK) {
              let result = dialog.url // Pathname of the file
              
              if (result != nil) {
                  let path = result!.path
                  let isopath = (path as String)
                  UserDefaults.standard.set(isopath, forKey: "Isopath")
                  self.syncShellExec(path: self.scriptPath, args: ["_get_isoname"])
              }
          } else {
              return
          }
    
      }
        
}
