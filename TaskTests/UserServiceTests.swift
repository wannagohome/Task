//
//  UserServiceTests.swift
//  TaskTests
//
//  Created by Jinho Jang on 2020/07/21.
//  Copyright © 2020 Peter Jang. All rights reserved.
//

import XCTest
import RxSwift
@testable import Task

final class UserServiceTests: XCTestCase {
    let disposeBag = DisposeBag()
    func testSearch()  {
        //give
        let networking = NetworkManagerStub()
        let service = UserService(networkManager: networking)

        //when
        service.searchUser(q: "abc")
                .map { result -> [User]? in
                    guard case .success(let value) = result else {
                        return nil
                    }
                    return value.items
            }
        .subscribe(onNext: {
            XCTAssertNotNil($0)
        })
            .disposed(by: disposeBag)

        //then
        let expectedURL = "https://api.github.com/search/users?q=abc"
        let actualURL = networking.parameter?.url?.absoluteString
        XCTAssertEqual(actualURL, expectedURL)

        let expectedMethod = HTTPMethod.GET
        let actualMethod = networking.parameter?.method
        XCTAssertEqual(actualMethod, expectedMethod)

        let expectedParameters = ["q": "abc"]
        let actualParameters = networking.parameter?.query
        XCTAssertEqual(actualParameters, expectedParameters)
    }

}
