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
    class func getPath(fromNodeWithID nodeID: Int, toNodeWithID neighID: Int, fromArray array: NSArray) -> MeshPath? {
        for value in array {
            if let path = value as? MeshPath {
                if (path.neighbour.id == neighID && path.node.id == nodeID) {
                    return path
                }
            }
        }
        return nil
    }
    
    /*********************
    *  INITIALISATION
     *********************/
    init(from node: MeshNode, toNeighbour neighbour: MeshNode) {
        self.node = node
        self.neighbour = neighbour
        self.meshPath = CGPathCreateMutable();
        
        super.init()
        
        CGPathMoveToPoint(self.meshPath, nil, self.node.position.x, self.node.position.y)
        CGPathAddLineToPoint(self.meshPath, nil, self.neighbour.position.x, self.neighbour.position.y)
        self.path = self.meshPath
        self.strokeColor = NSColor(red: 0.75, green: 0.84, blue: 0.00, alpha: 1.00)
        self.lineWidth = 2.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}