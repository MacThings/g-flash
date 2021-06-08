//
//  Website.swift
//
//
//  Created by Prof. Dr. Luigi on 13.08.19.
//

import Cocoa
import WebKit

class Website: NSViewController {
    
    @IBOutlet weak var webView: WebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        let url = NSURL (string: "https://update.kextupdater.de/gflash/gflash.html")
        let requestObj = NSURLRequest(url: url! as URL)
        webView.mainFrame.load(requestObj as URLRequest)
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @objc func cancel(_ sender: Any?) {
        self.view.window?.close()
    }
    
}
