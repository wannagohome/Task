//
//  UserServiceStub.swift
//  TaskTests
//
//  Created by jinho jang on 2020/07/23.
//  Copyright © 2020 Peter Jang. All rights reserved.
//

import RxSwift
import Alamofire
@testable import Task

final class UserServiceStub: UserServiceProtocol {
    var parameter: (keyword: String, page: Int)?
    
    func searchUser(keyword: String, page: Int) -> Observable<Result<SearchResult>> {
        self.parameter = (keyword, page)
        do {
            let result = try JSONDecoder().decode(SearchResult.self, from: SampleData.SearchUserResult.data(using: .utf8)!)
            return .just(.success(result))
        } catch {
            return .just(.failure(NetworkError.castingError))
        }
    }
    
    func repoCount(with url: URL) -> Observable<Result<Int>> {
        return .just(.success(10))
    }
}
