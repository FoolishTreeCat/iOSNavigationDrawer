//
//  DrawerViewController.swift
//  NavigationDrawer
//
//  Created by treecat on 9/25/14.
//  Copyright (c) 2014 treecat. All rights reserved.
//

import UIKit

protocol DrawerDelegate {
    
    func menuSelected(index: Int)
    
}

class DrawerViewController: UINavigationController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let MENU_DURATION: Double = 0.3
    let SHADOW_ALPHA: CGFloat = 0.5
    let MENU_TRIGGER_VELOCITY: CGFloat = 350.0
    
    var isOpen: Bool = false
    var menuWidth: CGFloat = 0.0
    var menuHeight: CGFloat = 0.0
    
    var drawerView: DrawerView!
    var shadowView: UIView!
    var outFrame: CGRect!
    var inFrame: CGRect!
    var panGr: UIPanGestureRecognizer!
    
    var drawerDelegate: DrawerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupDrawer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        
        self.panGr.enabled = false
    }
    
    override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        var vc: UIViewController = super.popViewControllerAnimated(animated)!
        
        if(self.viewControllers.count == 1) {
            self.panGr.enabled = true
        }
        
        return vc
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: DrawerViewCell = tableView.dequeueReusableCellWithIdentifier("drawerMenu") as DrawerViewCell
        
        if(indexPath.row == 0) {
            cell.name.text = "menu01"
        } else if (indexPath.row == 1) {
            cell.name.text = "menu02"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        if(self.drawerDelegate != nil) {
            self.drawerDelegate!.menuSelected(indexPath.row)
            self.closeMenuDrawer()
        }
    }
    
    func setupDrawer() {
        self.isOpen = false
        
        // load drawer view
        self.drawerView = loadFromNid("DrawerView") as DrawerView
        var nibName = UINib(nibName: "DrawerViewCell", bundle: nil)
        self.drawerView.tableView.registerNib(nibName, forCellReuseIdentifier: "drawerMenu")
        self.setExtraCellLineHidden(self.drawerView.tableView)
        
        self.menuWidth = self.view.frame.width * 2 / 3
        self.menuHeight = self.view.frame.height
        self.outFrame = CGRectMake(-self.menuWidth, 0, self.menuWidth, self.menuHeight)
        self.inFrame = CGRectMake(0, 0, self.menuWidth, self.menuHeight)
        
        // load shadow view
        self.shadowView = UIView(frame: self.view.frame)
        self.shadowView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        self.shadowView.hidden = true
        
        var tabIt: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapOnShadow:")
        self.shadowView.addGestureRecognizer(tabIt)
        self.shadowView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.shadowView)
        
        //add drawer view
        self.drawerView.frame = outFrame
        self.view.addSubview(self.drawerView)
        
        //drawer list
        self.drawerView.tableView.contentInset =  UIEdgeInsetsMake(64, 0, 0, 0)
        self.drawerView.tableView.dataSource = self
        self.drawerView.tableView.delegate = self
        
        //gesture on self.view
        self.panGr = UIPanGestureRecognizer(target: self, action: "moveDrawer:")
        self.panGr.maximumNumberOfTouches = 1
        self.panGr.minimumNumberOfTouches = 1
        self.view.addGestureRecognizer(self.panGr)
        
        self.view.bringSubviewToFront(self.navigationBar)
    }
    
    func tapOnShadow(recongnizer: UITapGestureRecognizer) {
        closeMenuDrawer()
    }
    
    func closeMenuDrawer() {
        //println("closeMenuDrawer")
        var duration: Double = MENU_DURATION / Double(self.menuWidth * abs(self.drawerView.center.x)) + MENU_DURATION / 2
        
        //shadow
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { self.shadowView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0) }, completion: { (finished: Bool) in self.shadowView.hidden = true })
        
        //drawer
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { self.drawerView.frame = self.outFrame }, nil)
        
        self.isOpen = false
    }
    
    func moveDrawer(recongnizer: UIPanGestureRecognizer) {
        var translation: CGPoint = recongnizer.translationInView(self.view)
        var velocity: CGPoint = recongnizer.velocityInView(self.view)
        
        if(recongnizer.state == UIGestureRecognizerState.Began) {
            if (velocity.x > MENU_TRIGGER_VELOCITY && !self.isOpen) {
                openMenuDrawer()
            } else if (velocity.x < -MENU_TRIGGER_VELOCITY && self.isOpen) {
                closeMenuDrawer()
            }
        }
        
        if(recongnizer.state == UIGestureRecognizerState.Changed) {
            var movingx: CGFloat = self.drawerView.center.x + translation.x
            if (movingx > -self.menuWidth / 2 && movingx < self.menuWidth / 2) {
                self.drawerView.center = CGPointMake(movingx, self.drawerView.center.y)
                recongnizer.setTranslation(CGPointMake(0, 0), inView: self.view)
                
                var changingAlpha: CGFloat = SHADOW_ALPHA / self.menuWidth * movingx + SHADOW_ALPHA / 2
                self.shadowView.hidden = false
                self.shadowView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: changingAlpha)
            }
        }
        
        if(recongnizer.state == UIGestureRecognizerState.Ended) {
            if (self.drawerView.center.x > 0) {
                openMenuDrawer()
            } else if (self.drawerView.center.x < 0) {
                closeMenuDrawer()
            }
        }
    }
    
    func openMenuDrawer() {
        //println("openMenuDrawer")
        var duration: Double = MENU_DURATION / Double(self.menuWidth * abs(self.drawerView.center.x)) + MENU_DURATION / 2
        
        self.shadowView.hidden = false
        //shadow
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { self.shadowView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: self.SHADOW_ALPHA) }, completion: nil)
        
        //drawer
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { self.drawerView.frame = self.inFrame }, completion: nil)
        
        self.isOpen = true
    }
    
    func toggleDrawer() {
        if(!self.isOpen) {
            openMenuDrawer()
        } else {
            closeMenuDrawer()
        }
    }
    
    func loadFromNid(name: String) -> UIView {
        return UINib(nibName: name, bundle: nil).instantiateWithOwner(nil , options: nil)[0] as UIView
    }
    
    func setExtraCellLineHidden(tableView: UITableView) {
        var view: UIView = UIView()
        view.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = view
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
