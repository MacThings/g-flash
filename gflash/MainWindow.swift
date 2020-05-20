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
    @IBOutlet weak var write_rom_button: NSButton!
    @IBOutlet weak var get_chip_type_button: NSButton!
    @IBOutlet weak var erase_eeprom_button: NSButton!
    @IBOutlet weak var list_usb_devices_button: NSButton!
    @IBOutlet weak var bios_modding_button: NSButton!
    @IBOutlet weak var preferences_button: NSButton!
    
    
    
    @IBOutlet weak var read_rom_progressbar: NSProgressIndicator!
    @IBOutlet weak var flash_rom_progressbar: NSProgressIndicator!
    @IBOutlet weak var erase_eeprom_progressbar: NSProgressIndicator!
    @IBOutlet weak var list_usb_progressbar: NSProgressIndicator!
    
    @IBOutlet weak var get_chip_type_text: NSTextField!
    @IBOutlet weak var get_chip_type_progressbar: NSProgressIndicator!
    
    @IBOutlet weak var bios_modding_progressbar: NSProgressIndicator!
    
    @IBOutlet weak var devices_pulldown: NSPopUpButton!
    @IBOutlet weak var devices_empty_entry: NSMenuItem!
    
    @IBOutlet weak var programmer_detect_text: NSTextField!
    @IBOutlet weak var programmer_green_dot: NSImageView!
    @IBOutlet weak var programmer_red_dot: NSImageView!
    @IBOutlet weak var programmer_orange_dot: NSImageView!
    @IBOutlet weak var programmer_progress_wheel: NSProgressIndicator!
    
    let userDesktopDirectory:String = NSHomeDirectory()
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    let defaults = UserDefaults.standard
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    

    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "G-Flash v" + appVersion!

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.programmer_detect_text.stringValue = NSLocalizedString("No Device selected", comment: "")

        if #available(OSX 10.14, *) {
            output_window.textColor = (NSApp.effectiveAppearance.name == NSAppearance.Name.darkAqua ? NSColor.white : NSColor.black)
        }
        let fontsize = CGFloat(15)
        let fontfamily = "Menlo"
        output_window.font = NSFont(name: fontfamily, size: fontsize)
        
        output_window.textStorage?.mutableString.setString("")
        
        NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.download_wine),
        name: NSNotification.Name(rawValue: "download_wine"),
        object: nil)
        
        NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.download_crossover),
        name: NSNotification.Name(rawValue: "download_crossover"),
        object: nil)
        
        NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.download_phoenixtool),
        name: NSNotification.Name(rawValue: "download_phoenixtool"),
        object: nil)
        
        NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.download_mods),
        name: NSNotification.Name(rawValue: "download_mods"),
        object: nil)
    }
    
    
    @IBAction func list_usb_devices(_ sender: Any) {
        clear_window()
        self.list_usb_progressbar.isHidden=false
        self.list_usb_progressbar?.startAnimation(self);
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["_list_usb_devices"])
            DispatchQueue.main.async {
                self.list_usb_progressbar.isHidden=true
                self.list_usb_progressbar?.stopAnimation(self);
            }
        }
    }
    
    
    @IBAction func detect_devices(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "Programmer found")
        UserDefaults.standard.removeObject(forKey: "Chip Type")
        self.write_rom_button.isEnabled = false
        self.save_rom_button.isEnabled = false
        self.erase_eeprom_button.isEnabled = false
        self.get_chip_type_text.isEditable = false
        self.get_chip_type_button.isEnabled = false
        self.programmer_detect_text.stringValue = NSLocalizedString("Searching for Device", comment: "")
        self.programmer_orange_dot.isHidden=true
        self.programmer_green_dot.isHidden=true
        self.programmer_red_dot.isHidden=true
        self.programmer_progress_wheel.isHidden=false
        self.programmer_progress_wheel?.startAnimation(self);
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["_detect_programmer"])
                DispatchQueue.main.async {
                    self.programmer_chooser("")
            }
        }
    }
    
    
    @IBAction func get_chip_type(_ sender: Any) {
        clear_window()
        UserDefaults.standard.removeObject(forKey: "Chip Type")
        self.get_chip_type_progressbar.isHidden=false
        self.get_chip_type_progressbar?.startAnimation(self);
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["_get_chip_type"])
            DispatchQueue.main.async {
                let chiptypes_check = UserDefaults.standard.string(forKey: "Chip Types")
                if chiptypes_check == "0" {
                    self.no_chip_found()
                    self.get_chip_type_progressbar.isHidden=true
                    self.get_chip_type_progressbar?.stopAnimation(self);
                    return
                } else if chiptypes_check != "1" {
                    self.multiple_types()
                }
                let force_check = UserDefaults.standard.bool(forKey: "Force Chip Type")
                if force_check == false {
                    self.write_rom_button.isEnabled = true
                    self.save_rom_button.isEnabled = true
                    self.erase_eeprom_button.isEnabled = true
                } else {
                    self.write_rom_button.isEnabled = false
                    self.save_rom_button.isEnabled = false
                    self.erase_eeprom_button.isEnabled = false
                }
                self.get_chip_type_progressbar.isHidden=true
                self.get_chip_type_progressbar?.stopAnimation(self);
            }
        }
    }
    
    
    @IBAction func input_detection(_ sender: Any) {
        self.write_rom_button.isEnabled = true
        self.save_rom_button.isEnabled = true
        self.erase_eeprom_button.isEnabled = true
    }
    
    
    @IBAction func save_rom(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "Successful")
        let programmer_check = UserDefaults.standard.string(forKey: "Programmer")
        if programmer_check == "0" {
            programmer_not_choosed()
            return
        }
        clear_window()
        save_rom(sender: "" as AnyObject)
        let abort_check = UserDefaults.standard.bool(forKey: "Abort")
        if abort_check == false {
            self.read_rom_progressbar.isHidden=false
            self.read_rom_progressbar?.startAnimation(self);
            DispatchQueue.global(qos: .background).async {
                self.syncShellExec(path: self.scriptPath, args: ["_save_rom"])
                DispatchQueue.main.async {
                    self.read_rom_progressbar.isHidden=true
                    self.read_rom_progressbar?.stopAnimation(self);
                    let chip_type_mismatch = UserDefaults.standard.bool(forKey: "Chip Type Mismatch")
                    let success_check = UserDefaults.standard.bool(forKey: "Successful")
                    if success_check == true {
                        self.successful()
                    } else {
                        if chip_type_mismatch == true {
                            self.wrong_type_entered()
                        } else {
                            self.not_successful()
                        }
                    }
                    
                    
                }
            }
            
        }
        else {
            return
        }
        UserDefaults.standard.removeObject(forKey: "Abort")
    }

    
    @IBAction func write_rom(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "Successful")
        let programmer_check = UserDefaults.standard.string(forKey: "Programmer")
        if programmer_check == "0" {
            programmer_not_choosed()
            return
        }
        clear_window()
        write_rom(sender: "" as AnyObject)
        let abort_check = UserDefaults.standard.bool(forKey: "Abort")
        if abort_check == false {
        self.flash_rom_progressbar.isHidden=false
        self.flash_rom_progressbar?.startAnimation(self);
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["_write_rom"])
            DispatchQueue.main.async {
                self.flash_rom_progressbar.isHidden=true
                self.flash_rom_progressbar?.stopAnimation(self);
                let chip_type_mismatch = UserDefaults.standard.bool(forKey: "Chip Type Mismatch")
                let success_check = UserDefaults.standard.bool(forKey: "Successful")
                if success_check == true {
                    self.successful()
                } else {
                    if chip_type_mismatch == true {
                        self.wrong_type_entered()
                    } else {
                        self.not_successful()
                    }
                }
            }
        }
        }
        UserDefaults.standard.removeObject(forKey: "Abort")
        
        
    }
    
    
    @IBAction func erase_eeprom(_ sender: Any) {
        erase_confirmation()
        UserDefaults.standard.removeObject(forKey: "Successful")
        let programmer_check = UserDefaults.standard.string(forKey: "Programmer")
        if programmer_check == "0" {
            programmer_not_choosed()
            return
        }
        let abort_check = UserDefaults.standard.bool(forKey: "Abort")
        if abort_check == false {
            clear_window()
            self.erase_eeprom_progressbar.isHidden=false
            self.erase_eeprom_progressbar?.startAnimation(self);
            DispatchQueue.global(qos: .background).async {
                self.syncShellExec(path: self.scriptPath, args: ["_erase_eeprom"])
                DispatchQueue.main.async {
                    self.erase_eeprom_progressbar.isHidden=true
                    self.erase_eeprom_progressbar?.stopAnimation(self);
                    let chip_type_mismatch = UserDefaults.standard.bool(forKey: "Chip Type Mismatch")
                    let success_check = UserDefaults.standard.bool(forKey: "Successful")
                    if success_check == true {
                        self.successful()
                    } else {
                        if chip_type_mismatch == true {
                            self.wrong_type_entered()
                        } else {
                            self.not_successful()
                        }
                    }
                }
            }
        }
        UserDefaults.standard.removeObject(forKey: "Abort")
    }
    
    
    @IBAction func programmer_chooser(_ sender: Any) {
        self.get_chip_type_button.isEnabled = false
        UserDefaults.standard.removeObject(forKey: "Programmer found")
        UserDefaults.standard.removeObject(forKey: "Chip Type")
        //UserDefaults.standard.removeObject(forKey: "Programmer")
        self.write_rom_button.isEnabled = false
        self.save_rom_button.isEnabled = false
        self.erase_eeprom_button.isEnabled = false
        self.get_chip_type_text.isEditable = false
        clear_window()
        self.devices_empty_entry.isHidden=true
        UserDefaults.standard.removeObject(forKey: "Chip Type Mismatch")
        UserDefaults.standard.removeObject(forKey: "Force Chip Type")
        self.programmer_detect_text.stringValue = NSLocalizedString("Checking connected USB Device", comment: "")
        self.programmer_progress_wheel.isHidden = false
        self.programmer_orange_dot.isHidden = true
        self.programmer_red_dot.isHidden = true
        self.programmer_green_dot.isHidden = true
        self.programmer_progress_wheel?.startAnimation(self);
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["_check_programmer"])
            DispatchQueue.main.async {
                let programmer_found = UserDefaults.standard.bool(forKey: "Programmer found")
                if programmer_found == true {
                    self.programmer_orange_dot.isHidden = true
                    self.programmer_red_dot.isHidden = true
                    self.programmer_green_dot.isHidden = false
                    self.programmer_detect_text.stringValue = NSLocalizedString("Device ready", comment: "")
                    self.get_chip_type_button.isEnabled = true
                } else {
                    self.programmer_orange_dot.isHidden = true
                    self.programmer_red_dot.isHidden = false
                    self.programmer_green_dot.isHidden = true
                    self.programmer_detect_text.stringValue = NSLocalizedString("Device not found", comment: "")
                    self.save_rom_button.isEnabled = false
                    self.write_rom_button.isEnabled = false
                    self.get_chip_type_button.isEnabled = false
                    self.erase_eeprom_button.isEnabled = false
                }
                self.programmer_progress_wheel.isHidden = true
                self.programmer_progress_wheel?.stopAnimation(self);
                self.defaults.synchronize()
            }
        }
    }
    
  
    func save_rom(sender: AnyObject) {
          let dialog                     = NSSavePanel();
          dialog.title                   = NSLocalizedString("Choose a Filepath", comment: "");
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
                  UserDefaults.standard.set(false, forKey: "Abort")
                  defaults.synchronize()
              }
          } else {
              UserDefaults.standard.set(true, forKey: "Abort")
              defaults.synchronize()
              return
          }
    }

    func write_rom(sender: AnyObject) {
          let dialog = NSOpenPanel();
          dialog.title                   = NSLocalizedString("Choose a ROM File (.bin)", comment: "");
          dialog.showsResizeIndicator    = true;
          dialog.showsHiddenFiles        = false;
          dialog.canCreateDirectories    = false;
          dialog.allowedFileTypes        = ["bin"];
          
          if (dialog.runModal() == NSApplication.ModalResponse.OK) {
              let result = dialog.url // Pathname of the file
              
              if (result != nil) {
                  let path = result!.path
                  let rompath = (path as String)
                  UserDefaults.standard.set(rompath, forKey: "ROM Readpath")
                  UserDefaults.standard.set(false, forKey: "Abort")
                  defaults.synchronize()
              }
          } else {
              UserDefaults.standard.set(true, forKey: "Abort")
              defaults.synchronize()
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
 
    
    func no_chip_found (){
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Cannot detect any chip!", comment: "")
        alert.informativeText = NSLocalizedString("Make sure the pliers is properly seated on the chip.", comment: "")
        alert.alertStyle = .warning
        let Button = NSLocalizedString("Bummer", comment: "")
        alert.addButton(withTitle: Button)
        alert.runModal()
    }
 
    
    func multiple_types (){
        UserDefaults.standard.set(true, forKey: "Force Chip Type")
        let chip_types = UserDefaults.standard.string(forKey: "Chip Types")
        //self.get_chip_type_text.isEnabled = true
        self.get_chip_type_text.isEditable = true
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Multiple chip types found!", comment: "")
        alert.informativeText = chip_types! + NSLocalizedString(" chip types has been recognized. Please enter the correct value in the input field that just appeared. It´s important to press 'Enter' after entering the chip type.", comment: "")
        alert.alertStyle = .warning
        let Button = NSLocalizedString("I understand", comment: "")
        alert.addButton(withTitle: Button)
        alert.runModal()
    }
    
    
    func wrong_type_entered (){
        //let chip_type = UserDefaults.standard.string(forKey: "Chip Type")
        //self.get_chip_type_text.isEnabled = true
        self.get_chip_type_text.isEditable = true
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Wrong chip type entered!", comment: "")
        alert.informativeText = NSLocalizedString("No or not the correct chip type was entered in the input field. Please try it again.", comment: "")
        alert.alertStyle = .warning
        let Button = NSLocalizedString("Bummer", comment: "")
        alert.addButton(withTitle: Button)
        alert.runModal()
    }
    
    
    func erase_confirmation (){
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Do you want it really?", comment: "")
        alert.informativeText = NSLocalizedString("All content on the chip will be erased!", comment: "")
        alert.alertStyle = .informational
        let Button = NSLocalizedString("Yes", comment: "")
        alert.addButton(withTitle: Button)
        let CancelButtonText = NSLocalizedString("No", comment: "")
        alert.addButton(withTitle: CancelButtonText)
        
        if alert.runModal() != .alertFirstButtonReturn {
            UserDefaults.standard.set(true, forKey: "Abort")
            return
        }
    }
  
    @objc private func download_wine(_ sender: Any) {
        self.bios_modding_progressbar.isHidden=false
        self.bios_modding_progressbar?.startAnimation(self);
        UserDefaults.standard.removeObject(forKey: "Successful")
        self.output_window.string=NSLocalizedString("Downloading and uncompressing PhoenixTool" , comment: "") + NSLocalizedString(" (Wineskin Wrapper)", comment: "") + NSLocalizedString("... please wait.", comment: "") + "\n"
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["_download_wine"])
                DispatchQueue.main.async {
                    let download_check = UserDefaults.standard.bool(forKey: "Successful")
                    if download_check == true {
                        self.output_window.string += "\n" + NSLocalizedString("Operation done!", comment: "")
                        self.output_window.scrollToEndOfDocument(nil)
                    } else {
                        self.output_window.string += "\n" + NSLocalizedString("Something went wrong. Please try again.", comment: "")
                        self.output_window.scrollToEndOfDocument(nil)
                    }
                    self.bios_modding_progressbar.isHidden=true
                    self.bios_modding_progressbar?.stopAnimation(self);
               }
           }
       }
 
    @objc private func download_crossover(_ sender: Any) {
        self.bios_modding_progressbar.isHidden=false
        self.bios_modding_progressbar?.startAnimation(self);
           UserDefaults.standard.removeObject(forKey: "Successful")
           self.output_window.string=NSLocalizedString("Downloading and uncompressing PhoenixTool", comment: "") + NSLocalizedString(" (CrossOver Bottle)", comment: "") + NSLocalizedString("... please wait.", comment: "") + "\n\n" + NSLocalizedString("Make sure that you have installed CrossOver v19.x to run this Bottle. If you don't already have it you can download the 14 Day trial from their website.", comment: "") + "\n\n\nhttps://media.codeweavers.com/pub/crossover/cxmac/demo/" + "\n\n"
           DispatchQueue.global(qos: .background).async {
               self.syncShellExec(path: self.scriptPath, args: ["_download_crossover"])
                   DispatchQueue.main.async {
                       let download_check = UserDefaults.standard.bool(forKey: "Successful")
                       if download_check == true {
                           self.output_window.string += "\n" + NSLocalizedString("Operation done!", comment: "")
                           self.output_window.scrollToEndOfDocument(nil)
                       } else {
                           self.output_window.string += "\n" + NSLocalizedString("Something went wrong. Please try again.", comment: "")
                           self.output_window.scrollToEndOfDocument(nil)
                       }
                    self.bios_modding_progressbar.isHidden=true
                    self.bios_modding_progressbar?.stopAnimation(self);
                  }
              }
       }
 
    @objc private func download_phoenixtool(_ sender: Any) {
        self.bios_modding_progressbar.isHidden=false
        self.bios_modding_progressbar?.startAnimation(self);
        UserDefaults.standard.removeObject(forKey: "Successful")
        self.output_window.string=NSLocalizedString("Downloading PhoenixTool", comment: "") + " " + NSLocalizedString("... please wait.", comment: "") + "\n"
         DispatchQueue.global(qos: .background).async {
             self.syncShellExec(path: self.scriptPath, args: ["_download_phoenixtool"])
                 DispatchQueue.main.async {
                     let download_check = UserDefaults.standard.bool(forKey: "Successful")
                     if download_check == true {
                         self.output_window.string += "\n" + NSLocalizedString("Operation done!", comment: "")
                         self.output_window.scrollToEndOfDocument(nil)
                     } else {
                         self.output_window.string += "\n" + NSLocalizedString("Something went wrong. Please try again.", comment: "")
                         self.output_window.scrollToEndOfDocument(nil)
                     }
                    self.bios_modding_progressbar.isHidden=true
                    self.bios_modding_progressbar?.stopAnimation(self);
                }
            }
    }
    
    func clear_window (){
        output_window.textStorage?.mutableString.setString("")
    }
    
    @objc private func download_mods(_ sender: Any) {
        self.bios_modding_progressbar.isHidden=false
        self.bios_modding_progressbar?.startAnimation(self);
        UserDefaults.standard.removeObject(forKey: "Successful")
        let model_check = UserDefaults.standard.string(forKey: "Model")
        self.output_window.string=NSLocalizedString("Downloading and uncompressing", comment: "") + " " + model_check! + " " + NSLocalizedString("MOD Files.", comment: "") + "\n"
         DispatchQueue.global(qos: .background).async {
             self.syncShellExec(path: self.scriptPath, args: ["_download_mods"])
                 DispatchQueue.main.async {
                     let download_check = UserDefaults.standard.bool(forKey: "Successful")
                     if download_check == true {
                         self.output_window.string += "\n" + NSLocalizedString("Operation done!", comment: "")
                         self.output_window.scrollToEndOfDocument(nil)
                     } else {
                         self.output_window.string += "\n" + NSLocalizedString("Something went wrong. Please try again.", comment: "")
                         self.output_window.scrollToEndOfDocument(nil)
                     }
                    self.bios_modding_progressbar.isHidden=true
                    self.bios_modding_progressbar?.stopAnimation(self);
                }
            }
    }

   
    
    func syncShellExec(path: String, args: [String] = []) {
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
