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
    func repoCount(with url: URL) -> Observable<Result<Int>>
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
                    }
                    return .success(result)
                } catch {
                    return .failure(NetworkError.castingError)
                }
        }
    }
    
    func repoCount(with url: URL) -> Observable<Result<Int>> {
        return SessionManager.default.rx.request(.get, url)
            .data()
            .map { data in
                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    return .success(user.publicRepos ?? 0)
                } catch {
                    return .failure(NetworkError.castingError)
                }
        }
    }
}
