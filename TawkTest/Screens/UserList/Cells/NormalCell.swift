//
//  NormalCell.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 9/9/2565 BE.
//

import UIKit

class NormalCell: UITableViewCell, CellConfigurable {
    private(set) var normalView: NormalView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        selectionStyle = .none
        
        normalView = NormalView()
        normalView.add(to: contentView, insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
    }
    
    func configure(with model: GithubUser) {
        normalView.configure(with: model)
    }
    
    func updateAvatarImage(from data: Data?) {
        normalView.avatarMode = .normal
        normalView.updateAvatarImage(from: data)
    }
}
