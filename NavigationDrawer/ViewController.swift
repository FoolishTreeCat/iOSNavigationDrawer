//
//  ViewController.swift
//  NavigationDrawer
//
//  Created by treecat on 9/25/14.
//  Copyright (c) 2014 treecat. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DrawerDelegate {

    @IBOutlet var info: UILabel!
    
    var menuDrawer: DrawerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.menuDrawer = self.navigationController as DrawerViewController
        self.menuDrawer.drawerDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toggleMenu(sender: UIBarButtonItem) {
        self.menuDrawer.toggleDrawer()
    }

    func menuSelected(index: Int) {
        self.info.text = "Menu " + String(index) + " Selected"
    }
}

