//
//  VectorMath.swift
//  MeshKit
//
//  Created by Jelle De Vleeschouwer on 11/02/16.
//  Copyright © 2016 Jelle De Vleeschouwer. All rights reserved.
//

import Foundation
import SpriteKit

class VectorMath: NSObject {
    /* Addition of two vectors */
    class func addVector(a: CGVector, toVector b: CGVector) -> CGVector {
        return CGVectorMake(a.dx + b.dx, a.dy + b.dy)
    }
    
    /* Substraction of two vectors */
    class func subtractVector(a: CGVector, fromVector b: CGVector) -> CGVector {
        return CGVectorMake(b.dx - a.dx, b.dy - b.dy)
    }
    
    /* Multiply vector with a constant */
    class func multiplyVector(a: CGVector, with c: CGFloat) -> CGVector {
        return CGVectorMake(a.dx * c, a.dy * c)
    }
    
    /* Sum together all CGVectors in an NSArray */
    class func sumVectorArray(array: NSArray) -> CGVector {
        var v1 = CGVectorMake(0, 0)
        
        for value in array {
            if let v = value as? CGVector {
                v1 = self.addVector(v, toVector: v1)
            }
        }
        
        return v1
    }
    
    /* Create a vector between two SKSpriteNodes */
    class func createVector(between a: SKSpriteNode, and b: SKSpriteNode) -> CGVector {
        return CGVectorMake(b.position.x - a.position.x, b.position.y - a.position.y)
    }
    
    /* Calculate the magnitude (absolute value) of a vector */
    class func magnitude(a: CGVector) -> CGFloat {
        var magnitude = (a.dx * a.dx) + (a.dy * a.dy)
        magnitude = sqrt(magnitude)
        return magnitude
    }
    
    /* Get the unit vector of a vector */
    class func unitVector(a: CGVector) -> CGVector {
        return CGVectorMake(a.dx / self.magnitude(a), a.dy / self.magnitude(a))
    }
    
    /* Same vector in opposite direction */
    class func negate(a: CGVector) -> CGVector {
        return self.multiplyVector(a, with: -1)
    }
    
    /* Determine a vector between in an SKSpriteNode and a Point */
    class func vectorFromNode(a: SKSpriteNode, toPoint b: CGPoint) -> CGVector {
        return CGVectorMake(b.x - a.position.x, b.y - a.position.y)
    }
}
