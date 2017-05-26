//
//  ETNavBarTransparent.swift
//  ETNavBarTransparentDemo
//
//  Created by Bing on 2017/3/1.
//  Copyright © 2017年 tanyunbing. All rights reserved.
//

import UIKit
import KVOBlock
extension UIColor {
    // System default bar tint color
    open class var defaultNavBarTintColor: UIColor {
        return UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1.0)
    }
}

extension DispatchQueue {
    
    private static var onceTracker = [String]()
    
    public class func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if onceTracker.contains(token) {
            return
        }
        
        onceTracker.append(token)
        block()
    }
}

// MARK: - UINavigationController
extension UINavigationController {
    
    public func enableRainbowTransition(with color: UIColor = .white, shadow enable: Bool = true) {
        UINavigationController._initialize()
        let bgg = NavigationBarrOverlay(frame: .zero)
        let barBackgroundView = navigationBar.subviews[0]
        let valueForKey = barBackgroundView.value(forKey:)
        var parenet: UIView = barBackgroundView
        if navigationBar.isTranslucent {
            if #available(iOS 10.0, *) {
                if let backgroundEffectView = valueForKey("_backgroundEffectView") as? UIView, navigationBar.backgroundImage(for: .default) == nil {
                    parenet = backgroundEffectView
                }
                
            } else {
                if let adaptiveBackdrop = valueForKey("_adaptiveBackdrop") as? UIView , let backdropEffectView = adaptiveBackdrop.value(forKey: "_backdropEffectView") as? UIView {
                    parenet = backdropEffectView
                    return
                }
            }
        }
        parenet.addSubview(bgg)
        parenet.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bgg]-0-|", options: NSLayoutFormatOptions.alignAllTop, metrics: nil, views: ["bgg": bgg]))
        parenet.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bgg]-0-|", options: NSLayoutFormatOptions.directionLeftToRight, metrics: nil, views: ["bgg": bgg]))
        bgg.tag = 9854
        bgg.backgroundColor = color
        bgg.shadowParent = barBackgroundView.layer
        bgg.enableShadow(enable: enable)
    }
    
    fileprivate var lo_bg: NavigationBarrOverlay? {
        get {
            let barBackgroundView = navigationBar.subviews[0]
            let valueForKey = barBackgroundView.value(forKey:)
            var parenet = barBackgroundView
            if navigationBar.isTranslucent {
                if #available(iOS 10.0, *) {
                    if let backgroundEffectView = valueForKey("_backgroundEffectView") as? UIView, navigationBar.backgroundImage(for: .default) == nil {
                        parenet = backgroundEffectView
                    }
                    
                } else {
                    if let adaptiveBackdrop = valueForKey("_adaptiveBackdrop") as? UIView , let backdropEffectView = adaptiveBackdrop.value(forKey: "_backdropEffectView") as? UIView {
                        parenet = backdropEffectView
                    }
                }
            }
            return parenet.viewWithTag(9854) as? NavigationBarrOverlay
        }
    }
    
    public func enableShadow(enable: Bool = true) {
        lo_bg?.enableShadow(enable: enable)
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
    
    private static let onceToken = UUID().uuidString
    
    internal static func _initialize() {
      guard self == UINavigationController.self else { return }
      
      DispatchQueue.once(token: onceToken) {
        let needSwizzleSelectorArr = [
          NSSelectorFromString("_updateInteractiveTransition:"),
          #selector(popToViewController),
          #selector(popToRootViewController)
        ]
        
        for selector in needSwizzleSelectorArr {
          
          let str = ("et_" + selector.description).replacingOccurrences(of: "__", with: "_")
          // popToRootViewControllerAnimated: et_popToRootViewControllerAnimated:
          
          let originalMethod = class_getInstanceMethod(self, selector)
          let swizzledMethod = class_getInstanceMethod(self, Selector(str))
          method_exchangeImplementations(originalMethod, swizzledMethod)
        }
      }
    }
  
    func et_updateInteractiveTransition(_ percentComplete: CGFloat) {
        guard let topViewController = topViewController, let coordinator = topViewController.transitionCoordinator else {
            et_updateInteractiveTransition(percentComplete)
            return
        }
        
        let fromViewController = coordinator.viewController(forKey: .from)
        let toViewController = coordinator.viewController(forKey: .to)
        
        // Bg Alpha
        let fromAlpha = fromViewController?.navBarBgAlpha ?? 0
        let toAlpha = toViewController?.navBarBgAlpha ?? 0
        let newAlpha = fromAlpha + (toAlpha - fromAlpha) * percentComplete
        setNeedsNavigationBackground(alpha: newAlpha)
        enableShadow(enable: toViewController?.navBarBgShadow ?? false)
        
        // Tint Color
        let fromColor = fromViewController?.navBarTintColor ?? .blue
        let toColor = toViewController?.navBarTintColor ?? .blue
        let newColor = averageColor(fromColor: fromColor, toColor: toColor, percent: percentComplete)
        navigationBar.tintColor = newColor
        let midColor = averageColor(fromColor: (fromViewController?.navBarBGColor ?? .white), toColor: (toViewController?.navBarBGColor ?? .white), percent: percentComplete)
        lo_bg?.update(color: midColor.withAlphaComponent(toAlpha), drag: false)
        et_updateInteractiveTransition(percentComplete)
    }
    
    // Calculate the middle Color with translation percent
    private func averageColor(fromColor: UIColor, toColor: UIColor, percent: CGFloat) -> UIColor {
        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        var fromAlpha: CGFloat = 0
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        
        var toRed: CGFloat = 0
        var toGreen: CGFloat = 0
        var toBlue: CGFloat = 0
        var toAlpha: CGFloat = 0
        toColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        
        let nowRed = fromRed + (toRed - fromRed) * percent
        let nowGreen = fromGreen + (toGreen - fromGreen) * percent
        let nowBlue = fromBlue + (toBlue - fromBlue) * percent
        let nowAlpha = fromAlpha + (toAlpha - fromAlpha) * percent
        
        return UIColor(red: nowRed, green: nowGreen, blue: nowBlue, alpha: nowAlpha)
    }
    
    func et_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        setNeedsNavigationBackground(alpha: viewController.navBarBgAlpha)
        let color = viewController.navBarBGColor
        lo_bg?.update(color: color.withAlphaComponent(viewController.navBarBgAlpha), drag: lo_poping)
        navigationBar.tintColor = viewController.navBarTintColor
        return et_popToViewController(viewController, animated: animated)
    }
    
    func et_popToRootViewControllerAnimated(_ animated: Bool) -> [UIViewController]? {
        let alpha = viewControllers.first?.navBarBgAlpha ?? 0
        setNeedsNavigationBackground(alpha: alpha)
        let color = viewControllers.first?.navBarBGColor ?? .white
        lo_bg?.update(color: color.withAlphaComponent(alpha), drag: lo_poping)
        navigationBar.tintColor = viewControllers.first?.navBarTintColor
        return et_popToRootViewControllerAnimated(animated)
    }
    
    fileprivate func setNeedsNavigationBackground(alpha: CGFloat) {
        let barBackgroundView = navigationBar.subviews[0]
        let valueForKey = barBackgroundView.value(forKey:)
        if let shadowView = valueForKey("_shadowView") as? UIView {
            shadowView.alpha = alpha
        }
        let color = topViewController?.navBarBGColor ?? .white
        lo_bg?.update(color: color.withAlphaComponent(alpha), drag: lo_poping)
        if navigationBar.isTranslucent {
            if #available(iOS 10.0, *) {
                if let backgroundEffectView = valueForKey("_backgroundEffectView") as? UIView, navigationBar.backgroundImage(for: .default) == nil {
                    backgroundEffectView.alpha = alpha
                    return
                }
                
            } else {
                if let adaptiveBackdrop = valueForKey("_adaptiveBackdrop") as? UIView , let backdropEffectView = adaptiveBackdrop.value(forKey: "_backdropEffectView") as? UIView {
                    backdropEffectView.alpha = alpha
                    return
                }
            }
        }
        barBackgroundView.alpha = alpha
    }
}

