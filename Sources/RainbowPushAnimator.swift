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
        
        let nextColor = toColorSource?.navigationBarInColor?() ?? fromColorSource?.navigationBarOutColor?()

        let containerView = transitionContext.containerView
        
        containerView.addSubview(toVC.view)
        
        // Layout
        let originFromFrame = fromVC.view.frame
        let finalToFrame = transitionContext.finalFrame(for: toVC)
        toVC.view.frame = finalToFrame.offsetBy(dx: finalToFrame.width, dy: 0)
        
        let duration = transitionDuration(using: transitionContext)
        let animation: () -> () = {
            toVC.view.frame = finalToFrame
            let finalFromframe = originFromFrame.offsetBy(dx: -originFromFrame.width, dy: 0)
            fromVC.view.frame = finalFromframe
            
            guard let navigationColor = nextColor else { return }
            fromVC.navigationController?.navigationBar.df_setBackgroundColor(navigationColor)
        }
        let finish: (Bool) -> () = { _ in
            fromVC.view.frame = originFromFrame
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: animation, completion: finish)
    }
}
