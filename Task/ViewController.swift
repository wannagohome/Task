//
//  ViewController.swift
//  Task
//
//  Created by Peter Jang on 09/04/2019.
//  Copyright © 2019 Peter Jang. All rights reserved.
//

import UIKit
import SwiftyJSON
import RxSwift
import RxCocoa

extension UIScrollView {
    func  isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
}

class ViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar { return searchController.searchBar }
    
    var viewModel = ViewModel()
    let disposeBag = DisposeBag()
    var isNextPageLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchController()
        
        
        view.addSubview(tableView)
        tableView.fillSuperview()
        
        viewModel.loaded.asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: "Cell")) { _, repository, cell in
                
                self.isNextPageLoading = false
                
                cell.textLabel?.text = repository.login
                cell.detailTextLabel?.text = repository.avatarUrl
            }
            .disposed(by: disposeBag)

        searchBar.rx.text.orEmpty
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        
        

        
        tableView.register(cell.self, forCellReuseIdentifier: "Cell")
        
//        let loadNextPageTrigger: (Driver<SearchUsersState>) -> Signal<()> = { state in
//            self.tableView.rx.contentOffset.asDriver()
//            .withLatestFrom(state)
//                .flatMap { state in
//                    return self.tableView.isNearBottomEdge() && !state.shouldLoadNextPage
//                    ? Signal.just(())
//                    : Signal.empty()
//            }
//        }
        
        
        tableView.rx.contentOffset
            .filter{ point in self.tableView.isNearBottomEdge(edgeOffset: 20.0) && !self.isNextPageLoading }
            .debounce(0.5, scheduler: MainScheduler.instance)
            .map{ "\($0.y )"}
            .bind(to: viewModel.loadNextPageTrigger)
            .disposed(by: disposeBag)

        
        
        
        
        viewModel.loadNextPageTrigger
            .subscribe{

                print($0)
        }
        .disposed(by: disposeBag)
        
        viewModel.searchText
            .subscribe{
                print($0)
        }
        .disposed(by: disposeBag)
        
//        searchBar.rx.text
//            .orEmpty
//            .distinctUntilChanged()
//            .filter { !$0.isEmpty }
//            .debounce(0.5, scheduler: MainScheduler.instance)
//            .map{query in
//                var apiUrl = URLComponents(string: "https://api.github.com/search/users")!
//                apiUrl.queryItems = [URLQueryItem(name: "q", value: query)]
//
//                return apiUrl.url!
//        }
//            .flatMapLatest{ url in
//                return URLSession.shared.rx.json(url: url)
//                .catchErrorJustReturn([])
//        }
//            .map{ json -> [Item] in
//                guard let json = json as? [String: Any],
//                    let items = json["items"] as? [[String:Any]] else {
//                        return []
//                }
//                return items.compactMap(Item.init)
//        }
//            .bind(to: tableView.rx.items){ tableView, row, repo in
//                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
//                cell.textLabel!.text = repo.login
//                return cell
//        }
//        .disposed(by: disposeBag)
        

    }
    
    
    
    
    func configureSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchBar.showsCancelButton = true
        searchBar.placeholder = "검색할 ID"
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
    }
    
    
}

class cell: UITableViewCell {

}


extension UIView {
    func fillSuperview() {
        anchor(top: superview?.safeAreaLayoutGuide.topAnchor, leading: superview?.leadingAnchor, bottom: superview?.safeAreaLayoutGuide.bottomAnchor, trailing: superview?.trailingAnchor)
    }
    
    func anchorSize(to view: UIView) {
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    
}
