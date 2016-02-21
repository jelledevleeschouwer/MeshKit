//
//  MeshPath.swift
//  MeshKit
//
//  Created by Jelle De Vleeschouwer on 11/02/16.
//  Copyright © 2016 Jelle De Vleeschouwer. All rights reserved.
//

import Foundation
import SpriteKit

class MeshPath: SKShapeNode {
    var meshPath: CGMutablePathRef
    var node: MeshNode
    var neighbour: MeshNode
    
    override var description: String {
        return "Path from \(node.id) to \(neighbour.id)"
    }
    
    /*********************
     *  MESH
     *********************/
    func updatePath() {
        self.meshPath = CGPathCreateMutable();
        CGPathMoveToPoint(self.meshPath, nil, self.node.position.x, self.node.position.y)
        CGPathAddLineToPoint(self.meshPath, nil, self.neighbour.position.x, self.neighbour.position.y)
        self.path = self.meshPath
    }
    
    /*********************
     *  CLASS FUNCTIONS
     *********************/
    class func findPath(fromNodeWithID nodeID: UInt8, toNodeWithID neighID: UInt8, inArray array: [MeshPath]) -> MeshPath? {
        for path in array {
            if (path.neighbour.id == neighID && path.node.id == nodeID) {
                return path
            }
        }
        return nil
    }
    
    class func findPaths(fromNodeWithID id: UInt8, inArray array: [MeshPath]) -> [MeshPath] {
        var ret: [MeshPath] = []
        
        for path in array {
            if (path.node.id == id || path.neighbour.id == id) {
                ret.append(path)
            }
        }
        
        return ret
    }
    
    class func findIndexOfPath(fromNodeWithID nodeID: UInt8, toNodeWithID neighID: UInt8, inArray array: [MeshPath]) -> Int {
        for path in array {
            if ((path.node.id == nodeID && path.neighbour.id == neighID) || (path.node.id == neighID && path.neighbour.id == nodeID)) {
                return array.indexOf(path)!
            }
        }
        
        return -1
    }
    
    class func delPath(fromNodeWithID nodeID: UInt8, toNodeWithID neighID: UInt8, var fromArray array: [MeshPath]) -> ([MeshPath], MeshPath?) {
        let index = findIndexOfPath(fromNodeWithID: nodeID, toNodeWithID: neighID, inArray: array)
        
        if (index < 0) {
            return (array, nil)
        }
        
        let del = array.removeAtIndex(index)
        
        return (array, del)
    }
    
    class func delPaths(fromNode node: MeshNode, toNodes nodes: [MeshNode], var fromArray array: [MeshPath]) -> ([MeshPath], [MeshPath]) {
        var deleted: [MeshPath] = []
        
        for neigh in nodes {
            var (narray, del) = delPath(fromNodeWithID: node.id, toNodeWithID: neigh.id, fromArray: array)
            if (del != nil) {
                array = narray
                deleted.append(del!)
            }
            
            // Also delete the possible reverse path
            (narray, del) = delPath(fromNodeWithID: neigh.id, toNodeWithID: node.id, fromArray: array)
            if (del != nil) {
                array = narray
                deleted.append(del!)
            }
        }
        
        return (array, deleted)
    }
    
    class func delPaths(fromNodeWithID id: UInt8, var fromArray array: [MeshPath]) -> [MeshPath] {
        for path in array {
            if (path.node.id == id || path.neighbour.id == id) {
                array.removeAtIndex(array.indexOf(path)!)
            }
        }
        
        return array
    }
    
    class func addPath(from node: MeshNode, to neigh: MeshNode, withColor color: NSColor, var toArray array: [MeshPath]) -> ([MeshPath], MeshPath?) {
        if let _ = MeshPath.findPath(fromNodeWithID: node.id, toNodeWithID: neigh.id, inArray: array) {
            /* Path already exists */
        } else {
            /* Create new path and add to array */
            let new = MeshPath(from: node, toNeighbour: neigh, withColor: color)
            array.append(new)
            return (array, new)
        }
        
        return (array, nil)
    }
    
    /*********************
    *  INITIALISATION
     *********************/
    init(from node: MeshNode, toNeighbour neighbour: MeshNode, withColor color: NSColor) {
        self.node = node
        self.neighbour = neighbour
        self.meshPath = CGPathCreateMutable();
        
        super.init()
        
        CGPathMoveToPoint(self.meshPath, nil, self.node.position.x, self.node.position.y)
        CGPathAddLineToPoint(self.meshPath, nil, self.neighbour.position.x, self.neighbour.position.y)
        self.path = self.meshPath
        self.strokeColor = color
        self.lineWidth = 2.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}