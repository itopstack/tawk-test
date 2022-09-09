//
//  UserListViewController.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 9/9/2565 BE.
//

import UIKit

protocol UserListViewControllerDelegate: AnyObject {
    
}

final class UserListViewController: UIViewController {
    weak var coordinator: (Coordinator & UserListViewControllerDelegate)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
