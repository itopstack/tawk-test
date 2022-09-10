//
//  UserProfileViewController.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 11/9/2565 BE.
//

import UIKit

protocol UserProfileViewControllerDelegate: AnyObject {
    
}

final class UserProfileViewController: UIViewController, Storyboarded {
    var viewModel: UserProfileViewControllerViewModel!
    weak var coordinator: (Coordinator & UserProfileViewControllerDelegate)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        precondition(viewModel != nil, "ViewModel is missing, please assign it to view controller first")
    }
}

extension UserProfileViewController: UserProfileViewControllerViewModelDelegate {
    
}
