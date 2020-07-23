//
//  UserCell.swift
//  Task
//
//  Created by Peter Jang on 17/04/2019.
//  Copyright © 2019 Peter Jang. All rights reserved.
//

import UIKit
import Kingfisher


class UserCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profile.layer.cornerRadius = profile.bounds.height / 2
    }
    
    func setData(_ data: User) {
        userName.text = data.login
        
        if let profileURLString = data.avatarURL,
            let profileURL = URL(string: profileURLString) {
            profile.kf.setImage(with: profileURL)
        }
    }
    
    private func layout() {
        addSubview(profile)
        addSubview(userName)
        addSubview(repos)
        
        profile.snp.makeConstraints { m in
            m.top.equalToSuperview().offset(5)
            m.leading.equalToSuperview().offset(25)
            m.bottom.equalToSuperview().offset(-5)
            m.size.equalTo(CGSize(width: 50, height: 50))
        }
        userName.snp.makeConstraints { m in
            m.top.equalTo(profile)
            m.leading.equalTo(profile.snp.trailing).offset(5)
        }
        repos.snp.makeConstraints { m in
            m.top.equalTo(userName.snp.bottom).offset(10)
            m.leading.equalTo(userName)
        }
    }
    
    
    let profile: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        return imageView
    }()
    let userName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    let repos: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        return label
    }()
}
