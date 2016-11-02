//
//  LLRainbowPushAnimator.swift
//  Pods
//
//  Created by Danis on 15/11/25.
//
//
import UIKit

final class RainbowPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let fromColorSource = fromVC as? RainbowColorSource
        let toColorSource = toVC as? RainbowColorSource
        
        var nextColor: UIColor?
        nextColor = fromColorSource?.navigationBarOutColor?()
        nextColor = toColorSource?.navigationBarInColor?()

        let containerView = transitionContext.containerView
        let shadowMask = UIView(frame: containerView.bounds)
        shadowMask.backgroundColor = UIColor.black
        shadowMask.alpha = 0
        containerView.addSubview(shadowMask)
        containerView.addSubview(toVC.view)
        
        // Layout
        let originFromFrame = fromVC.view.frame
        let finalToFrame = transitionContext.finalFrame(for: toVC)
        toVC.view.frame = finalToFrame.offsetBy(dx: finalToFrame.width, dy: 0)
        
        let duration = transitionDuration(using: transitionContext)
        let animation: () -> () = {
            toVC.view.frame = finalToFrame
            let finalFromframe = originFromFrame.offsetBy(dx: -originFromFrame.width / 2, dy: 0)
            fromVC.view.frame = finalFromframe
            shadowMask.alpha = 0.3
            guard let navigationColor = nextColor else { return }
            fromVC.navigationController?.navigationBar.df_setBackgroundColor(navigationColor)
        }
        let finish: (Bool) -> () = { _ in
            fromVC.view.frame = originFromFrame
            shadowMask.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: animation, completion: finish)
    }
}
