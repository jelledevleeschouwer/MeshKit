//
//  GameScene.swift
//  MeshKit
//
//  Created by Jelle De Vleeschouwer on 11/02/16.
//  Copyright (c) 2016 Jelle De Vleeschouwer. All rights reserved.
//

import Cocoa
import SpriteKit
import ORSSerial

var nodeCount: UInt8 = 1

class GameScene: SKScene, SKPhysicsContactDelegate {
    internal let pathColor = NSColor(red: 0.7002, green: 0.8241, blue: 0.031, alpha: 1.0)
    internal let scale: CGFloat = 0.2
    
    var nodes: [MeshNode] = [];
    var paths: [MeshPath] = [];
    
    var count = 0
    
    func parseNeighbourList(list: String) {
        var symbols = list.characters.split{$0 == " "}.map(String.init)
        
        if (symbols.count < 1) {
            return
        }
        
        /* Determine the node */
        var node: UInt8 = 0
        if let node_n = UInt8(symbols[0]) {
            node = node_n
        }
        symbols.removeFirst()
        
        var neighbours: [UInt8] = []
        for symbol in symbols {
            if let n = UInt8(symbol) {
                neighbours.append(n)
            }
        }
        
        self.parseNode(withID: node, andNeighbours: neighbours)
    }
    
    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        
        /*
        switch(count) {
        case 0:
            parseNeighbourList("001 002")
        case 1:
            parseNeighbourList("002 001")
        case 2:
            parseNeighbourList("003")
        case 3:
            parseNeighbourList("003 002 001")
        case 4:
            parseNeighbourList("004 002 003")
        case 5:
            parseNeighbourList("005 002 003")
        case 6:
            parseNeighbourList("006 001")
        case 7:
            parseNeighbourList("004 003")
        case 8:
            parseNeighbourList("002 001")
        case 9:
            parseNeighbourList("003")
        case 10:
            parseNeighbourList("003 002 001")
        case 11:
            parseNeighbourList("004 003")
        case 12:
            parseNeighbourList("005 004")
        default:
            parseNeighbourList("")
            /* Do nothing */
        }

        
        count++
*/
    }
    
    func addGravity() {
        createNode(withID: 0)
    }
    
    func parseNeighbours(neighbours: [UInt8], of node: MeshNode) {
        /* Clear out all node-confirmations */
        node.clearNeighbourConfirms()
        
        for neigh in neighbours {
            /* If a neighbour in this list also really exists */
            if let neighbour = MeshNode.findNode(withID: neigh, inArray: nodes) {
                /* Add the neighbour to the node */
                node.addNeighbour(neighbour)
                
                /* Add a path between this node and the other one, if a new path was created also add it to Sprite-tree */
                let (npaths, new) = MeshPath.addPath(from: node, to: neighbour, withColor: pathColor, toArray: paths)
                if (new != nil) {
                    self.addChild(new!)
                    paths = npaths
                }
            }
        }
        
        /* Delete all neighbours not reconfirmed or newly added */
        let deleted = node.validateNeighbours()
        
        /* Delete all outdated paths */
        let (npaths, delpaths) = MeshPath.delPaths(fromNode: node, toNodes: deleted, fromArray: paths)
        
        self.removeChildrenInArray(delpaths)
        paths = npaths
    }
    
    func createNode(withID id: UInt8) -> MeshNode {
        let node = MeshNode(withID: id)
        
        /* Insert new node into node-list */
        nodes.append(node)
        
        /* Set position */
        if (id > 1) {
            /* For plain nodes, generate a random position */
            node.position = randPosition()
        } else {
            /* Put the 6LBR and the gravity node in the center of the screen */
            node.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        }
        
        node.setScale(scale)
        
        self.addChild(node)
        
        return node
    }
    
    func parseNode(withID id: UInt8, andNeighbours neighbours: [UInt8]) {
        /* If the node with this ID already exists */
        if let node = MeshNode.findNode(withID: id, inArray: nodes) {
            parseNeighbours(neighbours, of: node)
        } else {
            /* Node doesn't exist, create it */
            let new = createNode(withID: id)
            
            parseNeighbours(neighbours, of: new)
        }
    }
    
    func randPosition() -> CGPoint {
        let sizeX = Int(CGRectGetMaxX(self.frame))
        let sizeY = Int(CGRectGetMaxY(self.frame))
        let randomX = CGFloat(Int(arc4random()) % sizeX)
        let randomY = CGFloat(Int(arc4random()) % sizeY)
        
        return CGPointMake(randomX, randomY)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        for node in nodes {
            /* Don't apply forces on the central node or on the gravity node */
            if (node.id > 1) {
                node.applyForces(nodes)
            }
        }
        
        /* Update each path */
        for path in paths {
            path.updatePath()
        }
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        updateBorders()
        
        self.physicsBody?.categoryBitMask = 2
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        
        //self.backgroundColor = NSColor(red: 0.5803, green: 0.5514, blue: 0.5172, alpha: 1.0)
        self.backgroundColor = NSColor.whiteColor()
        
        NSScreen.mainScreen()!.frame
        
        addGravity()
    }
    
    func updateBorders() {
        let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
    }
}
