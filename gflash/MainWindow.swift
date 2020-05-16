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
    
    @IBOutlet weak var save_rom_button: NSButton!
    
    
    @IBOutlet weak var programmer_detect_text: NSTextField!
    @IBOutlet weak var programmer_green_dot: NSImageView!
    @IBOutlet weak var programmer_red_dot: NSImageView!
    @IBOutlet weak var programmer_orange_dot: NSImageView!
    @IBOutlet weak var programmer_progress_wheel: NSProgressIndicator!
    
    let userDesktopDirectory:String = NSHomeDirectory()
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.programmer_detect_text.stringValue = NSLocalizedString("No Device selected", comment: "")
    }
    
    @IBAction func list_usb_devices(_ sender: Any) {
        self.syncShellExec(path: self.scriptPath, args: ["_list_usb_devices"])
    }
    
    
    @IBAction func save_rom(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "Successful")
        let programmer_check = UserDefaults.standard.string(forKey: "Programmer")
        if programmer_check == "0" {
            programmer_not_choosed()
            return
        }
        save_rom(sender: "" as AnyObject)
        self.syncShellExec(path: self.scriptPath, args: ["_save_rom"])
        let success_check = UserDefaults.standard.bool(forKey: "Successful")
        if success_check == true {
            successful()
        } else {
            not_successful()
        }
        
    }
    
    
    @IBAction func programmer_chooser(_ sender: Any) {
        self.programmer_detect_text.stringValue = NSLocalizedString("Checking connected USB Devices", comment: "")
        self.programmer_progress_wheel.isHidden = false
        self.programmer_orange_dot.isHidden = true
        self.programmer_red_dot.isHidden = true
        self.programmer_green_dot.isHidden = true
        self.programmer_progress_wheel?.startAnimation(self);
        self.syncShellExec(path: self.scriptPath, args: ["_check_programmer"])
        let programmer_found = UserDefaults.standard.bool(forKey: "Programmer found")
        if programmer_found == true {
            self.programmer_orange_dot.isHidden = true
            self.programmer_red_dot.isHidden = true
            self.programmer_green_dot.isHidden = false
            self.programmer_detect_text.stringValue = NSLocalizedString("Device found", comment: "")
            self.save_rom_button.isEnabled = true
        } else {
            self.programmer_orange_dot.isHidden = true
            self.programmer_red_dot.isHidden = false
            self.programmer_green_dot.isHidden = true
            self.programmer_detect_text.stringValue = NSLocalizedString("Device not found", comment: "")
            self.save_rom_button.isEnabled = false
        }

        self.programmer_progress_wheel.isHidden = true
        self.programmer_progress_wheel?.stopAnimation(self);
        defaults.synchronize()
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

    
    func save_rom(sender: AnyObject) {
          let dialog = NSSavePanel();
          dialog.title                   = "Choose a Filepath (.bin)";
          dialog.nameFieldStringValue    = "ROM.bin";
          dialog.showsResizeIndicator    = true;
          dialog.showsHiddenFiles        = false;
          dialog.canCreateDirectories    = true;
          //dialog.allowedFileTypes        = ["bin"];
          
          if (dialog.runModal() == NSApplication.ModalResponse.OK) {
              let result = dialog.url // Pathname of the file
              
              if (result != nil) {
                  let path = result!.path
                  let rompath = (path as String)
                  UserDefaults.standard.set(rompath, forKey: "ROM Savepath")
              }
          } else {
              return
          }
      }
       
    func programmer_not_choosed (){
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("You did not have selected any Programmer!", comment: "")
        alert.informativeText = NSLocalizedString("Please choose one from the Pulldown Menu and try again.", comment: "")
        alert.alertStyle = .warning
        let Button = NSLocalizedString("Bummer", comment: "")
        alert.addButton(withTitle: Button)
        alert.runModal()
    }
    
    func successful (){
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Operation done!", comment: "")
        alert.informativeText = NSLocalizedString("No Problems detected.", comment: "")
        alert.alertStyle = .informational
        let Button = NSLocalizedString("Nice", comment: "")
        alert.addButton(withTitle: Button)
        alert.runModal()
    }
    
    func not_successful (){
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("An Error has occured!", comment: "")
        alert.informativeText = NSLocalizedString("Something went wrong. Please try again.", comment: "")
        alert.alertStyle = .warning
        let Button = NSLocalizedString("Bummer", comment: "")
        alert.addButton(withTitle: Button)
        alert.runModal()
    }
    
}
