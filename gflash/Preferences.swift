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

    
    override func viewDidLoad() {
           super.viewDidLoad()
       }
    
    @objc func cancel(_ sender: Any?) {
        self.view.window?.close()
    }
    
}
