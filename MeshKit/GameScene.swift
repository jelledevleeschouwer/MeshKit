//
//  GameScene.swift
//  MeshKit
//
//  Created by Jelle De Vleeschouwer on 11/02/16.
//  Copyright (c) 2016 Jelle De Vleeschouwer. All rights reserved.
//

import SpriteKit
import ORSSerial

var nodeCount = 1

class GameScene: SKScene, SKPhysicsContactDelegate {
    internal let color = NSColor(red: 0.7002, green: 0.8241, blue: 0.031, alpha: 1.0)
    
    var nodes: NSMutableArray = [];
    var paths: NSMutableArray = [];
    
    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        addNode(withID: nodeCount)
        nodeCount = nodeCount + 1
    }
    
    func addGravity() {
        addNode(withID: 0);
    }
    
    func addNode(withID id: Int) {
        let node = MeshNode(withID: id)
    
        /* Insert new node into node-list */
        nodes.addObject(node)
        
        /* Set position */
        if (id > 1) {
            /* For plain nodes, generate a random position */
            node.position = randPosition()
        } else {
            /* Put the 6LBR and the gravity node in the center of the screen */
            node.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        }
        node.setScale(0.1)
        
        node.addNeighbour(MeshNode.getNode(withID: nodeCount - 1, fromArray: nodes))
        if let lbr = MeshNode.getNode(withID: nodeCount - 1, fromArray: nodes) {
            addPath(from: node, to:lbr, withColor: color)
        }
        
        /* Add the node to the scene */
        self.addChild(node)
    }
    
    /* Add a path from one node to another */
    func addPath(from node: MeshNode, to neighbour: MeshNode, withColor color: NSColor) {
        let path = node.createPath(toNeighbour: neighbour, withColor: color)
        paths.addObject(path)
        self.addChild(path)
    }
    
    /* Delete a path from on node to another */
    func deletePath(from node: MeshNode, to neighbour:MeshNode) {
        if let path = MeshPath.getPath(fromNodeWithID: node.id, toNodeWithID: neighbour.id, fromArray: paths) {
            paths.removeObject(path)
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
        for value in nodes {
            if let node = value as? MeshNode {
                /* Don't apply forces on the central node or on the gravity node */
                if (node.id > 1) {
                    node.applyForces(nodes)
                }
            }
        }
        
        for value in paths {
            if let path = value as? MeshPath {
                path.updatePath()
            }
        }
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        
        self.backgroundColor = NSColor(red: 0.5803, green: 0.5514, blue: 0.5172, alpha: 1.0)
    }
    
    
}
