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
}

final class UserService: UserServiceProtocol {
    func searchUser(keyword: String, page: Int = 1) -> Observable<Result<SearchResult>> {
        guard let url = GitHubUserAPI.searchUserComponents.url else {
            return .just(.failure(NetworkError.urlError))
        }
        let parameters: Parameters = ["q": keyword, "page": page]
        
        return SessionManager.default
            .rx
            .request(
                .get,
                url,
                parameters: parameters)
            .responseData()
            .map { response, data in
                do {
                    let result = try JSONDecoder().decode(SearchResult.self, from: data)
                    return .success(result)
                } catch {
                    return .failure(NetworkError.castingError)
                }
        }
    }
}
