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
    static var shared = ViewModel()
    let searchText = BehaviorRelay(value: "")
    let tableContentOffset =  BehaviorRelay(value: "")
    let disposeBag = DisposeBag()

    
    var dataSource: BehaviorSubject<[User]> = BehaviorSubject<[User]>(value: [])
    var pageCount: Int = 1

    var users:[User] = [] {
        didSet {
            self.dataSource.onNext(users)
        }
    }
    
    
    init() {
        searchText.asObservable()
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe{ self.getFirstPage($0.element!) }
            .disposed(by: disposeBag)
        
        tableContentOffset.asObservable()
            .throttle(0.3, scheduler: MainScheduler.instance)
            .subscribe{ self.getNextPage($0.element!) }
            .disposed(by: disposeBag)
    }
    
    
    
    var quarry: String = String();
    var isNextPageExist: Bool = true

    
    func getFirstPage(_ quarry: String) {
        guard !quarry.isEmpty else { return }
        self.quarry = quarry
        pageCount = 1
        isNextPageExist = true
        
        var result: [User] = []
        AF.request("https://api.github.com/search/users?q=\(quarry)", method: .get, encoding: JSONEncoding.default).responseJSON {
            (responds) in
            let pageStatus: String? =  responds.response?.allHeaderFields["Link"] as? String
            if !(pageStatus?.contains("\"next\"") ?? false) { self.isNextPageExist = false }
            
            switch responds.result {
                
            case .success(let value):
                result = self.parse(json: value)
                self.users = result
                if self.isNextPageExist {
                    self.users.append(User(true))
                }
                
                
            case .failure(let error):
                print(error.localizedDescription)
                
            }
        }
    }
    
    
    func getNextPage(_ pageNumber : String) {
        guard !pageNumber.isEmpty, isNextPageExist else { return }
        
        pageCount += 1
        
        var result: [User] = []
        AF.request("https://api.github.com/search/users?q=\(quarry)&page=\(pageCount)", method: .get, encoding: JSONEncoding.default).responseJSON {
            (responds) in
            let pageStatus: String? =  responds.response?.allHeaderFields["Link"] as? String
            if !(pageStatus?.contains("\"next\"") ?? false)  { self.isNextPageExist = false }
            
            switch responds.result {
        
            case .success(let value):
                result = self.parse(json: value)
                self.users.remove(at: self.users.count - 1)
                self.users.append(contentsOf: result)
                if self.isNextPageExist {
                    self.users.append(User(true))
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                
            }
        }
    }
    
    
    func parse(json: Any) -> [User] {
        guard let json = json as? [String: Any],
            let items = json["items"] as? [[String:Any]] else {
                return []
        }
        return items.compactMap(User.init)
    }
}
