//
//  LLRainbowDragPop.swift
//  Pods
//
//  Created by Danis on 15/11/25.
//
//
import UIKit
import KVOBlock
final class RainbowDragPop: UIPercentDrivenInteractiveTransition {

    var disableDragViewControllers: [UIViewController.Type] = [] {
        didSet {
            let gestureDisable =  disableDragViewControllers.contains(where: { (t) -> Bool in
                guard let value = navigationController?.topViewController else { return false }
                return type(of: value) == t
            })
            panGesture.isEnabled = !gestureDisable
        }
    }
    
    private(set) var interacting = false
    var transitioning: ((Bool) -> ())?
    
    private var start = false
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(RainbowDragPop.handlePan(_:)))
    weak var navigationController: UINavigationController! {
        didSet {
            navigationController?.view.addGestureRecognizer(panGesture)
        }
    }
    
    weak var popAnimator: RainbowPopAnimator!

    override var completionSpeed: CGFloat {
        get { return max(CGFloat(0.5), 1 - self.percentComplete) }
        set { self.completionSpeed = newValue }
    }

    @objc private func handlePan(_ panGesture: UIPanGestureRecognizer) {
        let offset = panGesture.translation(in: panGesture.view)
        let velocity = panGesture.velocity(in: panGesture.view)
        if velocity.x <= 0 && offset.x <= 0 { return }
        switch panGesture.state {
        case .began:
            start = true
            if !popAnimator.animating {
                interacting = true
                if velocity.x > 0, self.navigationController.viewControllers.count > 0 {
                    transitioning?(true)
                    navigationController.popViewController(animated: true)
                }
            }
        case .changed:
            transitioning?(true)
            if interacting {
                var progress = offset.x / panGesture.view!.bounds.width
                progress = max(progress, 0)
                update(progress)
            }
        case .ended:
            if start == false { return }
            transitioning?(false)
            start = false
            if interacting {
                let canFinish = (offset.x / panGesture.view!.bounds.width) > 0.5
                let slieToEnd = panGesture.velocity(in: panGesture.view!).x > 0
                if canFinish || slieToEnd {
                    popAnimator.finish()
                    finish()
                } else {
                    popAnimator.cancel()
                    cancel()
                }
                interacting = false
            }
        case .cancelled:
            if interacting {
                popAnimator.cancel()
                cancel()
                interacting = false
            }
            start = false
            transitioning?(false)
        default:
            break
        }
    }

}
