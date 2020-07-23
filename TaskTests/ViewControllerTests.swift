//
//  ViewControllerTests.swift
//  TaskTests
//
//  Created by jinho jang on 2020/07/22.
//  Copyright © 2020 Peter Jang. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import Task

final class ViewControllerTests: XCTestCase {
    //MARK: - Constants
    private let disposeBag = DisposeBag()
    private var scheduler: TestScheduler!
    private var service: UserServiceStub!
    private var viewModel: ViewModel!
    private var viewController: ViewController!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.service = UserServiceStub()
        self.viewModel = ViewModel(userService: service)
        self.viewController = ViewController(viewModel: viewModel)
        self.viewController.loadViewIfNeeded()
    }
    
    func testSearchBar_whenSearchBarTextTyped_searchWithText() {
        let searchText = scheduler.createObserver(String.self)
        let result = scheduler.createObserver([User].self)
        
        self.viewModel.searchText
            .bind(to: searchText)
            .disposed(by: disposeBag)
        
        self.viewModel.searchResult
            .bind(to: result)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(0, "abc")])
            .bind(to: self.viewController.searchController.searchBar.rx.text)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertNotNil(result.events)
    }
}
