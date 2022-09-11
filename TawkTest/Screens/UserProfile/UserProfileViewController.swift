//
//  UserProfileViewController.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 11/9/2565 BE.
//

import UIKit

protocol UserProfileViewControllerDelegate: AnyObject {
    func userProfileViewController(_ vc: UserProfileViewController, didUpdate note: String, at userId: Int)
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
    @IBOutlet weak var personalView: UIStackView!
    
    var viewModel: UserProfileViewControllerViewModel!
    weak var coordinator: (Coordinator & UserProfileViewControllerDelegate)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        precondition(viewModel != nil, "ViewModel is missing, please assign it to view controller first")
        
        personalView.layer.borderWidth = 1
        personalView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        personalView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        personalView.isLayoutMarginsRelativeArrangement = true
        
        noteTextView.layer.borderWidth = 1
        noteTextView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        
        viewModel.fetchUserProfile { [weak self] errorMessage in
            if let errorMessage = errorMessage {
                let alertView = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    self?.navigationController?.popViewController(animated: true)
                }
                alertView.addAction(okAction)
                self?.present(alertView, animated: true)
            } else {
                self?.followingLabel.text = self?.viewModel.following
                self?.followersLabel.text = self?.viewModel.followers
                self?.nameLabel.text = self?.viewModel.name
                self?.emailLabel.text = self?.viewModel.email
                self?.locationLabel.text = self?.viewModel.location
                self?.reposLabel.text = self?.viewModel.repos
                self?.bioLabel.text = self?.viewModel.bio
                self?.noteTextView.text = self?.viewModel.note
                
                self?.viewModel.loadProfileImage(completion: { data in
                    if let data = data {
                        self?.profileImageView.image = UIImage(data: data)
                    }
                })
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.endEditing(true)
    }
    
    @IBAction func save(_ sender: Any) {
        view.endEditing(true)
        coordinator?.userProfileViewController(self, didUpdate: noteTextView.text, at: viewModel.userProfile.id)
    }
}
