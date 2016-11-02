//
//  LLRainbowNavigationDelegate.swift
//  Pods
//
//  Created by Danis on 15/11/25.
//
//
import UIKit
// MARK: - RainbowColorSource
@objc public protocol RainbowColorSource {
    @objc optional func navigationBarInColor() -> UIColor
    @objc optional func navigationBarOutColor() -> UIColor
}

// MARK: - RainbowNavigation
final class RainbowNavigation: NSObject, UINavigationControllerDelegate {

    fileprivate weak var navigationController: UINavigationController?

    fileprivate lazy var pushAnimator = RainbowPushAnimator()
    fileprivate lazy var popAnimator = RainbowPopAnimator()
    fileprivate lazy var dragPop = RainbowDragPop()
    
    var transitioning: ((Bool) -> ())?

    override public init() {
        super.init()
        dragPop.popAnimator = popAnimator
        dragPop.transitioning = { [weak self] b in self?.transitioning?(b) }
    }

    func wireTo(navigationController nc: UINavigationController) {
        navigationController = nc
        dragPop.navigationController = nc
        navigationController?.delegate = self
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitioning?(true)
        if operation == .push { return pushAnimator }
        return popAnimator
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dragPop.interacting ? dragPop : nil
    }

}
