//
//  Views.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 10/9/2565 BE.
//

import UIKit

extension UIView {
    func add(to parentView: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -insets.right),
            topAnchor.constraint(equalTo: parentView.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -insets.bottom)
        ])
    }
}
