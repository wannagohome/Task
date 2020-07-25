//
//  User.swift
//  Task
//
//  Created by jinho jang on 2020/07/24.
//  Copyright © 2020 Peter Jang. All rights reserved.
//

import Foundation

struct User: Codable {
    var login: String?
    var id: Int?
    var nodeID: String?
    var avatarURL: String?
    var publicRepos: Int?

    enum CodingKeys: String, CodingKey {
        case login, id
        case nodeID = "node_id"
        case avatarURL = "avatar_url"
        case publicRepos = "public_repos"
    }
}
