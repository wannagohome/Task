//
//  ViewModelTests.swift
//  TaskTests
//
//  Created by jinho jang on 2020/07/24.
//  Copyright © 2020 Peter Jang. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import Task

final class ViewModelTests: XCTestCase {
    private let disposeBag = DisposeBag()
    private var scheduler: TestScheduler!
    private var service: UserServiceStub!
    private var viewModel: ViewModel!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.service = UserServiceStub()
        self.viewModel = ViewModel(userService: service)
    }
    
    func testSearchText_whenReceiveText_searchUser() {
        let searchText = scheduler.createObserver(String.self)
        let result = scheduler.createObserver(SearchResult.self)
        
        self.viewModel.searchText
            .bind(to: searchText)
            .disposed(by: disposeBag)
        
        self.viewModel.userSearchResult
            .bind(to: result)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(10, "abc")])
            .bind(to: self.viewModel.searchText)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertNotNil(result.events)
    }
    
    func testSearchText_whenReceiveText_resetPage() {
        let page = scheduler.createObserver(Int.self)
        
        self.viewModel.page
            .skip(1)
            .bind(to: page)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(10, "abc")])
            .bind(to: self.viewModel.searchText)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(page.events, [.next(10, 1)])
    }
    
    func testLoadNext_turnNextPage() {
        let page = scheduler.createObserver(Int.self)
        
        self.viewModel.page
            .skip(2)
            .bind(to: page)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([
            .next(10, ()),
            .next(30, ()),
            .next(50, ()),
        ])
            .bind(to: self.viewModel.loadNext)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(0, "abc")])
            .bind(to: self.viewModel.searchText)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(0, true)])
            .bind(to: self.viewModel.isNotLastPage)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(page.events, [.next(10, 2),
                                     .next(30, 3),
                                     .next(50, 4),])
    }
    
    func testLoadNext_loadNextPage() {
        let result = scheduler.createObserver(SearchResult.self)
        
        self.viewModel.fetchedSearchResult
            .bind(to: result)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([
            .next(10, ()),
            .next(30, ()),
            .next(50, ()),
        ])
            .bind(to: self.viewModel.loadNext)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(0, "abc")])
            .bind(to: self.viewModel.searchText)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(0, true)])
            .bind(to: self.viewModel.isNotLastPage)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertNotNil(result)
    }
    
    func testLoadNext_appendList() {
        let count = scheduler.createObserver(Int.self)
        
        self.viewModel.cellData
            .map { $0.count }
            .drive(count)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(10, "abc")])
            .bind(to: self.viewModel.searchText)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(0, true)])
            .bind(to: self.viewModel.isNotLastPage)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([
            .next(20, ()),
            .next(30, ()),
            .next(40, ()),
        ])
            .bind(to: self.viewModel.loadNext)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(count.events, [.next(10, 30),
                                      .next(20, 60),
                                      .next(30, 90),
                                      .next(40, 120)])
    }
    
    func testRepoCount_loadCount() {
        let count = scheduler.createObserver(Int.self)
        
        self.scheduler.createColdObservable([.next(0, URL(string: "HelloWorld")!)])
            .flatMapLatest(self.service.repoCount(with:))
            .filter { $0.isSuccess }
            .compactMap { $0.value }
            .bind(to: count)
            .disposed(by: disposeBag)
            
        self.scheduler.start()
        
        XCTAssertEqual(count.events, [.next(0, 10)])
    }
}
