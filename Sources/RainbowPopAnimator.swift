//
//  LLRainbowPopAnimator.swift
//  Pods
//
//  Created by Danis on 15/11/25.
//
//
import UIKit
final class RainbowPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private(set) lazy var animating = false
    weak var navi: UINavigationController?
    var fromColor: UIColor?
    var toColor: UIColor?
    
    func cancel() {
        guard let navigationColor = fromColor else { return }
        navi?.navigationBar.df_setBackgroundColor(navigationColor)
    }
    
    func finish() {
        guard let navigationColor = toColor else { return }
        navi?.navigationBar.df_setBackgroundColor(navigationColor)
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let fromColorSource = fromVC as? RainbowColorSource
        let toColorSource = toVC as? RainbowColorSource
        
        toColor = toColorSource?.navigationBarInColor?() ?? fromColorSource?.navigationBarOutColor?()
        fromColor = fromColorSource?.navigationBarInColor?()
        let nextColor = toColor
        let containerView = transitionContext.containerView
        
        let finalToFrame = transitionContext.finalFrame(for: toVC)
        toVC.view.frame = finalToFrame.offsetBy(dx: -finalToFrame.width, dy: 0)
        
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        let duration = transitionDuration(using: transitionContext)
        
        animating = true
        navi = fromVC.navigationController
        let animation: () -> () = {
            fromVC.view.frame = fromVC.view.frame.offsetBy(dx: fromVC.view.frame.width, dy: 0)
            toVC.view.frame = finalToFrame
            if let navigationColor = nextColor {
                fromVC.navigationController?.navigationBar.df_setBackgroundColor(navigationColor)
            }
        }
        let finish: (Bool) -> () = {[weak self]
            _ in
            self?.animating = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: animation, completion:finish)
    }
}
