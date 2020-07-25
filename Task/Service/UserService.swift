//
//  UserService.swift
//  Task
//
//  Created by Jinho Jang on 2020/07/21.
//  Copyright © 2020 Peter Jang. All rights reserved.
//

import RxSwift
import Alamofire
import RxAlamofire


protocol UserServiceProtocol {
    func searchUser(keyword: String, page: Int) -> Observable<Result<SearchResult>>
    func repoCount(with user: UserList) -> Observable<Result<UserList>>
}

final class UserService: UserServiceProtocol {
    func searchUser(keyword: String, page: Int = 1) -> Observable<Result<SearchResult>> {
        guard let url = GitHubUserAPI.searchUserComponents.url else {
            return .just(.failure(NetworkError.urlError))
        }
        let parameters: Parameters = ["q": keyword, "page": page]
        
        return SessionManager.default.rx.request(
            .get,
            url,
            parameters: parameters
        )
            .responseData()
            .map { response, data in
                do {
                    var result = try JSONDecoder().decode(SearchResult.self, from: data)
                    if let link = response.allHeaderFields["Link"] as? String {
                        result.isNotLastPage = link.contains("next")
                        result.isFirstPage = (page == 1)
                    }
                    return .success(result)
                } catch {
                    return .failure(NetworkError.castingError)
                }
        }
    }
    
    func repoCount(with user: UserList) -> Observable<Result<UserList>> {
        guard let urlString = user.url,
            let url = URL(string: urlString) else {
                return .just(.failure(NetworkError.urlError))
        }
        var user = user
        return SessionManager.default.rx.request(.get, url)
            .responseData()
            .map { response, data in
                if response.statusCode != 200 {
                    return .failure(NetworkError.defaultError)
                }
                do {
                    let result = try JSONDecoder().decode(User.self, from: data)
                    user.repoCount = result.publicRepos
                    return .success(user)
                } catch {
                    return .failure(NetworkError.castingError)
                }
        }
    }
}
