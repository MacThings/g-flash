//
//  Preferences.swift
//  G-Flash
//
//  Created by Prof. Dr. Luigi on 17.05.20.
//  Copyright © 2020 Sascha Lamprecht. All rights reserved.
//

import Foundation
import Cocoa


class Biosmodding: NSViewController {

    
    @IBOutlet weak var download_button: NSButton!
    @IBOutlet weak var pulldown_empty_entry: NSMenuItem!
    @IBOutlet weak var pulldown_menu: NSPopUpButton!
    
    
    override func viewDidLoad() {
           super.viewDidLoad()
        self.pulldown_menu.selectItem(at: 0)
        self.pulldown_menu.item(withTitle: "")?.isHidden=true
    }
    
    @IBAction func mod_chooser(_ sender: Any) {
        self.pulldown_empty_entry.isHidden=true
        self.download_button.isEnabled=true
    }
    
    @IBAction func download_wine(_ sender: Any) {
        self.view.window?.close()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "download_wine"), object: nil)
    }
    
    @IBAction func download_phoenixtool(_ sender: Any) {
        self.view.window?.close()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "download_phoenixtool"), object: nil)
    }
    
    @IBAction func download_mods(_ sender: Any) {
        self.view.window?.close()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "download_mods"), object: nil)
    }
    
    @IBAction func help_mods(_ sender: Any) {
        NSWorkspace.shared.open(NSURL(string: "https://www.hackintosh-forum.de/forum/thread/45205-bios-mod-wwan-whitelist-mit-wenigen-schritten-selbstgemacht")! as URL)
    }
    
    @objc func cancel(_ sender: Any?) {
        self.view.window?.close()
    }
}

