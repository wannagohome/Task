//
//  UserCell.swift
//  Task
//
//  Created by Peter Jang on 17/04/2019.
//  Copyright © 2019 Peter Jang. All rights reserved.
//

import UIKit


class UserCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    
    
    func setupViews() {
        addSubview(profileImageView)
        addSubview(userNameLabel)
        addSubview(scoreLabel)
        
        
        profileImageView.anchor(top: contentView.topAnchor,
                                leading: contentView.leadingAnchor,
                                bottom: nil,
                                trailing: nil,
                                padding: .init(top: 25, left: 25, bottom: 0, right: 0),
                                size: .init(width: 50, height: 50))
        userNameLabel.anchor(top: profileImageView.topAnchor,
                             leading: profileImageView.trailingAnchor,
                             bottom: nil,
                             trailing: nil,
                             padding: .init(top: 0, left: 5, bottom: 0, right: 0))
        scoreLabel.anchor(top: userNameLabel.bottomAnchor,
                          leading: userNameLabel.leadingAnchor,
                          bottom: contentView.bottomAnchor,
                          trailing: nil,
                          padding: .init(top: 3, left: 0, bottom: 0, right: 0))
        
        
        
        addSubview(scrollView)
        scrollView.anchor(top: profileImageView.bottomAnchor,
                          leading: profileImageView.leadingAnchor,
                          bottom: nil,
                          trailing: contentView.trailingAnchor,
                          padding: .init(top: 5, left: 0, bottom: 0, right: 25),
                          size: .init(width: contentView.bounds.width, height: 40))
        scrollView.addSubview(stackView)
        stackView.anchor(top: scrollView.topAnchor,
                         leading: scrollView.leadingAnchor,
                         bottom: scrollView.bottomAnchor,
                         trailing: scrollView.trailingAnchor)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.isUserInteractionEnabled = true
        label.backgroundColor = .clear
        return label
    }()
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        label.backgroundColor = .clear
        return label
    }()
    var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()
}
