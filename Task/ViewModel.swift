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
    
    var cellData: Driver<[User]>
    
    var searchResult: Observable<[User]>
    
    init(userService: UserServiceProtocol) {
        self.userService = userService
        
        self.searchResult = searchText
            .flatMapLatest(userService.searchUser(q:))
            .map { result -> [User]? in
                guard case .success(let value) = result else {
                    return nil
                }
                return value.items
        }
        .filterNil()
        
        
        self.cellData = searchResult
            .asDriver(onErrorDriveWith: .empty())
    }
}