// MARK: - UINavigationBarDelegate
extension UINavigationController: UINavigationBarDelegate {
    
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if let topVC = topViewController, let coor = topVC.transitionCoordinator, coor.initiallyInteractive {
            if #available(iOS 10.0, *) {
                coor.notifyWhenInteractionChanges({ (context) in
                    self.dealInteractionChanges(context)
                })
            } else {
                coor.notifyWhenInteractionEnds({ (context) in
                    self.dealInteractionChanges(context)
                })
            }
            return true
        }
        
        let itemCount = navigationBar.items?.count ?? 0
        let n = viewControllers.count >= itemCount ? 2 : 1
        let popToVC = viewControllers[viewControllers.count - n]
        enableShadow(enable: popToVC.navBarBgShadow)
        lo_bg?.update(color: popToVC.navBarBGColor, drag: false)
        popToViewController(popToVC, animated: true)
        return true
    }
    
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPush item: UINavigationItem) -> Bool {
        setNeedsNavigationBackground(alpha: topViewController?.navBarBgAlpha ?? 0)
        enableShadow(enable: topViewController?.navBarBgShadow ?? false)
        lo_bg?.update(color: (topViewController?.navBarBGColor ?? .white).withAlphaComponent(topViewController?.navBarBgAlpha ?? 1), drag: false)
        navigationBar.tintColor = topViewController?.navBarTintColor
        return true
    }
    
    private func dealInteractionChanges(_ context: UIViewControllerTransitionCoordinatorContext) {
        let animations: (UITransitionContextViewControllerKey) -> () = {
            let nowAlpha = context.viewController(forKey: $0)?.navBarBgAlpha ?? 0
            self.setNeedsNavigationBackground(alpha: nowAlpha)
            self.navigationBar.tintColor = context.viewController(forKey: $0)?.navBarTintColor
        }
        
        if context.isCancelled {
            let cancelDuration: TimeInterval = context.transitionDuration * Double(context.percentComplete)
            let vc = context.viewController(forKey: .to)
            vc?.lo_poping = true
            let shadow = context.viewController(forKey: .from)?.navBarBgShadow ?? false
            enableShadow(enable: shadow)
            lo_bg?.update(color: (topViewController?.navBarBGColor ?? .white).withAlphaComponent(topViewController?.navBarBgAlpha ?? 1), drag: false)
            UIView.animate(withDuration: cancelDuration, animations: { 
                animations(.from)
            }, completion: { (b) in
                vc?.lo_poping = false
            })
        } else {
            let finishDuration: TimeInterval = context.transitionDuration * Double(1 - context.percentComplete)
            UIView.animate(withDuration: finishDuration) {
                animations(.to)
            }
        }
    }
}
// MARK: - UIViewController extension
extension UIViewController {
    
