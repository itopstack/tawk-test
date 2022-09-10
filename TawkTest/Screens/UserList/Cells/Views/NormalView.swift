//
//  NormalView.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 10/9/2565 BE.
//

import UIKit

final class NormalView: UIView {
    enum AvatarMode {
        case normal
        case inverted
    }
    
    private var usernameLabel: UILabel!
    private var avatarImageView: CircleImageView!
    
    var avatarMode: AvatarMode?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }
    
    private func setUpView() {
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 8
        
        avatarImageView = CircleImageView()
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            avatarImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        
        usernameLabel = UILabel()
        usernameLabel.font = .boldSystemFont(ofSize: 14)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(usernameLabel)
        NSLayoutConstraint.activate([
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            usernameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            usernameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configure(with user: GithubUser?) {
        usernameLabel.text = user?.login
    }
    
    func updateAvatarImage(from data: Data?) {
        guard let data = data else {
            return
        }
        
        let image = UIImage(data: data)
        
        if case .inverted = avatarMode {
            let beginImage = CIImage(image: image ?? UIImage())
            
            if let filter = CIFilter(name: "CIColorInvert") {
                filter.setValue(beginImage, forKey: kCIInputImageKey)
                
                if let outputImage = filter.outputImage {
                    avatarImageView.image = UIImage(ciImage: outputImage)
                    return
                }
            }
        }
        
        avatarImageView.image = image
    }
}
