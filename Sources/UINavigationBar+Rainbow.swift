//
//  UINavigationBar+Rainbow.swift
//  Pods
//
//  Created by Danis on 15/11/25.
//
//

import UIKit
import KVOBlock
private struct _RKeys_ {
    static var rainbow = "_RKeys_.rainbow"
    static var scrollView = "_RKeys_.scrollView"
    static var kBackgroundViewKey = "_RKeys_.kBackgroundViewKey"
    static var kStatusBarMaskKey = "_RKeys_.kStatusBarMaskKey"
    static var transitioning = "_RKeys_.transitioning"
    static var alphaColor = "_RKeys_.alphaColor"
    static let keyPath = "contentOffset"
    static var statusBarResponder = "_RKeys_.statusBarResponder"
}

extension UINavigationController {

    public func enableRainbowTransition(with color: UIColor = .white, shadow enable: Bool = true) {
        let rain = RainbowNavigation()
        rain.wireTo(navigationController: self)
        rain.transitioning = {
            [weak self] b in
            self?.navigationBar.transcationing = b
        }
        navigationBar.df_setBackgroundColor(color)
        navigationBar.backgroundView?.enableShadow(enable: enable)
        rainbow = rain
    }

    private var rainbow: RainbowNavigation? {
        get { return objc_getAssociatedObject(self, &_RKeys_.rainbow) as? RainbowNavigation }
        set { objc_setAssociatedObject(self, &_RKeys_.rainbow, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    public func disableDrag(in vc: UIViewController.Type) {
        guard var copy = rainbow?.disableDragViewControllers else { return }
        if let index = copy.index(where: { (t) -> Bool in return vc == t }) {
            copy.remove(at: index)
        }
        copy.append(vc)
        rainbow?.disableDragViewControllers = copy
    }
}

private class Wrapper { fileprivate weak var vc: UIViewController? }
extension UIScrollView {
    
    public var statusBarResponder: UIViewController? {
        get { return (objc_getAssociatedObject(self, &_RKeys_.statusBarResponder) as? Wrapper)?.vc }
        set {
            var wrapper = objc_getAssociatedObject(self, &_RKeys_.statusBarResponder) as? Wrapper
            if wrapper == nil { wrapper = Wrapper() }
            wrapper?.vc = newValue
            objc_setAssociatedObject(self, &_RKeys_.statusBarResponder, wrapper, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public var alphaColor: UIColor {
        get { return objc_getAssociatedObject(self, &_RKeys_.alphaColor) as? UIColor ?? UIColor.white.withAlphaComponent(0) }
        set { objc_setAssociatedObject(self, &_RKeys_.alphaColor, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    public func updateColor(with alpha: CGFloat) {
        alphaColor = alphaColor.withAlphaComponent(alpha)
        statusBarResponder?.setNeedsStatusBarAppearanceUpdate()
    }
}


private final class NavigationBarrOverlay: UIView {
    
    private lazy var seperator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.lightGray.cgColor
        return layer
    }()
    
    private lazy var shadowMask: CAGradientLayer = {
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
                layer.addSublayer(shadowMask)
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
        layer.addSublayer(seperator)
        layer.addSublayer(shadowMask)
    }
    
    fileprivate override func layoutSubviews() {
        super.layoutSubviews()
        seperator.frame = CGRect(x: 0, y: bounds.height - 0.5, width: bounds.width, height: 0.5)
        shadowMask.frame = bounds
    }
    
    fileprivate func update(color value: UIColor, drag: Bool) {
        let alpha = Float(value.cgColor.alpha)
        seperator.opacity = alpha
        if drag { shadowMask.opacity = 1 - alpha }
        else {
            shadowMask.opacity = 0
            if alpha == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {[weak self] in
                    self?.shadowMask.opacity = 1
                })
            }
        }
        backgroundColor = value
    }
}

extension UINavigationBar {
    
    public func df_setBackgroundColor(_ color: UIColor, drag: Bool = false) {
        if backgroundView == nil {
            setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            shadowImage = UIImage()
            let bgg = NavigationBarrOverlay(frame: .zero)
            if let bg = value(forKey: "_backgroundView") as? UIView {
                bg.insertSubview(bgg, at: 0)
                bg.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bgg]-0-|", options: NSLayoutFormatOptions.alignAllTop, metrics: nil, views: ["bgg": bgg]))
                bg.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bgg]-0-|", options: NSLayoutFormatOptions.directionLeftToRight, metrics: nil, views: ["bgg": bgg]))
            }
            backgroundView = bgg
        }
        backgroundView?.update(color: color, drag: drag)
    }

    public func df_reset() {
        setBackgroundImage(nil, for: .default)
        shadowImage = nil
        backgroundView?.removeFromSuperview()
        backgroundView = nil
    }
    
    public func shadow(enable: Bool) { backgroundView?.enableShadow(enable: enable) }

    // MARK: Properties
    var transcationing: Bool {
        get { return objc_getAssociatedObject(self, &_RKeys_.transitioning) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &_RKeys_.transitioning, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    fileprivate var backgroundView: NavigationBarrOverlay? {
        get { return objc_getAssociatedObject(self, &_RKeys_.kBackgroundViewKey) as? NavigationBarrOverlay }
        set { objc_setAssociatedObject(self, &_RKeys_.kBackgroundViewKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    private var scrollView: UIScrollView? {
        get { return objc_getAssociatedObject(self, &_RKeys_.scrollView) as? UIScrollView }
        set { objc_setAssociatedObject(self, &_RKeys_.scrollView, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    public func transparent(with scroll: UIScrollView?, total distance: CGFloat = 200) {
        guard let value = scroll else { return }
        scrollView?.removeObserver(for: _RKeys_.keyPath)
        scrollView = value
        transcationing = false
        value.observeKeyPath(_RKeys_.keyPath, with: {[weak self]
            target, newValue, oldValue in
            guard let v = newValue as? CGPoint, let o = oldValue as? CGPoint, let sself = self, sself.transcationing == false, let t = target as? UIScrollView, t == sself.scrollView else { return }
            if v == o, v == .zero { return }
            var a = v.y / distance
            if a < 0 { a = 0 }
            if a > 1 { a = 1 }
            let color = UIColor.white.withAlphaComponent(a)
            self?.df_setBackgroundColor(color, drag: true)
            t.updateColor(with: a)
        })
    }
}
