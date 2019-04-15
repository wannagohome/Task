//
//  ViewModel.swift
//  Task
//
//  Created by Peter Jang on 09/04/2019.
//  Copyright © 2019 Peter Jang. All rights reserved.
//

import RxSwift
import RxCocoa
import Alamofire

class ViewModel {
    
    let searchText = BehaviorRelay(value: "")
    let loadNextPageTrigger =  BehaviorRelay(value: "")
    let disposeBag = DisposeBag()

    
    var loaded: BehaviorSubject<[User]> = BehaviorSubject<[User]>(value: [])
    var pageCount: Int = 1

    var user:[User] = [] {
        didSet {
            self.loaded.onNext(user)
        }
    }
    init() {
        searchText.asObservable()
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe{ self.loadFirstPage($0.element!) }
            .disposed(by: disposeBag)
        
        loadNextPageTrigger.asObservable()
            .throttle(0.3, scheduler: MainScheduler.instance)
            .subscribe{ self.loadNextPage($0.element!) }
            .disposed(by: disposeBag)
    }
    
    
    var quarry: String = String();
    var isNextPageExist: Bool = true

    
    func loadFirstPage(_ quarry: String) {
        guard !quarry.isEmpty else { return }
        self.quarry = quarry
        pageCount = 2
        isNextPageExist = true
        
        var result: [User] = []
        AF.request("https://api.github.com/search/users?q=\(quarry)", method: .get, encoding: JSONEncoding.default).responseJSON {
            (responds) in
            switch responds.result {
                
            case .success(let value):
                result = self.parse(json: value)
                self.user = result
                
            case .failure(let error):
                print(error.localizedDescription)
                
            }
        }
        return
    }
    
    
    func loadNextPage(_ pageNumber : String) {
        guard !pageNumber.isEmpty, isNextPageExist else { return }
        
        var result: [User] = []
        AF.request("https://api.github.com/search/users?q=\(quarry)&page=\(pageCount)", method: .get, encoding: JSONEncoding.default).responseJSON {
            (responds) in
            let pageStatus: String =  responds.response?.allHeaderFields["Link"] as! String
            if pageStatus.contains("\"next\"") { self.isNextPageExist = false }
            
            switch responds.result {
        
            case .success(let value):
                result = self.parse(json: value)
                self.user.append(contentsOf: result)
                
            case .failure(let error):
                print(error.localizedDescription)
                
            }
        }
        return
    }
    
    
    func parse(json: Any) -> [User] {
        guard let json = json as? [String: Any],
            let items = json["items"] as? [[String:Any]] else {
                return []
        }
        return items.compactMap(User.init)
    }
}
