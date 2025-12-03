//
//  Animational.swift
//  DicePro
//
//  Created by Dmitri on 03.12.25.
//

import UIKit

// MARK: - AnimatedLabel
/// UILabel subclass that animates text changes with a fade transition.
final class AnimatedLabel: UILabel {
    
    override var text: String? {
        didSet {
            guard oldValue != text else { return }
            
            let newText = text
            super.text = oldValue // temporarily revert to animate to new text
            
            UIView.transition(
                with: self,
                duration: 0.15,
                options: [.transitionCrossDissolve, .allowUserInteraction],
                animations: {
                    super.text = newText
                }
            )
        }
    }
}

// MARK: - UIImageView Animation
extension UIImageView {
    /// Smoothly transitions the image with cross-dissolve animation.
    func setImageAnimated(_ newImage: UIImage?, duration: TimeInterval = 0.15) {
        UIView.transition(
            with: self,
            duration: duration,
            options: [.transitionCrossDissolve, .allowUserInteraction],
            animations: {
                self.image = newImage
            }
        )
    }
}

// MARK: - UIView Bounce Animation
extension UIView {
    /// Applies a soft bounce animation to the view using a spring effect.
    func bounce(scale: CGFloat = 1.15, duration: TimeInterval = 0.25) {
        self.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 3,
            options: [.allowUserInteraction],
            animations: {
                self.transform = .identity
            }
        )
    }
}

// MARK: - UIProgressView Alpha Animation
extension UIProgressView {
    /// Animates the progress view's alpha value.
    func setAlphaAnimated(_ value: CGFloat, duration: TimeInterval = 0.25) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: {
                self.alpha = value
            }
        )
    }
}
