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
    
    var searchText = PublishSubject<String>()
    var loadNext = PublishSubject<Void>()
    
    var cellData: Driver<[UserList]>
    
    var userSearchResult: Observable<[UserList]>
    
    init(userService: UserServiceProtocol) {
        self.userService = userService
        
        self.userSearchResult = searchText
            .map { ($0, 1) }
            .flatMapLatest(userService.searchUser)
            .map { result -> [UserList]? in
                guard case .success(let value) = result else {
                    return nil
                }
                return value.items
        }
        .filterNil()
        
        self.cellData = userSearchResult
            .asDriver(onErrorDriveWith: .empty())
    }
}

