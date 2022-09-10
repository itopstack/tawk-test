//
//  UITableViewCells.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 10/9/2565 BE.
//

import UIKit

protocol CellConfigurable: UITableViewCell {
    func configure(with model: GithubUser)
}
