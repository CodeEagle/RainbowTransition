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
    
    var disableDragViewControllers: [UIViewController.Type]  {
        get { return dragPop.disableDragViewControllers }
        set {  dragPop.disableDragViewControllers = newValue }
    }

    private weak var navigationController: UINavigationController?
    
    private lazy var pushAnimator = RainbowPushAnimator()
    private lazy var popAnimator = RainbowPopAnimator()
    private lazy var dragPop = RainbowDragPop()
    private lazy var poping = false
    
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
        poping = false
        if operation == .push { return pushAnimator }
        poping = true
        return popAnimator
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dragPop.interacting ? dragPop : nil
    }

}
