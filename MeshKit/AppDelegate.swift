//
//  AppDelegate.swift
//  MeshKit
//
//  Created by Jelle De Vleeschouwer on 11/02/16.
//  Copyright (c) 2016 Jelle De Vleeschouwer. All rights reserved.
//


import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var configure: NSButton!
    @IBOutlet weak var title: NSTextField!
    
    let configurationViewController = NSViewController(nibName: "ConfigurationViewController", bundle: nil)
    var detachedWindow: NSWindow
    var detachedHUDWindow: NSPanel
    var popOver: NSPopover
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        /* Pick a size for the scene */
        
        if let scene = GameScene(fileNamed:"GameScene") {
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            /* */
            self.configure.wantsLayer = true
            self.title.wantsLayer = true
            
            self.skView!.presentScene(scene)
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            self.skView!.ignoresSiblingOrder = true
            
            self.skView!.showsFPS = true
            self.skView!.showsNodeCount = true
            //self.skView!.showsPhysics = true
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
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
    
    func popoverShouldDetach(popover: NSPopover) -> Bool {
        return true
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
        
        super.init()
        
        popOver.contentViewController = configurationViewController
        popOver.appearance = NSAppearance(appearanceNamed: NSAppearanceNameVibrantLight, bundle: nil)
        popOver.animates = true
        popOver.behavior = NSPopoverBehavior.Transient
        popOver.delegate = self
    }
}
