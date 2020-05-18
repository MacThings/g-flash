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

    
    override func viewDidLoad() {
           super.viewDidLoad()
       }
    
    @objc func cancel(_ sender: Any?) {
        self.view.window?.close()
    }
    
}
