////
////  UINavigationBar+Rainbow.swift
////  Pods
////
////  Created by Danis on 15/11/25.
////
////
//
//import UIKit
//import KVOBlock
//private struct _RKeys_ {
//    static var rainbow = "_RKeys_.rainbow"
//    static var scrollView = "_RKeys_.scrollView"
//    static var kBackgroundViewKey = "_RKeys_.kBackgroundViewKey"
//    static var kStatusBarMaskKey = "_RKeys_.kStatusBarMaskKey"
//    static var transitioning = "_RKeys_.transitioning"
//    static var alphaColor = "_RKeys_.alphaColor"
//    static let keyPath = "contentOffset"
//    static var statusBarResponder = "_RKeys_.statusBarResponder"
//}
//
//extension UINavigationController {
//
////    public func enableRainbowTransition(with color: UIColor = .white, shadow enable: Bool = true) {
//////        let rain = RainbowNavigation()
//////        rain.wireTo(navigationController: self)
//////        rain.transitioning = {
//////            [weak self] b in
//////            self?.navigationBar.transcationing = b
//////        }
//////        navigationBar.df_setBackgroundColor(color)
//////        navigationBar.backgroundView?.enableShadow(enable: enable)
//////        rainbow = rain
////        UINavigationController._initialize()
////    }
//
//    private var rainbow: RainbowNavigation? {
//        get { return objc_getAssociatedObject(self, &_RKeys_.rainbow) as? RainbowNavigation }
//        set { objc_setAssociatedObject(self, &_RKeys_.rainbow, newValue, .OBJC_ASSOCIATION_RETAIN) }
//    }
//    
//    public func disableDrag(in vc: UIViewController.Type) {
//        guard var copy = rainbow?.disableDragViewControllers else { return }
//        if let index = copy.index(where: { (t) -> Bool in return vc == t }) {
//            copy.remove(at: index)
//        }
//        copy.append(vc)
//        rainbow?.disableDragViewControllers = copy
//    }
//}
//
//private class Wrapper { fileprivate weak var vc: UIViewController? }
//extension UIScrollView {
//    
//    public var statusBarResponder: UIViewController? {
//        get { return (objc_getAssociatedObject(self, &_RKeys_.statusBarResponder) as? Wrapper)?.vc }
//        set {
//            var wrapper = objc_getAssociatedObject(self, &_RKeys_.statusBarResponder) as? Wrapper
//            if wrapper == nil { wrapper = Wrapper() }
//            wrapper?.vc = newValue
//            objc_setAssociatedObject(self, &_RKeys_.statusBarResponder, wrapper, .OBJC_ASSOCIATION_RETAIN)
//        }
//    }
//    
//    public func updateColor(with alpha: CGFloat) {
//        statusBarResponder?.navBarBgAlpha = alpha
//        statusBarResponder?.setNeedsStatusBarAppearanceUpdate()
//    }
//}
//
//
//
//
//extension UINavigationBar {
//    
//    public func df_setBackgroundColor(_ color: UIColor, drag: Bool = false) {
//        if backgroundView == nil {
//            setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//            shadowImage = UIImage()
//            let bgg = NavigationBarrOverlay(frame: .zero)
//            if let bg = value(forKey: "_backgroundView") as? UIView {
//                bg.insertSubview(bgg, at: 0)
//                bg.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bgg]-0-|", options: NSLayoutFormatOptions.alignAllTop, metrics: nil, views: ["bgg": bgg]))
//                bg.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bgg]-0-|", options: NSLayoutFormatOptions.directionLeftToRight, metrics: nil, views: ["bgg": bgg]))
//            }
//            backgroundView = bgg
//        }
//        backgroundView?.update(color: color, drag: drag)
//    }
//
//    public func df_reset() {
//        setBackgroundImage(nil, for: .default)
//        shadowImage = nil
//        backgroundView?.removeFromSuperview()
//        backgroundView = nil
//    }
//    
//    public func shadow(enable: Bool) { backgroundView?.enableShadow(enable: enable) }
//
//    // MARK: Properties
//    var transcationing: Bool {
//        get { return objc_getAssociatedObject(self, &_RKeys_.transitioning) as? Bool ?? false }
//        set { objc_setAssociatedObject(self, &_RKeys_.transitioning, newValue, .OBJC_ASSOCIATION_RETAIN) }
//    }
//    
//    fileprivate var backgroundView: NavigationBarrOverlay? {
//        get { return objc_getAssociatedObject(self, &_RKeys_.kBackgroundViewKey) as? NavigationBarrOverlay }
//        set { objc_setAssociatedObject(self, &_RKeys_.kBackgroundViewKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
//    }
//    
//    
//}
