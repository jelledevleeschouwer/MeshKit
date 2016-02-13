//
//  ConfigurationViewController.swift
//  
//
//  Created by Jelle De Vleeschouwer on 12/02/16.
//
//

import Cocoa

class ConfigurationViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var stateLabel: NSTextField!
    @IBOutlet weak var disconnectBtn: NSButton!
    @IBOutlet weak var connectBtn: NSButton!
    @IBOutlet weak var portTable: NSTableView!
    @IBOutlet weak var baudRates: NSPopUpButton!
    
    /* Delegate */
    var portDelegate: ConfigurationViewControllerDelegate? = nil
    
    /* Temporarily valid array with paths to available ports
     * this to not allow ports to be changed when the configuration view 
     * is opened .
     */
    internal var paths: NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do view setup here.
        if let dele = portDelegate {
            stateLabel.stringValue = dele.portState
            stateLabel.needsDisplay = true
        }
        
        portTable.setDataSource(self)
        portTable.setDelegate(self)
        
        /* On first display, disable disconnect */
        disconnectBtn.enabled = false
        
        baudRates.selectItemAtIndex(baudRates.itemArray.count - 1)
    }
    
    @IBAction func connect(sender: AnyObject) {
        /* If none is selected return immediatelly */
        if (portTable.selectedRow < 0) {
            return
        }
        
        if var del = portDelegate {
            /* Disable connect and enable disconnect */
            connectBtn.enabled = false
            disconnectBtn.enabled = true
            
            /* If one is selected, try to connect */
            if let path = (paths.objectAtIndex(portTable.selectedRow) as? String) {
                /* Set the selected baudrate */
                del.baudRate = UInt32(baudRates.selectedCell()!.title)!

                /* Set the selected port */
                del.portPath = path
                print("[PORT] Trying to connect to: \(path)")
                
                if (del.connect() < 0) {
                    connectBtn.enabled = true
                    print("[PORT] Connecting failed")
                } else {
                    print("[PORT] Connecting succeeded")
                }
            }
            
            stateLabel.stringValue = portDelegate!.portState
            stateLabel.needsDisplay = true
        }
    }
    
    @IBAction func disconnect(sender: AnyObject) {
        if let _ = portDelegate {
            connectBtn.enabled = true
            disconnectBtn.enabled = false
            
            if (portDelegate!.disconnect() < 0) {
                disconnectBtn.enabled = true
                print("[PORT] Disconnecting failed")
            } else {
                print("[PORT] Disconnecting succeeded")
            }
            
            stateLabel.stringValue = portDelegate!.portState
            stateLabel.needsDisplay = true
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if let _ = portDelegate {
            return portDelegate!.availablePorts().count
        }
        return 0
    }

    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if let _ = portDelegate {
            if row < portDelegate!.availablePorts().count {
                let port = portDelegate!.availablePorts()[row]
                if tableView.tableColumns[0] == tableColumn {
                    return port.name
                } else {
                    paths.insertObject(port.path, atIndex: row)
                    return port.path
                }
            }
            return nil
        }
        return nil
    }
}
