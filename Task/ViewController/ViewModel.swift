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
    var loadRepoCount = PublishSubject<URL>()
    
    // output
    var cellData: Driver<[(type: ViewModel.CellType, value: UserList?)]>
    
    // state
    var userSearchResult: Observable<SearchResult>
    var fetchedSearchResult: Observable<SearchResult>
    var page = BehaviorRelay<Int>(value: 1)
    var isNotLastPage = PublishSubject<Bool>()
    
    init(userService: UserServiceProtocol) {
        self.userService = userService
        
        let userSearchResultTemp = self.searchText
            .map { ($0, 1) }
            .flatMapLatest(userService.searchUser)
            .filter { $0.isSuccess }
            .compactMap { $0.value }
        
        self.userSearchResult = userSearchResultTemp
            .compactMap { $0.items }
            .flatMap { Observable.from($0) }
            .concatMap(userService.repoCount)
            .filter { $0.isSuccess }
            .compactMap { $0.value }
            .map { [$0] }
            .scan([]){ prev, new -> [UserList] in
                if prev.count == 30 {
                    return new
                } else {
                    return prev + new
                }
        }
        .filter { $0.count == 30 }
        .withLatestFrom(userSearchResultTemp) {
            var result = $1
            result.items = $0
            return result
        }
        
        self.searchText
            .map { _ in 1 }
            .bind(to: self.page)
            .disposed(by: disposeBag)
        
        let fetchedSearchResultTemp = self.loadNext
            .withLatestFrom(self.isNotLastPage)
            .filter { $0 }
            .withLatestFrom(
                Observable.combineLatest(
                self.searchText,
                self.page
            ))
            .map { ($0, $1 + 1) }
            .flatMapLatest(userService.searchUser)
            .filter { $0.isSuccess }
            .compactMap { $0.value }
        
        self.fetchedSearchResult = fetchedSearchResultTemp
            .compactMap { $0.items }
            .flatMap { Observable.from($0) }
            .concatMap(userService.repoCount)
            .filter { $0.isSuccess }
            .compactMap { $0.value }
            .map { [$0] }
            .scan([]){ prev, new -> [UserList] in
                if prev.count == 30 {
                    return new
                } else {
                    return prev + new
                }
        }
        .filter { $0.count == 30 }
        .withLatestFrom(fetchedSearchResultTemp) {
            var result = $1
            result.items = $0
            return result
        }
        
        Observable.merge(
            self.userSearchResult,
            self.fetchedSearchResult
        )
            .compactMap { $0.isNotLastPage }
            .bind(to: self.isNotLastPage)
            .disposed(by: disposeBag)
        
        self.fetchedSearchResult
            .withLatestFrom(self.page)
            .map { $0 + 1 }
            .bind(to: self.page)
            .disposed(by: disposeBag)
        
        self.cellData = Observable.merge(
            self.userSearchResult,
            self.fetchedSearchResult
        )
            .scan([]) { (prev, new) -> [UserList] in
                if new.isFirstPage { return new.items ?? [] }
                else { return prev + (new.items ?? []) }
        }
        .withLatestFrom(self.isNotLastPage) { ($0, $1)}
        .map { list, isNotLast -> [(type: ViewModel.CellType, value: UserList?)] in
            var result: [(type: ViewModel.CellType, value: UserList?)] = list.map { (type: CellType.user, value: $0) }
            if isNotLast {
                result.append((type: .loading, value: nil))
                return result
            } else {
                return result
            }
        }
        .asDriver(onErrorDriveWith: .empty())
        
    }
    
    
    enum CellType {
        case user
        case loading
    }
}

