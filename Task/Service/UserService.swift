//
//  UserService.swift
//  Task
//
//  Created by Jinho Jang on 2020/07/21.
//  Copyright © 2020 Peter Jang. All rights reserved.
//

import RxSwift

protocol UserServiceProtocol {
    func searchUser(q: String) -> Observable<Result<SearchResult, NetworkError>>
}

extension UserServiceProtocol {
    func serchUserComponents(q: String) -> URLComponents {
        var result = GitHubUserAPI.basicComponents
        result.queryItems = [URLQueryItem(name: "q", value: q)]
        
        return result
    }
}

final class UserService: UserServiceProtocol {
    let networkManager: NetworkingManagerProtocol
    
    init(networkManager: NetworkingManagerProtocol) {
        self.networkManager = networkManager
    }
    
    @discardableResult
    func searchUser(q: String) -> Observable<Result<SearchResult, NetworkError>> {
        guard let url = serchUserComponents(q: q).url else {
            let error = NetworkError.urlError
            return .just(.failure(error))
        }
        return networkManager.request(URLRequest(url: url))
    }
}


