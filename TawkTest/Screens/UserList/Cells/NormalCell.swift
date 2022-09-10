//
//  NormalCell.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 9/9/2565 BE.
//

import UIKit

final class NormalCell: UITableViewCell, CellConfigurable {
    private var normalView: NormalView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        normalView = NormalView()
        normalView.add(to: contentView)
    }
    
    func configure(with model: GithubUser) {
        normalView.configure(with: model)
    }
}