    fileprivate struct AssociatedKeys {
        static var navBarBgShadow: String = "navBarBgShadow"
        static var navBarBgAlpha: CGFloat = 1.0
        static var navBarTintColor: UIColor = UIColor.defaultNavBarTintColor
        static var navBarBGColor: UIColor = UIColor.white
        static var bg = "bg"
        static var poping = "poping"
        static let keyPath = "contentOffset"
        static var scrollView = "_RKeys_.scrollView"
    }
    
    public var navBarBgShadow: Bool {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.navBarBgShadow) as? Bool else {
                return false
            }
            return value
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.navBarBgShadow, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            navigationController?.lo_bg?.enableShadow(enable: newValue)
        }
    }
    
    public var navBarBgAlpha: CGFloat {
        get {
            guard let alpha = objc_getAssociatedObject(self, &AssociatedKeys.navBarBgAlpha) as? CGFloat else {
                return 1.0
            }
            return alpha
        }
        set {
            let alpha = max(min(newValue, 1), 0) // 必须在 0~1的范围
            objc_setAssociatedObject(self, &AssociatedKeys.navBarBgAlpha, alpha, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            navigationController?.setNeedsNavigationBackground(alpha: alpha)
        }
    }
    
    public var navBarTintColor: UIColor {
        get {
            guard let tintColor = objc_getAssociatedObject(self, &AssociatedKeys.navBarTintColor) as? UIColor else {
                return UIColor.defaultNavBarTintColor
            }
            return tintColor
        }
        set {
            navigationController?.navigationBar.tintColor = newValue
            objc_setAssociatedObject(self, &AssociatedKeys.navBarTintColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var navBarBGColor: UIColor {
        get {
            guard let tintColor = objc_getAssociatedObject(self, &AssociatedKeys.navBarBGColor) as? UIColor else {
                return UIColor.white
            }
            return tintColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.navBarBGColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var lo_poping: Bool {
        get { return (objc_getAssociatedObject(self, &AssociatedKeys.poping) as? Bool) ?? false }
        set { objc_setAssociatedObject(self, &AssociatedKeys.poping, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    private var lo_ob: Bool {
        get { return (objc_getAssociatedObject(self, &AssociatedKeys.scrollView) as? Bool) ?? false }
        set { objc_setAssociatedObject(self, &AssociatedKeys.scrollView, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    public func transparent(with scroll: UIScrollView?, total distance: CGFloat = 200, force: Bool = false) {
        guard let value = scroll else { return }
        if force == false, lo_ob == true {
            return
        }
        lo_ob = true
        value.observeKeyPath(AssociatedKeys.keyPath, with: {[weak self]
            target, oldValue, newValue in
            guard let navi = self?.navigationController, navi.topViewController == self, self?.lo_poping == false else { return }
            guard let v = newValue as? CGPoint, let o = oldValue as? CGPoint else { return }
            if v == o, v == .zero { return }
            var a = v.y / distance
            if a < 0 { a = 0 }
            if a > 1 { a = 1 }
            self?.navBarBgAlpha = a
            self?.setNeedsStatusBarAppearanceUpdate()
        })
    }
}
// MARK: - NavigationBarrOverlay
private final class NavigationBarrOverlay: UIView {
    weak var shadowParent: CALayer?
    
    lazy var shadowMask: CAGradientLayer = {
        let gMask = CAGradientLayer()
        gMask.colors = [UIColor(white: 0, alpha: 0.4).cgColor, UIColor.clear.cgColor]
        gMask.locations = [0, 1]
        gMask.anchorPoint = CGPoint.zero
        gMask.startPoint = CGPoint(x: 0.5, y: 0)
        gMask.endPoint = CGPoint(x: 0.5, y: 1)
        gMask.opacity = 0
        return gMask
    }()
    
    fileprivate func enableShadow(enable: Bool = true) {
        if enable {
            if shadowMask.superlayer != layer {
                shadowParent?.addSublayer(shadowMask)
            }
        } else {
            shadowMask.removeFromSuperlayer()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        shadowParent?.addSublayer(shadowMask)
    }
    
    fileprivate override func layoutSubviews() {
        super.layoutSubviews()
        shadowMask.frame = bounds
    }
    
    fileprivate func update(color value: UIColor, drag: Bool) {
        let alpha = Float(value.cgColor.alpha)
        if drag { shadowMask.opacity = 1 - alpha }
        else {
            if alpha != 0 { shadowMask.opacity = 0 }
            else if shadowMask.opacity != 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {[weak self] in
                    self?.shadowMask.opacity = 1
                })
            }
        }
        backgroundColor = value
    }
}
