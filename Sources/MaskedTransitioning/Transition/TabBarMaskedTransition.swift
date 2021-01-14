//
//  TabBarMaskedTransition.swift
//  MaskedTransitioning
//
//  Created by Juan Cruz Guidi on 14/01/2021.
//  Copyright © 2020 Juan Cruz Guidi. All rights reserved.
//

import UIKit

public final class TabBarMaskedTransition: UIPercentDrivenInteractiveTransition {
    
    private var maskLayer = CAShapeLayer()
    private let animationDuration: Double = 0.5
    private var pausedTime: CFTimeInterval = 0
    private weak var storedContext: UIViewControllerContextTransitioning?
    
    var isTransitioning = false
    var initialLocation = CGPoint(x: UIScreen.main.bounds.width, y: UIScreen.main.bounds.height / 2)
    var interactive = false
    var direction: Direction = .left
    var completion: (() -> Void)?
  
    //MARK: Handle Pan Gesture
    
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: recognizer.view!.superview!)
        var progress: CGFloat = abs(translation.x / 300)
        progress = min(max(progress, 0.01), 0.99)
        
        switch recognizer.state {
        case .changed:
            initialLocation = recognizer.location(in: storedContext?.containerView)
            update(progress)
        case .cancelled, .ended:
            interactive = false
            if progress < 0.1 {
                cancel()
            } else {
                finish()
            }
        default:
            break
        }
    }
}

//MARK: - Private Methods

private extension TabBarMaskedTransition {
	func restart(forFinishing: Bool) {
		let transitionLayer = storedContext?.containerView.layer
		transitionLayer?.beginTime = CACurrentMediaTime()
		transitionLayer?.speed = forFinishing ? 1 : -1
	}
}

//MARK: - UIPercentDrivenInteractiveTransition Methods

extension TabBarMaskedTransition {
	public override func update(_ percentComplete: CGFloat) {
		super.update(percentComplete)
		maskLayer.path = MaskCreator.createPathFor(bounds: UIScreen.main.bounds,
												   centerY: initialLocation.y,
												   controlPointX: 200 * percentComplete * (1 + percentComplete),
												   reversed: direction == .right)
		let animationProgress = TimeInterval(animationDuration) * TimeInterval(percentComplete)
		storedContext?.containerView.layer.timeOffset = pausedTime + animationProgress
	}
	
	public override func cancel() {
		restart(forFinishing: false)
		super.cancel()
	}
	
	public override func finish() {
		restart(forFinishing: true)
		super.finish()
	}
}

//MARK: - UIViewControllerAnimatedTransitioning Methods

extension TabBarMaskedTransition: UIViewControllerAnimatedTransitioning {
	public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		animationDuration
	}
	
	public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		storedContext = transitionContext
		
		if interactive {
			let transitionLayer = transitionContext.containerView.layer
			pausedTime = CACurrentMediaTime()
			transitionLayer.speed = 0
			transitionLayer.timeOffset = pausedTime
		}
		
		let fromView = transitionContext.view(forKey: .from)!
		let toView = transitionContext.view(forKey: .to)!
		
		transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
		
		maskLayer.path = MaskCreator.createPathFor(bounds: fromView.bounds,
												   centerY: initialLocation.y,
												   controlPointX: 0,
												   reversed: direction == .right)
		maskLayer.strokeColor = UIColor.white.cgColor
		maskLayer.lineWidth = 1
		maskLayer.fillColor = UIColor.white.cgColor
		maskLayer.frame = fromView.frame
		
		fromView.layer.mask = maskLayer
		
		let translationX = direction == .left ? -fromView.bounds.width : fromView.bounds.width
		
		let animation = CABasicAnimation(keyPath: "transform")
		animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
		animation.toValue = NSValue(caTransform3D: CATransform3DMakeTranslation(translationX, 0.0, 0.0))
		animation.duration = animationDuration
		animation.delegate = self
		animation.fillMode = .forwards
		animation.isRemovedOnCompletion = false
		animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
		
		let pathAnimation = CABasicAnimation(keyPath: "path")
		pathAnimation.toValue = MaskCreator.createPathFor(bounds: fromView.bounds,
														  centerY: initialLocation.y,
														  controlPointX: 200,
														  reversed: direction == .right)
		pathAnimation.duration = animationDuration
		pathAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
		pathAnimation.isRemovedOnCompletion = false
		
		maskLayer.add(animation, forKey: nil)
		maskLayer.add(pathAnimation, forKey: nil)
	}
}

//MARK: - CAAnimationDelegate Methods

extension TabBarMaskedTransition: CAAnimationDelegate {
	public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		if let context = storedContext {
			context.completeTransition(!context.transitionWasCancelled)
			let fromVC = context.viewController(forKey: .from)!
			fromVC.view.layer.mask = nil
			context.containerView.layer.speed = 1
			maskLayer.removeAllAnimations()
		}
		completion?()
		isTransitioning = false
		storedContext = nil
	}
}
