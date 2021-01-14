//
//  ViewController.swift
//  UsageExample
//
//  Created by Juan Cruz Guidi on 14/01/2021.
//

import UIKit
import MaskedTransitioning

final class ViewController: UIViewController {
	
	let transition = TabBarMaskedTransition()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationController?.delegate = self
	}
}

extension ViewController: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController,
							  animationControllerFor operation: UINavigationController.Operation,
							  from fromVC: UIViewController,
							  to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return transition
	}
}
