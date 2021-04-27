//
//  CircleMarker.swift
//  Canada Covid-19 Vaccine Tracker
//
//  Created by Rahul Niraula on 2021-04-26.
//

import Foundation
import Charts

class CircleMarker: MarkerImage {
    
    @objc var color: UIColor
    @objc var radius: CGFloat = 4
    
    @objc public init(color: UIColor) {
        self.color = color
        super.init()
    }
    
    override func draw(context: CGContext, point: CGPoint) {
        let circleRect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
        
        context.setFillColor(color.cgColor)
        context.setStrokeColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        
        context.setLineWidth(2)

        context.strokeEllipse(in: circleRect)
        context.fillEllipse(in: circleRect)

        
        
        context.restoreGState()
    }
}
