//
//  API.swift
//  Task
//
//  Created by jinho jang on 2020/07/22.
//  Copyright © 2020 Peter Jang. All rights reserved.
//

import Foundation

struct GitHubUserAPI {
    static let scheme = "https"
    static let host = "api.github.com"
    static let path = "/search/users"
    
    static var basicComponents: URLComponents {
        get {
            var components = URLComponents()
            components.scheme = GitHubUserAPI.scheme
            components.host = GitHubUserAPI.host
            components.path = GitHubUserAPI.path
            return components
        }
    }
}

enum NetworkError: Error {
    case error(String)
    case defaultError
    case urlError
    case castingError
    
    var message: String? {
        switch self {
        case let .error(message):
            return message
        case .castingError:
            return "Casting Error"
        case .urlError:
            return "URL Error"
        case .defaultError:
            return "Network Error"
        }
    }
}

struct HTTPMethod {
    static let GET = "GET", POST = "POST", PUT = "PUT", DELETE = "DELETE", PATCH = "PATCH"
}
