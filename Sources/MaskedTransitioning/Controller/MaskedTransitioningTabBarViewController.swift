//
//  MaskedTransitioningTabBarViewController.swift
//  MaskedTransitioning
//
//  Created by Juan Cruz Guidi on 14/01/2021.
//  Copyright © 2020 Juan Cruz Guidi. All rights reserved.
//

import UIKit

//MARK: - MaskedTransitioningTabBarViewController

open class MaskedTransitioningTabBarViewController: UITabBarController {

    private let transition = TabBarMaskedTransition()

    private var rightGesture = UIScreenEdgePanGestureRecognizer()
    private var leftGesture = UIScreenEdgePanGestureRecognizer()
    
    private var buttonNext: UIButton = {
        let rect = CGRect(x: 0, y: 0, width: 50, height: 50)
        let button = UIButton(frame: rect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.addSublayer(ArrowShape.leftArrow(in: button.bounds))
        return button
    }()
    
    private var buttonPrevious: UIButton = {
        let rect = CGRect(x: 0, y: 0, width: 50, height: 50)
        let button = UIButton(frame: rect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.addSublayer(ArrowShape.rightArrow(in: button.bounds))
        return button
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isHidden = true
        delegate = self
        configureUI()
        
        transition.completion = { [weak self] in
            guard let self = self else { return }
            self.updateButtons(for: self.selectedIndex)
        }
    }
}

//MARK: - Private Methods

private extension MaskedTransitioningTabBarViewController {
    
    func configureUI() {
        configureButtons()
        configureGestures()
        selectedIndex = 0
        updateButtons(for: selectedIndex)
    }
    
    //MARK: Gestures Configuration
    
    func configureGestures() {
        leftGesture.addTarget(self, action: #selector(leftPan))
        leftGesture.edges = .left
        view.addGestureRecognizer(leftGesture)
        
        rightGesture.edges = .right
        rightGesture.addTarget(self, action: #selector(rightPan))
        view.addGestureRecognizer(rightGesture)
    }
    
    @objc
    func rightPan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            guard !transition.isTransitioning else { return }
            transition.interactive = true
            transition.direction = .left
            transition.initialLocation = sender.location(in: view)
            if selectedIndex < viewControllers?.count ?? 0 - 1 {
                transition.isTransitioning = true
                selectedIndex += 1
            }
        default:
            transition.handlePan(sender)
        }
    }
    
    @objc
    func leftPan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            guard !transition.isTransitioning else { return }
            transition.interactive = true
            transition.direction = .right
            transition.initialLocation = sender.location(in: view)
            if selectedIndex > 0 {
                transition.isTransitioning = true
                selectedIndex -= 1
            }
        default:
            transition.handlePan(sender)
        }
    }
    
    //MARK: Buttons Configuration
    
    func configureButtons() {
        view.addSubview(buttonNext)
        buttonNext.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        buttonNext.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        buttonNext.widthAnchor.constraint(equalToConstant: 50).isActive = true
        buttonNext.heightAnchor.constraint(equalToConstant: 50).isActive = true
        buttonNext.addTarget(self, action: #selector(nextTapped(_:)), for: .touchUpInside)
        buttonNext.alpha = 0.2
        animateNextButton()
        
        view.addSubview(buttonPrevious)
        buttonPrevious.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        buttonPrevious.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        buttonPrevious.widthAnchor.constraint(equalToConstant: 50).isActive = true
        buttonPrevious.heightAnchor.constraint(equalToConstant: 50).isActive = true
        buttonPrevious.addTarget(self, action: #selector(previousTapped(_:)), for: .touchUpInside)
        buttonPrevious.alpha = 0.2
    }
    
    func animateNextButton() {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        animation.toValue = NSValue(caTransform3D: CATransform3DMakeTranslation(5, 0.0, 0.0))
        animation.duration = 0.6
        animation.autoreverses = true
        animation.repeatCount = 5
        buttonNext.layer.add(animation, forKey: nil)
    }
    
    @objc
    func nextTapped(_ sender: AnyObject) {
        guard !transition.isTransitioning else { return }
        transition.interactive = false
        transition.direction = .left
        transition.initialLocation = sender.center
        if selectedIndex < viewControllers?.count ?? 0 - 1 {
            transition.isTransitioning = true
            selectedIndex += 1
        }
    }
    
    @objc
    func previousTapped(_ sender: AnyObject) {
        guard !transition.isTransitioning else { return }
        transition.interactive = false
        transition.direction = .right
        transition.initialLocation = sender.center
        if selectedIndex > 0 {
            transition.isTransitioning = true
            selectedIndex -= 1
        }
    }
    
    //MARK: Buttons Update
    
    func updateButtons(for index: Int) {
        buttonPrevious.isHidden = index == 0
        leftGesture.isEnabled = !buttonPrevious.isHidden
        buttonNext.isHidden = index == (viewControllers?.count ?? 0) - 1
        rightGesture.isEnabled = !buttonNext.isHidden
    }
}

//MARK: - UITabBarControllerDelegate Methods

extension MaskedTransitioningTabBarViewController: UITabBarControllerDelegate {
	public func tabBarController(_ tabBarController: UITabBarController,
						  interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		guard transition.interactive else { return nil }
		return transition
	}
	
	public func tabBarController(_ tabBarController: UITabBarController,
						  animationControllerForTransitionFrom fromVC: UIViewController,
						  to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		transition
	}
}
