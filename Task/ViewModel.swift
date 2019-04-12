//
//  ViewModel.swift
//  Task
//
//  Created by Peter Jang on 09/04/2019.
//  Copyright © 2019 Peter Jang. All rights reserved.
//

import RxSwift
import RxCocoa
import GithubAPI

class ViewModel {
    
    let searchText = BehaviorRelay(value: "")
    
    lazy var data: Driver<[Item]> = {
        
        return self.searchText.asObservable()
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest(ViewModel.repositoriesBy)
            .asDriver(onErrorJustReturn: [])
    }()
    
    static func repositoriesBy(_ githubID: String) -> Observable<[Item]> {
        guard !githubID.isEmpty,
            let url = URL(string: "https://api.github.com/search/users?q=\(githubID)") else {
                return Observable.just([])
        }
        
        return URLSession.shared.rx.json(url: url)
            .retry(3)
            //.catchErrorJustReturn([])
            .map(parse)
    }
    
    static func parse(json: Any) -> [Item] {
        guard let json = json as? [String: Any],
            let items = json["items"] as? [[String:Any]] else {
                return []
        }
        return items.compactMap(Item.init)
    }
}
