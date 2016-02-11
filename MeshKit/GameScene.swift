//
//  GameScene.swift
//  MeshKit
//
//  Created by Jelle De Vleeschouwer on 11/02/16.
//  Copyright (c) 2016 Jelle De Vleeschouwer. All rights reserved.
//

import SpriteKit

var nodeCount = 1

class GameScene: SKScene, SKPhysicsContactDelegate {
    var nodes: NSMutableArray = [];
    var paths: NSMutableArray = [];
    
    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        addNode(withID: nodeCount)
        nodeCount = nodeCount + 1
    }
    
    func addNode(withID id: Int) {
        let node = MeshNode(withID: id)
    
        /* Insert new node into node-list */
        nodes.addObject(node)
        
        /* Set position */
        if (id == 1) {
            node.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        } else {
            node.position = randPosition()
        }
        node.setScale(0.1)
        
        node.addNeighbour(MeshNode.getNode(withID: nodeCount - 1, fromArray: nodes))
        if let lbr = MeshNode.getNode(withID: nodeCount - 1, fromArray: nodes) {
            addPath(from: node, to:lbr)
        }
        
        /* Add the node to the scene */
        self.addChild(node)
    }
    
    /* Add a path from one node to another */
    func addPath(from node: MeshNode, to neighbour: MeshNode) {
        let path = node.createPath(toNeighbour: neighbour)
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
                /* Don't apply forces on the central node */
                if (node.id != 1) {
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
        let myLabel = SKLabelNode(fontNamed:"Avenir Next")
        myLabel.text = "6LoWPAN demo"
        myLabel.fontSize = 24
        myLabel.position = CGPoint(x:CGRectGetMaxX(self.frame) - (myLabel.frame.width / 2 + 10), y:CGRectGetMinX(self.frame) + myLabel.fontSize * 3.5)
        self.addChild(myLabel)
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        
        self.backgroundColor = NSColor.darkGrayColor()
    }
}
