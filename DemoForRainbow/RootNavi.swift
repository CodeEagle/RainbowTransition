//
//  RootNavi.swift
//  LuooFM
//
//  Created by LawLincoln on 2016/9/20.
//  Copyright © 2016年 LawLincoln. All rights reserved.
//

import UIKit
// import FDFullscreenPopGesture

extension RootNavi {
    static var window: UIWindow {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let tabbar = RootTabBar()
        let navi = RootNavi(rootViewController: tabbar)
        win.rootViewController = navi
        return win
    }
}

final class RootNavi: UINavigationController {

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        //        fd_fullscreenPopGestureRecognizer.isEnabled = true
        interactivePopGestureRecognizer?.isEnabled = true
        enableRainbowTransition(with: .white, shadow: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
