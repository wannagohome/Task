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
            // 데이터에 변화가 생길 때 마다 dataSource에 쏴주면서 최신화
            self.dataSource.onNext(users)
            isNextPageLoading = false
        }
    }
    
    
    init() {
        searchText.asObservable()
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe{ self.getUserList($0.element!) }
            .disposed(by: disposeBag)
        
        tableContentOffset.asObservable()
            .throttle(0.3, scheduler: MainScheduler.instance)
            .subscribe{ self.getUserList($0.element!) }
            .disposed(by: disposeBag)
    }
    
    
    
    var quarry: String = String();
    var isNextPageExist: Bool = true
    var isNextPageLoading: Bool = false
    var xRateRemain = BehaviorSubject<Int>(value: 9)
    var xRateLimit: Int = 10
    
    
    func getUserList(_ quarry: String) {
        guard !quarry.isEmpty else { return }
        
        if quarry == "nextPage" {
            guard isNextPageExist else { return }
            isNextPageLoading = true
            pageCount += 1
        } else {
            self.quarry = quarry
            pageCount = 1
            isNextPageExist = true
        }
        
        
        var result: [User] = []
        AF.request("https://api.github.com/search/users?q=\(self.quarry)&page=\(pageCount)", method: .get, encoding: JSONEncoding.default).responseJSON {
            (responds) in
            
            // 다음 페이지 존재 여부 확인
            let httpHeaders: String? =  responds.response?.allHeaderFields["Link"] as? String
            if !(httpHeaders?.contains("\"next\"") ?? false) { self.isNextPageExist = false }
            
            // 페이지 조회 가능 횟수 확인
            let xRate: String = responds.response?.allHeaderFields["X-RateLimit-Remaining"] as? String ?? "999"
            self.xRateRemain.onNext(Int(xRate)!)
            
            // 분당 페이지 조회 횟수 제한 확인
            let xRateLimit: String = responds.response?.allHeaderFields["X-RateLimit-Limit"] as? String ?? "10"
            self.xRateLimit = Int(xRateLimit)!
            
            // 검색 결과를 Array 형식으로 저장
            switch responds.result {
                
            case .success(let value):
                result = self.parse(json: value)
                
                if quarry == "nextPage" {
                    self.users.remove(at: self.users.count - 1)
                    self.users.append(contentsOf: result)
                } else {
                    self.users = result
                }
                
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
