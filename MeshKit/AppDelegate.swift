//
//  AppDelegate.swift
//  MeshKit
//
//  Created by Jelle De Vleeschouwer on 11/02/16.
//  Copyright (c) 2016 Jelle De Vleeschouwer. All rights reserved.
//


import Cocoa
import SpriteKit
import ORSSerial

protocol ConfigurationViewControllerDelegate {
    var portPath: String { get set }
    var portState: String { get }
    var baudRate: UInt32 { get set }
    
    func connect() -> Int
    func disconnect() -> Int
    func availablePorts() -> [ORSSerialPort]
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate, NSWindowDelegate, ConfigurationViewControllerDelegate, ORSSerialPortDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var configure: NSButton!
    @IBOutlet weak var title: NSTextField!
    
    internal var configurationViewController = ConfigurationViewController(nibName: "ConfigurationViewController", bundle: nil)
    internal var detachedWindow: NSWindow
    internal var detachedHUDWindow: NSPanel
    internal var popOver: NSPopover
    internal var mainScene: GameScene? = nil
    
    var portPath: String = ""
    var portState: String = ""
    var baudRate: UInt32 = 115200
    internal var serialPort: ORSSerialPort? = nil
    
    /*********************
     *  ACTIONS
     *********************/
    @IBAction func configure(sender: AnyObject) {
        if (detachedHUDWindow.visible == true) {
            detachedHUDWindow.close()
        }
        
        if (detachedWindow.visible == true) {
            detachedWindow.makeKeyAndOrderFront(self)
            return
        }
        
        let targetButton = sender as! NSButton
        let edge = NSRectEdge(rectEdge: CGRectEdge.MinYEdge)
        
        popOver.showRelativeToRect(targetButton.bounds, ofView: sender as! NSView, preferredEdge: edge)
    }
    
    /*********************
     *  CUSTOM DELEGATION
     *********************/
    func connect() -> Int {
        serialPort = ORSSerialPort(path: portPath)
        if let _ = serialPort {
            serialPort!.baudRate = NSNumber(unsignedInt: baudRate)
            serialPort!.delegate = self
            serialPort!.open()
            portState = "Connected"
            return 0
        }
        portState = "Connect failed"
        return -1
    }
    
    func disconnect() -> Int {
        if let _ = serialPort {
            if serialPort!.close() {
                portState = "Disconnect"
                serialPort = nil
                return 0
            }
        }
        portState = "Disconnect failed"
        return -1
    }
    
    func serialPortWasRemovedFromSystem(serialPort: ORSSerialPort) {
        portState = "Port removed"
        self.serialPort = nil
    }
    
    func serialPort(serialPort: ORSSerialPort, didReceiveData data: NSData) {
        let received = NSString(data: data, encoding: NSUTF8StringEncoding)
        print("Received")
        print(received)
    }
    
    func availablePorts() -> [ORSSerialPort] {
        return ORSSerialPortManager.sharedSerialPortManager().availablePorts
    }
    
    /*********************
     *  UI
     *********************/
    func popoverShouldDetach(popover: NSPopover) -> Bool {
        return true
    }
    
    /*********************
     *  INITIALISATION
     *********************/
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        /* Pick a size for the scene */
        
        if let scene = GameScene(fileNamed:"GameScene") {
            /* Set window size */
            if let w = self.window {
                w.setFrame(CGRectMake(0, 0, NSScreen.mainScreen()!.frame.width, NSScreen.mainScreen()!.frame.height), display: true)
                w.contentAspectRatio = w.frame.size
                w.makeKeyAndOrderFront(self)
            }
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFit
            
            skView.frame.size = self.window.frame.size
            scene.size = skView.frame.size
            
            mainScene = scene
            
            /* XXX Display AppKit widgets on top of skView */
            self.configure.wantsLayer = true
            self.title.wantsLayer = true
            
            /* Present SpriteKit Scene */
            self.skView!.presentScene(scene)
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            self.skView!.ignoresSiblingOrder = true
            
            /* DEBUG SpriteKit */
            self.skView!.showsFPS = true
            self.skView!.showsNodeCount = true
            //self.skView!.showsPhysics = true
        }
    }
    
    override init() {
        let frame = configurationViewController!.view.bounds
        var styleMask = NSTitledWindowMask + NSClosableWindowMask
        let rect = NSWindow.contentRectForFrameRect(frame, styleMask: styleMask)
        detachedWindow = NSWindow(contentRect: rect, styleMask: styleMask, backing: NSBackingStoreType.Buffered , `defer`: true)
        detachedWindow.contentViewController = configurationViewController
        detachedWindow.releasedWhenClosed = false
        
        styleMask = NSTitledWindowMask + NSClosableWindowMask + NSHUDWindowMask + NSUtilityWindowMask;
        detachedHUDWindow = NSPanel(contentRect: rect, styleMask: styleMask, backing: NSBackingStoreType.Buffered , `defer`: true)
        detachedHUDWindow.contentViewController = configurationViewController
        detachedHUDWindow.releasedWhenClosed = false
        popOver = NSPopover()
        popOver.contentViewController = configurationViewController
        popOver.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
        popOver.animates = true
        popOver.behavior = NSPopoverBehavior.Transient
        
        /* Have to initialise superclass before we can set the NSPopoverDelegate*/
        super.init()
        popOver.delegate = self
        
        let ports = ORSSerialPortManager.sharedSerialPortManager().availablePorts
        for port in ports {
            print(port.name)
        }
        
        configurationViewController?.portDelegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "screenResize:", name: NSWindowDidResizeNotification, object: nil)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
    func screenResize(notification: NSNotification) {
        if let scene = mainScene {
            scene.updateBorders()
        }
    }
}
