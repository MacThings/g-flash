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

    @IBAction func test(_ sender: Any) {
        self.syncShellExec(path: self.scriptPath, args: ["_loaded"])
    }
    
    
    func syncShellExec(path: String, args: [String] = []) {
        let theme_check = UserDefaults.standard.string(forKey: "System Theme")
        if theme_check == "Dark" {
            output_window.textColor = NSColor.white
        } else {
            output_window.textColor = NSColor.black
        }
        
        let fontsize = CGFloat(15)
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

        
}
