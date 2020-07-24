//
//  ViewModel.swift
//  Task
//
//  Created by Peter Jang on 09/04/2019.
//  Copyright © 2019 Peter Jang. All rights reserved.
//

import RxSwift
import RxCocoa
import RxOptional

class ViewModel: ViewBindable {
    let userService: UserServiceProtocol
    let disposeBag = DisposeBag()
    
    // input
    var searchText = PublishSubject<String>()
    var loadNext = PublishSubject<Void>()
    
    // output
    var cellData: Driver<[UserList]>
    
    // state
    var userSearchResult: Observable<SearchResult>
    var fetchedSearchResult: Observable<SearchResult>
    var page = BehaviorRelay<Int>(value: 1)
    var isNotLastPage = PublishSubject<Bool>()
    
    init(userService: UserServiceProtocol) {
        self.userService = userService
        
        self.userSearchResult = self.searchText
            .map { ($0, 1) }
            .flatMapLatest(userService.searchUser)
            .map { result -> SearchResult? in
                guard case .success(let value) = result else {
                    return nil
                }
                return value
        }
        .filterNil()
        
        self.searchText
            .map { _ in 1 }
            .bind(to: self.page)
            .disposed(by: disposeBag)
        
        self.fetchedSearchResult = self.loadNext
            .withLatestFrom(self.isNotLastPage)
            .filter { $0 }
            .withLatestFrom(
                Observable.combineLatest(
                self.searchText,
                self.page
            ))
            .map { ($0, $1 + 1) }
            .flatMapLatest(userService.searchUser)
                .map { result -> SearchResult? in
                    guard case .success(let value) = result else {
                        return nil
                    }
                    return value
            }
            .filterNil()
        
        Observable.merge(
            self.userSearchResult,
            self.fetchedSearchResult
        )
            .map { $0.isNotLastPage }
            .filterNil()
            .bind(to: self.isNotLastPage)
            .disposed(by: disposeBag)
        
        self.fetchedSearchResult
            .withLatestFrom(self.page)
            .map { $0 + 1 }
            .bind(to: self.page)
            .disposed(by: disposeBag)
        
        self.cellData = Observable.merge(
            self.userSearchResult
                .map{ $0.items }
                .filterNil(),
            self.fetchedSearchResult
                .map{ $0.items }
                .filterNil()
        )
            .scan([]){ prev, new in
                return new.isEmpty ? [] : prev + new
        }
        .asDriver(onErrorDriveWith: .empty())
    }
}

