//
//  RootTabBar.swift
//  LuooFM
//
//  Created by LawLincoln on 2016/9/20.
//  Copyright © 2016年 LawLincoln. All rights reserved.
//

import UIKit
#if !PACKING_FOR_APPSTORE
    import RainbowTransition
#endif

final class RootTabBar: UITabBarController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        initialize()
    }

    private func initialize() {
        let empty = UIViewController(nibName: nil, bundle: nil)
        empty.view.backgroundColor = UIColor.white
        empty.navigationItem.leftBarButtonItem = nil
        empty.navigationItem.title = "haha empty"
        empty.title = "haha empty"
        viewControllers = [ViewController(nibName: nil, bundle: nil) , empty]
        selectedIndex = 0
        DispatchQueue.global().async {
            var needSet = true
            while needSet {
                guard self.navigationController == nil else { return }
                needSet = false
                DispatchQueue.main.async { self.updateNaviBar() }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var selectedViewController: UIViewController? {
        get { return super.selectedViewController }
        set {
            updateNaviBar(with: newValue)
            super.selectedViewController = newValue
        }
    }
    
    private func updateNaviBar(with vc: UIViewController? = nil) {
        let view = vc ?? selectedViewController
        let item = view?.navigationItem
        let topItem = navigationController?.navigationBar.topItem
        topItem?.leftBarButtonItems = item?.leftBarButtonItems
        topItem?.rightBarButtonItems = item?.rightBarButtonItems
        topItem?.titleView = item?.titleView
        topItem?.title = item?.title
    }
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
    */
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return selectedViewController?.preferredStatusBarStyle ?? .default
    }
}
extension RootTabBar: RainbowColorSource {
    func navigationBarInColor() -> UIColor {
        return .clear
    }
}
