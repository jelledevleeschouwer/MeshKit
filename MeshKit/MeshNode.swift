//
//  MeshNode.swift
//  MeshKit
//
//  Created by Jelle De Vleeschouwer on 11/02/16.
//  Copyright © 2016 Jelle De Vleeschouwer. All rights reserved.
//

import Foundation
import SpriteKit

let ATTRACTION: CGFloat  = 70
let REPULSION: CGFloat   = ATTRACTION * 200
let GENERAL_REP: CGFloat = ATTRACTION * 20
let GRAVITY: CGFloat     = 30

class MeshNode: SKSpriteNode {
    internal let idLabel: SKLabelNode
    
    internal var confirmed = false
    internal var neighbours: [MeshNode] = []
    var id: UInt8 = 0
    
    override var description: String {
        return "Node \(id)"
    }
    
    /*********************
     *  MESH
     *********************/
    func clearNeighbourConfirms() {
        for neigh in neighbours {
            neigh.confirmed = false
        }
    }
    
    /* Deletes every neighbour not confirmed */
    func validateNeighbours() -> [MeshNode] {
        var deleted: [MeshNode] = []
        
        for neigh in neighbours {
            if (neigh.confirmed == false) {
                deleted.append(neighbours.removeAtIndex(neighbours.indexOf(neigh)!))
                neigh.removeNeighbour(self)
            }
        }
        
        return deleted
    }
    
    func removeNeighbour(n: MeshNode?) {
        if let neighbour = n {
            if (neighbour.id != id) {
                neighbours = MeshNode.delNode(withID: neighbour.id, inArray: neighbours)
            }
        } else {
            return
        }
    }
    
    func addNeighbour(n: MeshNode?) {
        if let neighbour = n {
            if (neighbour.id != self.id) {
                if let found = MeshNode.findNode(withID: neighbour.id, inArray: neighbours) {
                    /* Node is already a neighbour */
                    found.confirmed = true
                } else {
                    /* Node is not already a neighbour, add as one */
                    neighbour.confirmed = true
                    neighbours.append(neighbour)
                    neighbour.addNeighbour(self)
                }
            }
        } else {
            return
        }
    }
    
    func isNeighbour(id: UInt8) -> Bool {
        if let _ = MeshNode.getNode(withID: id, fromArray: neighbours) {
            return true
        } else {
            return false
        }
    }
    
    func addPath(toNeighbour n:MeshNode, withColor color: NSColor) -> MeshPath {
        return MeshPath(from: self, toNeighbour: n, withColor: color)
    }
    
    /*********************
     *  CLASS FUNCTIONS
     *********************/
    class func findIndexOf(node n: MeshNode, inArray array: [MeshNode]) -> Int {
        var index = 0
        for node in array {
            if (node.id == n.id) {
                return index;
            }
            
            ++index
        }
        
        return -1
    }
    
    class func findIndexOfNode(withID id: UInt8, inArray array: [MeshNode]) -> Int {
        var index = 0
        for node in array {
            if (id == node.id) {
                return index
            }
            
            ++index
        }
        
        return -1
    }
    
    class func findNode(withID id: UInt8, inArray array: [MeshNode]) -> MeshNode? {
        for node in array {
            if (node.id == id) {
                return node
            }
        }
        
        return nil
    }
    
    class func delNode(withID id: UInt8, var inArray array: [MeshNode]) -> [MeshNode] {
        let index = findIndexOfNode(withID: id, inArray: array)
        
        if (index < 0) {
            return array
        }
        
        array.removeAtIndex(index)
        
        return array
    }
    
    /*********************
     *  PHYSICS
     *********************/
    func applyForces(nodes: [MeshNode]) {
        
        var force = CGVectorMake(0, 0);
        
        for node in nodes {
            var v = VectorMath.createVector(between: self, and: node)
            let r = VectorMath.magnitude(v);
            
            if (isNeighbour(node.id)) {
                /* Apply a force between this node and it's neighbour that pulls
                * the node towards it's neighbour */
                v = VectorMath.multiplyVector(v, with: ATTRACTION)
                
                /* Do apply the force */
                force = VectorMath.addVector(v, toVector: force)
                
                /* Apply a force between this node and it's neighbour that pushes
                * the node away from it's neighbour */
                v = VectorMath.createVector(between: self, and: node)
                v = VectorMath.multiplyVector(v, with: REPULSION / r);
                v = VectorMath.negate(v);
                
                /* Do apply the force */
                force = VectorMath.addVector(v, toVector: force)
            } else if (self.id != node.id && node.id != 0) {
                /* Apply a force between this node and it's neighbour that pushes
                * the node away from it's neighbour */
                v = VectorMath.createVector(between: self, and: node)
                v = VectorMath.multiplyVector(v, with: GENERAL_REP / r);
                v = VectorMath.negate(v);
                
                /* Do apply the force */
                force = VectorMath.addVector(v, toVector: force)
            } else if (node.id == 0) {
                if (neighbours.count == 0) {
                    /* Apply a gravitational force between this node and the center
                    * of the mesh */
                    v = VectorMath.multiplyVector(v, with: GRAVITY)
                    
                } else {
                    /* Apply a gravitational force between this node and the center
                    * of the mesh */
                    v = VectorMath.multiplyVector(v, with: GRAVITY / 10)
                }
                
                /* Do apply gravitational force */
                force = VectorMath.addVector(v, toVector: force)
            }
        }
        
        /* Don't do needless rendering */
        //if (VectorMath.magnitude(force) > 3.0) {
            self.physicsBody?.applyForce(force)
        //}
    }
    
    func initPhysics() {
        /* Intialise the physics body */
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.frame.size.width / 2)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = 1
        self.physicsBody?.restitution = 1
        self.physicsBody?.collisionBitMask = 2
        self.physicsBody?.linearDamping = 10
    }
    
    /*********************
     *  CLASS FUNCTIONS
     *********************/
    class func getNode(withID id: UInt8, fromArray array: NSArray) -> MeshNode? {
        for value in array {
            if let node = value as? MeshNode {
                if (node.id == id) {
                    return node
                }
            }
        }
        return nil
    }
    
    /*********************
     *  INITIALISATION
     *********************/
    init(withID id: UInt8) {
        let texture: SKTexture
        
        /* Initialize with sprite-image */
        if (id == 0) {
            texture = SKTexture()
        } else {
            texture = SKTexture(imageNamed: "circle")
        }
        
        idLabel = SKLabelNode(fontNamed: "Menlo")
        
        super.init(texture: texture, color: NSColor.clearColor(), size: texture.size())
        
        /* Set some params */
        self.id = id
        
        /**/
        
        if (id != 0) {
            idLabel.text = String(self.id)
            idLabel.fontSize = 200
            idLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 70)
            idLabel.fontColor = NSColor.blackColor()
            idLabel.zPosition = self.zPosition + 1
            self.addChild(idLabel)
            
            /* Initialise the physics */
            initPhysics()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}