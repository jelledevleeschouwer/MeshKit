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
let REPULSION: CGFloat   = ATTRACTION * 100
let GENERAL_REP: CGFloat = ATTRACTION * 20
let GRAVITY: CGFloat     = ATTRACTION * 10

class MeshNode: SKSpriteNode {
    var neighbours: NSMutableArray = []
    var id = 0
    
    /*********************
     *  MESH
     *********************/
    func removeNeighbour(n: MeshNode?) {
        if let neighbour = n {
            if (neighbour.id != id) {
                neighbours.removeObject(neighbour)
            }
        } else {
            return
        }
    }
    
    func addNeighbour(n: MeshNode?) {
        if let neighbour = n {
            if (neighbour.id != id) {
                neighbours.addObject(neighbour)
            }
        } else {
            return
        }
    }
    
    func isNeighbour(id: Int) -> Bool {
        if let _ = MeshNode.getNode(withID: id, fromArray: neighbours) {
            return true
        } else {
            return false
        }
    }
    
    func createPath(toNeighbour n:MeshNode, withColor color: NSColor) -> MeshPath {
        return MeshPath(from: self, toNeighbour: n, withColor: color)
    }
    
    /*********************
     *  PHYSICS
     *********************/
    func applyForces(nodes: NSMutableArray) {
        var force = CGVectorMake(0, 0);
        
        for value in nodes {
            if let node = value as? MeshNode {
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
                    /* Apply a gravitational force between this node and the center 
                     * of the mesh */
                    v = VectorMath.multiplyVector(v, with: GRAVITY)
                    
                    /* Do apply gravitational force */
                    force = VectorMath.addVector(v, toVector: force)
                }
            }
        }
        
        /* Don't do needless rendering */
        if (VectorMath.magnitude(force) > 3.0) {
            self.physicsBody?.applyForce(force)
        }
    }
    
    func initPhysics() {
        /* Intialise the physics body */
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.frame.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = 0
        self.physicsBody?.linearDamping = 10
    }
    
    /*********************
     *  CLASS FUNCTIONS
     *********************/
    class func getNode(withID id: Int, fromArray array: NSArray) -> MeshNode? {
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
    init(withID id: Int) {
        /* Initialize with sprite-image */
        let texture = SKTexture(imageNamed: "circle")
        super.init(texture: texture, color: NSColor.clearColor(), size: texture.size())
        
        /* Set some params */
        self.id = id
        
        /* Initialise the physics */
        initPhysics()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}