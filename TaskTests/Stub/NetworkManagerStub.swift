//
//  NetworkManagerStub.swift
//  TaskTests
//
//  Created by jinho jang on 2020/07/22.
//  Copyright © 2020 Peter Jang. All rights reserved.
//

import RxSwift

@testable import Task

final class NetworkManagerStub: NetworkingManagerProtocol {
    var parameter: (url: URL?, method: String?, query:[String: String]?)?
    
    func request<T>(_ request: URLRequest) -> Observable<Result<T, NetworkError>> where T : Decodable {
        self.parameter = (request.url, request.httpMethod, request.url?.queryParameters)
        
        do {
            let result = try JSONDecoder().decode(T.self, from: SampleData.user.data(using: .utf8)!)
            return .just(.success(result))
        } catch  {
            return .just(.failure(.defaultError))
        }
    }
    
}
extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
