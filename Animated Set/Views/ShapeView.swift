//
//  ShapeView.swift
//  Graphical Set
//
//  Created by Oleg Gnashuk on 2/24/18.
//  Copyright © 2018 Oleg Gnashuk. All rights reserved.
//

import UIKit

class ShapeView: UIView {
    
    var shape: Card.Shape = Card.Shape.shape1 { didSet { setNeedsLayout() } }
    var fill: Card.Fill = Card.Fill.fill1 { didSet { setNeedsLayout() } }
    var color: UIColor = .red { didSet { setNeedsLayout() } }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let path = pathForShape()
        path.lineWidth = lineWidth
        
        switch fill {
        case .fill1:
            color.setFill()
            path.fill()
        case .fill2:
            path.addClip()
            color.setStroke()
            path.move(to: CGPoint(x: bounds.midX, y: bounds.minY))
            path.addLine(to: CGPoint(x: bounds.midX, y: bounds.maxY))
            path.stroke()
//            for x in stride(from: 0, to: bounds.width, by: bounds.width / 10) {
//                let path = UIBezierPath()
//                path.move(to: CGPoint(x: x, y: 0))
//                path.addLine(to: CGPoint(x: 0, y: x))
//                path.stroke()
//            }
//            for y in stride(from: 0, to: bounds.width, by: bounds.width / 10) {
//                let path = UIBezierPath()
//                path.move(to: CGPoint(x: y, y: bounds.height))
//                path.addLine(to: CGPoint(x: bounds.width, y: y))
//                path.stroke()
//            }
        case .fill3:
            color.setStroke()
            path.stroke()
        }
        
        
    }
    
    private func pathForShape() -> UIBezierPath {
        let inset = lineWidth / 2
        switch shape {
        case .shape1:
            let path = UIBezierPath(rect: bounds.insetBy(dx: inset, dy: inset))
            return path
        case .shape2:
            let path = UIBezierPath(ovalIn: bounds.insetBy(dx: inset, dy: inset))
            return path
        case .shape3:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: bounds.midX, y: bounds.minY + inset))
            path.addLine(to: CGPoint(x: bounds.maxX - inset, y: bounds.maxY - inset))
            path.addLine(to: CGPoint(x: bounds.minX + inset, y: bounds.maxY - inset))
            path.close()
            return path
        }
    }

}

extension ShapeView {
    private struct SizeRatio {
        static let viewWidthToLineWidth: CGFloat = 10.0
    }

    private var lineWidth: CGFloat {
        return min(bounds.width, bounds.height) / SizeRatio.viewWidthToLineWidth
    }
}
