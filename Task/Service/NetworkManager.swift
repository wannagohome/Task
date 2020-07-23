//
//  NetworkManager.swift
//  Task
//
//  Created by jinho jang on 2020/07/22.
//  Copyright © 2020 Peter Jang. All rights reserved.
//

import RxSwift

protocol NetworkingManagerProtocol {
     func request<T: Decodable>(_ request: URLRequest) -> Observable<Result<T, NetworkError>>
}

final class NetworkingManager: NetworkingManagerProtocol {
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T: Decodable>(_ request: URLRequest) -> Observable<Result<T, NetworkError>> {
        return session.rx.response(request: request)
            .map { respons, data in
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    return .success(result)
                } catch {
                    return .failure(.castingError)
                }
        }
    }
}


