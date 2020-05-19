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

    
    @IBOutlet var download_progressbar: NSProgressIndicator!
    
    override func viewDidLoad() {
           super.viewDidLoad()
    }
    
    @IBAction func download_wine(_ sender: Any) {
        self.view.window?.close()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "download_wine"), object: nil)
    }
    
    @IBAction func download_crossover(_ sender: Any) {
        self.view.window?.close()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "download_crossover"), object: nil)
    }

    @IBAction func download_mods(_ sender: Any) {
        self.view.window?.close()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "download_mods"), object: nil)
    }
    
  
    @objc func cancel(_ sender: Any?) {
        self.view.window?.close()
    }
}

