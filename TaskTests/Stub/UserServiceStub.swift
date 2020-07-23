//
//  UserServiceStub.swift
//  TaskTests
//
//  Created by jinho jang on 2020/07/23.
//  Copyright © 2020 Peter Jang. All rights reserved.
//

import RxSwift
@testable import Task

final class UserServiceStub: UserServiceProtocol {
    var parameter: (url: URL?, query:[String: String]?)?
    let networkManager: NetworkingManagerProtocol
    
    init(networkManager: NetworkingManagerProtocol
        = NetworkManagerStub()) {
        self.networkManager = networkManager
    }
    
    func searchUser(q: String) -> Observable<Result<SearchResult, NetworkError>> {
                guard let url = serchUserComponents(q: q).url else {
            let error = NetworkError.urlError
            return .just(.failure(error))
        }
        self.parameter = (url, url.queryParameters)
        return networkManager.request(URLRequest(url: url))
    }
}
