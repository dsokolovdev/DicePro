//
//  Animational.swift
//  DicePro
//
//  Created by Dmitri  on 03.12.25.
//

import UIKit

final class AnimatedLabel: UILabel {

    override var text: String? {
        didSet {
            guard oldValue != text else { return }

            let newText = text
            super.text = oldValue     // temporarily revert

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

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?, duration: TimeInterval = 0.15) {
        UIView.transition(
            with: self,
            duration: duration,
            options: [.transitionCrossDissolve, .allowUserInteraction],
            animations: {
                self.image = newImage
            },
            completion: nil
        )
    }
}


extension UIView {
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
            },
            completion: nil
        )
    }
}

extension UIProgressView {
    func setAlphaAnimated(_ value: CGFloat, duration: TimeInterval = 0.25) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: {
                self.alpha = value
            },
            completion: nil
        )
    }
}
