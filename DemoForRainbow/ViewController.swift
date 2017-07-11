//
//  ViewController.swift
//  SD
//
//  Created by LawLincoln on 2016/11/1.
//  Copyright © 2016年 LawLincoln. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let v = UIView(frame: UIScreen.main.bounds)
        v.backgroundColor = .white
        view.addSubview(v)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(ViewController.p))
        navBarBgAlpha = 0
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        navigationController?.disableDrag(in: type(of: self))
    }

    @IBAction func p() {
        let vc = TBViewController(nibName: nil, bundle: nil)
        show(vc, sender: nil)
    }
}

class TBViewController: UIViewController {

    private lazy var tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)

    private lazy var collectionview: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 300)
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300), collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.alwaysBounceHorizontal = true
        cv.isPagingEnabled = true
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        //        navigationController?.navigationBar.shadow(enable: true)
        view.backgroundColor = .white
        automaticallyAdjustsScrollViewInsets = false
        collectionview.backgroundColor = .green
        tableView.tableHeaderView = collectionview
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        navBarTintColor = .blue
        navBarBgAlpha = 0
        navBarBgShadow = true
        navBarBGColor = .green
        transparent(with: tableView)
        // fd_interactivePopDisabled = true
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //        navigationController?.disableDrag(in: TBViewController.self)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return navBarBgAlpha > 0.6 ? .default : .lightContent
    }
}

extension TBViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.orange
        return cell
    }
}

extension TBViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 30
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = "\(indexPath.row)"
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = DTBViewController(nibName: nil, bundle: nil)
        show(vc, sender: nil)
    }

    func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        return true
    }

    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }

    func tableView(_: UITableView, commit _: UITableViewCellEditingStyle, forRowAt _: IndexPath) {
    }
}

class DTBViewController: UIViewController {

    private lazy var tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.backgroundColor = .white
        automaticallyAdjustsScrollViewInsets = false
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 300))
        v.backgroundColor = .blue
        tableView.tableHeaderView = v
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        navBarBgAlpha = 0
        navBarTintColor = .orange
        navBarBgShadow = false
        transparent(with: tableView)
        // fd_interactivePopDisabled = true
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension DTBViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 30
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = "\(indexPath.row)"
        return cell!
    }
}

class TTTViewController: UIViewController {

    weak var lastVC: VC?
    private lazy var _pageVC: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.dataSource = self
        vc.delegate = self
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = VC(index: 999)
        view.backgroundColor = UIColor.orange
        view.addSubview(_pageVC.view)
        _pageVC.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
        navigationController?.enableRainbowTransition()
        navBarBgAlpha = 0
        lastVC = vc
        transparent(with: vc._scrollView, force: true)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TTTViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let idx = (viewController as? VC)?.idx else { return nil }
        return VC(index: idx - 1)
    }

    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let idx = (viewController as? VC)?.idx else { return nil }
        return VC(index: idx + 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating _: Bool, previousViewControllers _: [UIViewController], transitionCompleted _: Bool) {
        if let vc = pageViewController.viewControllers?.first as? VC {
            transparent(with: vc._scrollView, force: true, setAlphaForFirstTime: false)
            let al = rt_alpha(for: vc._scrollView)
            navigationController?.setNeedsNavigationBackground(alpha: al, animated: true)
            setNeedsStatusBarAppearanceUpdate()
            lastVC = vc
        }
    }
}

final class VC: UIViewController {

    var idx: Int = 0

    deinit {
        print("deinit \(idx)")
    }

    lazy var _scrollView: UIScrollView = {
        let sc = UIScrollView()
        sc.frame = UIScreen.main.bounds
        return sc
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    convenience init(index: Int) {
        self.init(nibName: nil, bundle: nil)
        print("init \(index)")
        idx = index
        if idx % 2 == 0 {
            view.backgroundColor = UIColor.gray
        } else {
            view.backgroundColor = UIColor.orange
        }
        _scrollView.tag = idx
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 4)
        view.addSubview(_scrollView)
    }
}
