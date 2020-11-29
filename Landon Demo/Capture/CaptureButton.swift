//
//  CaptureButton.swift
//  LandonDemo
//
//  Created by Jack Mousseau on 11/29/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

import UIKit

/// A button styled like the default camera app's capture button.
final class CaptureButton: UIControl {

    /// The capture button's impact feedback generator.
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)

    /// The capture button's inner circle layer.
    private lazy var innerCircleLayer: CAShapeLayer = {
        let outerRingLayer = CAShapeLayer()
        outerRingLayer.fillColor = UIColor.white.cgColor
        outerRingLayer.rasterizationScale = UIScreen.main.scale
        outerRingLayer.shouldRasterize = true
        return outerRingLayer
    }()

    /// The capture button's outer ring layer.
    private lazy var outerRingLayer: CAShapeLayer = {
        let outerRingLayer = CAShapeLayer()
        outerRingLayer.fillColor = UIColor.white.cgColor
        outerRingLayer.rasterizationScale = UIScreen.main.scale
        outerRingLayer.shouldRasterize = true
        return outerRingLayer
    }()

    override var isHighlighted: Bool {
        didSet {
            if oldValue != isHighlighted {
                animateInnerCircleLayer()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.addSublayer(innerCircleLayer)
        layer.addSublayer(outerRingLayer)

        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        outerRingLayer.frame = rect
        outerRingLayer.path = outerRingPath(in: rect).cgPath

        innerCircleLayer.frame = rect
        innerCircleLayer.path = innerCirclePath(in: rect).cgPath
    }

    private func animateInnerCircleLayer() {
        innerCircleLayer.add(innerCircleAnimation(), forKey: "transform")
        impactFeedbackGenerator.impactOccurred()
    }

    private func innerCircleAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        let values = [
            CATransform3DMakeScale(1.0, 1.0, 1.0),
            CATransform3DMakeScale(0.9, 0.9, 0.9)
        ]
        animation.values = isHighlighted ? values : values.reversed()
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.duration = isHighlighted ? 0.25 : 0.2
        return animation
    }

    private func outerRingPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath(ovalIn: rect)
        let innerRect = rect.scaleAndCenter(withRatio: 0.9)
        let innerPath = UIBezierPath(ovalIn: innerRect).reversing()
        path.append(innerPath)
        return path
    }

    private func innerCirclePath(in rect: CGRect) -> UIBezierPath {
        let rect = rect.scaleAndCenter(withRatio: 0.85)
        let path = UIBezierPath(ovalIn: rect)
        return path
    }

}

extension CGRect {

    /// Scale a rectangle and retain its center.
    ///
    /// - Parameter ratio: The ratio by which to scale the rectangle.
    func scaleAndCenter(withRatio ratio: CGFloat) -> CGRect {
        let scale = CGAffineTransform(scaleX: ratio, y: ratio)
        let scaledRect = applying(scale)
        let translation = CGAffineTransform(
            translationX: origin.x * (1 - ratio) + (width - scaledRect.width) / 2,
            y: origin.y * (1 - ratio) + (height - scaledRect.height) / 2
        )
        let translatedRect = scaledRect.applying(translation)
        return translatedRect
    }

}

