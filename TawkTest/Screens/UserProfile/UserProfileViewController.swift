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
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var reposLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    
    var viewModel: UserProfileViewControllerViewModel!
    weak var coordinator: (Coordinator & UserProfileViewControllerDelegate)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        precondition(viewModel != nil, "ViewModel is missing, please assign it to view controller first")
        
        viewModel.fetchUserProfile { [weak self] errorMessage in
            if let errorMessage = errorMessage {
                // TODO: Handle error message
            } else {
                self?.followingLabel.text = self?.viewModel.following
                self?.followersLabel.text = self?.viewModel.followers
                self?.nameLabel.text = self?.viewModel.name
                self?.emailLabel.text = self?.viewModel.email
                self?.locationLabel.text = self?.viewModel.location
                self?.reposLabel.text = self?.viewModel.repos
                self?.bioLabel.text = self?.viewModel.bio
                
                self?.viewModel.loadProfileImage(completion: { data in
                    if let data = data {
                        self?.profileImageView.image = UIImage(data: data)
                    }
                })
            }
        }
    }
    
    @IBAction func save(_ sender: Any) {
        
    }
}
