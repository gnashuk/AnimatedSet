//
//  CardView.swift
//  Graphical Set
//
//  Created by Oleg Gnashuk on 2/24/18.
//  Copyright © 2018 Oleg Gnashuk. All rights reserved.
//

import UIKit

@IBDesignable
class CardView: UIView {
    
    var card: Card = Card(Card.Color.color1, Card.Number.number3, Card.Shape.shape3, Card.Fill.fill3) { didSet { setNeedsDisplay() } }
    
    var isSelected: Bool = false { didSet { setNeedsDisplay() } }
    var isHinted: Bool = false { didSet { setNeedsDisplay() } }
    
    private var shapes: [(ShapeView, ShapePosition)] = []

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
        
        if isSelected {
            layer.borderColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        } else if isHinted {
            layer.borderColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        } else {
            layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        }
        
        layer.borderWidth = isSelected || isHinted ? 3.0 : 1.0
        
        if shapes.count > 0 {
            shapes = []
        }
        drawShapes()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        positionShapes()
    }
    
    private func drawShapes() {
        subviews.forEach { $0.removeFromSuperview() }
        
        switch card.number {
        case .number1:
            createShape(.single)
        case .number2:
            createShape(.firstOfTwo)
            createShape(.secondOfTwo)
        case .number3:
            createShape(.firstOfThree)
            createShape(.secondOfThree)
            createShape(.thirdOfThree)
        }
        
        positionShapes()
    }
    
    private func createShape(_ position: ShapePosition) {
        let shapeView = ShapeView()
        shapeView.frame = initialShapeFrame
        shapeView.shape = card.shape
        shapeView.fill = card.fill
        shapeView.color = ModelToView.colors[card.color]!

        shapeView.isOpaque = false
        self.addSubview(shapeView)
        shapes.append((shapeView, position))
    }
    
    private func positionShapes() {
        for (shape, position) in shapes {
            shape.center = getShapeCenter(position: position)
        }
    }
    
    private func getShapeCenter(position: ShapePosition) -> CGPoint {
        switch position {
        case .single, .secondOfThree:
            return calculateShapeViewCenter(0.0)
        case .firstOfTwo:
            return calculateShapeViewCenter(shapeWidth)
        case .secondOfTwo:
            return calculateShapeViewCenter(-shapeWidth)
        case .firstOfThree:
            return calculateShapeViewCenter(shapeWidth * 1.5)
        case .thirdOfThree:
            return calculateShapeViewCenter(-shapeWidth * 1.5)
        }
    }
    
    private func calculateShapeViewCenter(_ offsetBy: CGFloat) -> CGPoint {
        return bounds.width < bounds.height
            ? CGPoint(x: bounds.midX, y: bounds.midY + offsetBy)
            : CGPoint(x: bounds.midX + offsetBy, y: bounds.midY)
    }
    
    private enum ShapePosition {
        case single
        case firstOfTwo
        case secondOfTwo
        case firstOfThree
        case secondOfThree
        case thirdOfThree
    }

}

extension CardView {
    private struct SizeRatio {
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let viewWidthToShapeWidth: CGFloat = 3
    }
    
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    
    private var shapeWidth: CGFloat {
        return min(bounds.width, bounds.height) / SizeRatio.viewWidthToShapeWidth
    }
    
    private var initialShapeFrame: CGRect {
        return CGRect(origin: CGPoint.zero, size: CGSize(width: shapeWidth, height: shapeWidth))
    }
}

struct ModelToView {
    static let colors = [Card.Color.color1 : #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), .color2 : #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), .color3 : #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)]
}
