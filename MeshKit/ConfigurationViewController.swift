//
//  ConfigurationViewController.swift
//  
//
//  Created by Jelle De Vleeschouwer on 12/02/16.
//
//

import Cocoa

class ConfigurationViewController: NSViewController {

    @IBOutlet weak var state: NSTextField!
    @IBOutlet weak var portPath: NSTextField!
    @IBOutlet weak var connectButton: NSButton!
    @IBOutlet weak var disconnectButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func disconnect(sender: AnyObject) {
    }
    @IBAction func connect(sender: AnyObject) {
    }
    
}
