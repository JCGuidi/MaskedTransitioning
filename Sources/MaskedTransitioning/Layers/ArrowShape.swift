//
//  ArrowShape.swift
//  MaskedTransitioning
//
//  Created by Juan Cruz Guidi on 14/01/2021.
//  Copyright © 2020 Juan Cruz Guidi. All rights reserved.
//

import UIKit

enum ArrowShape {
    static func leftArrow(in bounds: CGRect) -> CAShapeLayer {
        let arrowShape = getBaseShape(in: bounds)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: bounds.width * 3/4, y: bounds.height / 4))
        path.addLine(to: CGPoint(x: bounds.width * 0.5, y: bounds.height / 2))
        path.addLine(to: CGPoint(x: bounds.width * 3/4, y: bounds.height * 0.75))
        arrowShape.path = path
        
        return arrowShape
    }
    
    static func rightArrow(in bounds: CGRect) -> CAShapeLayer {
        let arrowShape = getBaseShape(in: bounds)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: bounds.width / 4, y: bounds.height / 4))
        path.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height / 2))
        path.addLine(to: CGPoint(x: bounds.width / 4, y: bounds.height * 0.75))
        arrowShape.path = path
        
        return arrowShape
    }
}

//MARK: - Private Methods

private extension ArrowShape {
    static func getBaseShape(in bounds: CGRect) -> CAShapeLayer {
        let arrowShape = CAShapeLayer()
        arrowShape.strokeColor = UIColor.lightGray.cgColor
        arrowShape.fillColor = UIColor.clear.cgColor
        arrowShape.lineWidth = 5
        arrowShape.lineCap = .round
        arrowShape.frame = bounds
        return arrowShape
    }
}
