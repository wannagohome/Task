//
//	Item.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

struct Item : Codable {

    let avatarUrl : String?
    let followersUrl : String?
    let gravatarId : String?
    let htmlUrl : String?
    let id : Int?
    let login : String?
    let organizationsUrl : String?
    let receivedEventsUrl : String?
    let reposUrl : String?
    let score : Double?
    let subscriptionsUrl : String?
    let type : String?
    let url : String?


	enum CodingKeys: String, CodingKey {
		case avatarUrl = "avatar_url"
		case followersUrl = "followers_url"
		case gravatarId = "gravatar_id"
		case htmlUrl = "html_url"
		case id = "id"
		case login = "login"
		case organizationsUrl = "organizations_url"
		case receivedEventsUrl = "received_events_url"
		case reposUrl = "repos_url"
		case score = "score"
		case subscriptionsUrl = "subscriptions_url"
		case type = "type"
		case url = "url"
	}
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		avatarUrl = try values.decodeIfPresent(String.self, forKey: .avatarUrl)
		followersUrl = try values.decodeIfPresent(String.self, forKey: .followersUrl)
		gravatarId = try values.decodeIfPresent(String.self, forKey: .gravatarId)
		htmlUrl = try values.decodeIfPresent(String.self, forKey: .htmlUrl)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		login = try values.decodeIfPresent(String.self, forKey: .login)
		organizationsUrl = try values.decodeIfPresent(String.self, forKey: .organizationsUrl)
		receivedEventsUrl = try values.decodeIfPresent(String.self, forKey: .receivedEventsUrl)
		reposUrl = try values.decodeIfPresent(String.self, forKey: .reposUrl)
		score = try values.decodeIfPresent(Double.self, forKey: .score)
		subscriptionsUrl = try values.decodeIfPresent(String.self, forKey: .subscriptionsUrl)
		type = try values.decodeIfPresent(String.self, forKey: .type)
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
            let type = object["type"] as? String,
            let url = object["url"] as? String else {
                return nil
        }
        
        
        
        self.avatarUrl = avatarUrl
        self.followersUrl = followersUrl
        self.gravatarId = gravatarId
        self.htmlUrl = htmlUrl
        self.id = id
        self.login = login
        self.organizationsUrl = organizationsUrl
        self.receivedEventsUrl = receivedEventsUrl
        self.reposUrl = reposUrl
        self.score = score
        self.subscriptionsUrl = subscriptionsUrl
        self.type = type
        self.url = url
    }

}
