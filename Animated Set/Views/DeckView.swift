//
//  DeckView.swift
//  Animated Set
//
//  Created by Oleg Gnashuk on 3/17/18.
//  Copyright © 2018 Oleg Gnashuk. All rights reserved.
//

import UIKit

@IBDesignable
class DeckView: UIView {
    var labelText: String = "" {
        didSet {
            (subviews[0] as! UILabel).text = labelText
        }
    }
    
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: 8.0)
        roundedRect.addClip()
        UIColor.gray.setFill()
        roundedRect.fill()
    }
}
