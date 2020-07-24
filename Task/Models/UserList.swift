//
//	User.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

struct SearchResult: Codable {
    var totalCount: Int?
    var incompleteResults: Bool?
    var items: [UserList]?
    var isNotLastPage: Bool?

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

struct UserList: Codable {
    var login: String?
    var id: Int?
    var nodeID: String?
    var avatarURL: String?
    var gravatarID: String?
    var url, htmlURL, followersURL: String?
    var followingURL, gistsURL, starredURL: String?
    var subscriptionsURL, organizationsURL, reposURL: String?
    var eventsURL: String?
    var receivedEventsURL: String?
    var type: Type?
    var siteAdmin: Bool?
    var score: Double?
    var isExpanded: Bool = false
    var isLoadingCell: Bool = false
    var organizationAvatarUrls: [String] = []
    var repoCount: Int?

    init(_ isLoadingCell: Bool) {
        self.isLoadingCell = isLoadingCell
    }
    
    mutating func showOrganizationsWithURLs(urls: [String]) {
        self.organizationAvatarUrls = urls
        self.isExpanded = true
    }
    
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		avatarURL = try values.decodeIfPresent(String.self, forKey: .avatarURL)
		followingURL = try values.decodeIfPresent(String.self, forKey: .followingURL)
		gravatarID = try values.decodeIfPresent(String.self, forKey: .gravatarID)
		htmlURL = try values.decodeIfPresent(String.self, forKey: .htmlURL)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		login = try values.decodeIfPresent(String.self, forKey: .login)
		organizationsURL = try values.decodeIfPresent(String.self, forKey: .organizationsURL)
		receivedEventsURL = try values.decodeIfPresent(String.self, forKey: .receivedEventsURL)
		reposURL = try values.decodeIfPresent(String.self, forKey: .reposURL)
		score = try values.decodeIfPresent(Double.self, forKey: .score)
		subscriptionsURL = try values.decodeIfPresent(String.self, forKey: .subscriptionsURL)
		type = try values.decodeIfPresent(Type.self, forKey: .type)
		url = try values.decodeIfPresent(String.self, forKey: .url)
	}
    init?(object: [String: Any]) {
        guard let avatarUrl = object["avatar_url"] as? String,
            let followersUrl = object["followers_url"] as? String,
            let gravatarId = object["gravatar_id"] as? String,
            let htmlUrl = object["html_url"] as? String,
            let id = object["id"] as? Int,
            let login = object["login"] as? String,
            let organizationsUrl = object["organizations_url"] as? String,
            let receivedEventsUrl = object["received_events_url"] as? String,
            let reposUrl = object["repos_url"] as? String,
            let score = object["score"] as? Double,
            let subscriptionsUrl = object["subscriptions_url"] as? String,
            let type = object["type"] as? Type,
            let url = object["url"] as? String else {
                return nil
        }
        
        self.avatarURL = avatarUrl
        self.followingURL = followersUrl
        self.gravatarID = gravatarId
        self.htmlURL = htmlUrl
        self.id = id
        self.login = login
        self.organizationsURL = organizationsUrl
        self.receivedEventsURL = receivedEventsUrl
        self.reposURL = reposUrl
        self.score = score
        self.subscriptionsURL = subscriptionsUrl
        self.type = type
        self.url = url
    }

    enum CodingKeys: String, CodingKey {
        case login, id
        case nodeID = "node_id"
        case avatarURL = "avatar_url"
        case gravatarID = "gravatar_id"
        case url
        case htmlURL = "html_url"
        case followersURL = "followers_url"
        case followingURL = "following_url"
        case gistsURL = "gists_url"
        case starredURL = "starred_url"
        case subscriptionsURL = "subscriptions_url"
        case organizationsURL = "organizations_url"
        case reposURL = "repos_url"
        case eventsURL = "events_url"
        case receivedEventsURL = "received_events_url"
        case type
        case siteAdmin = "site_admin"
        case score
    }
}
enum Type: String, Codable {
    case user = "User"
}
