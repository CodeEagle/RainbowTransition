//
//  ViewController.swift
//  SD
//
//  Created by LawLincoln on 2016/11/1.
//  Copyright © 2016年 LawLincoln. All rights reserved.
//

import UIKit
import RainbowTransition

class ViewController: UIViewController, RainbowColorSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        let v = UIView(frame: UIScreen.main.bounds)
        v.backgroundColor = .white
        view.addSubview(v)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(ViewController.p))
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func navigationBarInColor() -> UIColor {
        return .clear
    }
    
    @IBAction func p() {
        let vc = TBViewController(nibName: nil, bundle: nil)
        show(vc, sender: nil)
    }
}


class TBViewController: UIViewController, RainbowColorSource {
    
    private lazy var tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        navigationController?.navigationBar.shadow(enable: true)
        view.backgroundColor = .white
        automaticallyAdjustsScrollViewInsets = false
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 300))
        v.backgroundColor = .orange
        tableView.tableHeaderView = v
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.statusBarResponder = self
        //fd_interactivePopDisabled = true
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.transparent(with: tableView)
        navigationController?.disableDrag(in: type(of: self))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.shadow(enable: false)
    }

    func navigationBarInColor() -> UIColor {
        return tableView.alphaColor
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return tableView.alphaColor.cgColor.alpha > 0.6 ? .default : .lightContent
    }
}

extension TBViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
}



class DTBViewController: UIViewController, RainbowColorSource {
    
    private lazy var tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.backgroundColor = .white
        automaticallyAdjustsScrollViewInsets = false
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 300))
        v.backgroundColor = .orange
        tableView.tableHeaderView = v
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //fd_interactivePopDisabled = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.transparent(with: tableView)
    }
    
    func navigationBarInColor() -> UIColor {
        return tableView.alphaColor
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension DTBViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = "\(indexPath.row)"
        return cell!
    }
}
