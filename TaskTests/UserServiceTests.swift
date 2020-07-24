//
//  UserServiceTests.swift
//  TaskTests
//
//  Created by Jinho Jang on 2020/07/21.
//  Copyright © 2020 Peter Jang. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import Task

final class UserServiceTests: XCTestCase {
    private let disposeBag = DisposeBag()
    private var scheduler: TestScheduler!
    private var service: UserServiceStub!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.service = UserServiceStub()
    }
    
    
    func testSearchUsers()  {
        let result = scheduler.createObserver(SearchResult.self)
        
        self.scheduler.createColdObservable([.next(0, ("abc", 1))])
            .flatMapLatest(self.service.searchUser)
            .compactMap { result -> SearchResult? in
                guard case .success(let value) = result else {
                    return nil
                }
                return value
        }
        .bind(to: result)
        .disposed(by: disposeBag)
        
        self.scheduler.start()
        XCTAssertNotNil(result.events)

        let expectedURL = "abc"
        let actualURL = self.service.parameter?.keyword
        XCTAssertEqual(actualURL, expectedURL)

        let expectedParameters = 1
        let actualParameters = self.service.parameter?.page
        XCTAssertEqual(actualParameters, expectedParameters)
    }
    
    func testRepoCount() {
        let count = scheduler.createObserver(Int.self)
        
        self.scheduler.createColdObservable([.next(0, URL(string: "HelloWorld")!)])
            .flatMapLatest(self.service.repoCount(with:))
            .filter { $0.isSuccess }
            .compactMap { $0.value }
            .bind(to: count)
            .disposed(by: disposeBag)
            
        self.scheduler.start()
        
        XCTAssertEqual(URL(string: "HelloWorld")!, self.service.parameter?.url)
    }
}
