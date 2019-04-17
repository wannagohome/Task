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
import Alamofire
import Kingfisher



class ViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.separatorColor = UIColor.clear
        return tableView
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar { return searchController.searchBar }
    
    let disposeBag = DisposeBag()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupTableView()
        setupNextPageLoading()
        driveToTableViewItems()
        
        ViewModel.shared.tableContentOffset
            .subscribe{
                print($0)
        }
        .disposed(by: disposeBag)
    }
    
    
    @objc func showOrganizationAvatarURLs(_ sender: UITapGestureRecognizer) {
        guard let view: UIView = sender.view  else {
            return
        }
        let index: Int = view.tag
        guard let url = URL(string: ViewModel.shared.users[index].organizationsUrl ?? ""),
            ViewModel.shared.users[index].isExpanded == false else {
                return
        }
        AF.request(url, method: .get, encoding: JSONEncoding.default)
            .responseJSON{ (response) in
                
                switch response.result {
                    
                case .success(let value):
                    let json = JSON(value)
                    var urls: [String] = []
                    json.forEach { (_, org) in
                        urls.append(org["avatar_url"].stringValue)
                        
                    }
                    ViewModel.shared.users[index].organizationAvatarUrls = urls
                    ViewModel.shared.users[index].isExpanded = true
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
    }
    
    
    
    
    func setupNextPageLoading() {
        tableView.rx.contentOffset
            .filter{ _ in
                self.tableView.isNearBottomEdge(edgeOffset: 20.0) &&
                ViewModel.shared.isNextPageLoading == false
            }
            .map{ _ in
                "nextPage"}
            .bind(to: ViewModel.shared.tableContentOffset)
            .disposed(by: disposeBag)
    }
    
    
    
    func setupSearchBar() {
        searchBar.rx.text.orEmpty
            .bind(to: ViewModel.shared.searchText)
            .disposed(by: disposeBag)
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchBar.showsCancelButton = true
        searchBar.placeholder = "검색할 ID"
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
    }
    
    
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.fillSuperview()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(LoadingCell.self, forCellReuseIdentifier: "footer")
    }
    
    
    
    func driveToTableViewItems() {
        ViewModel.shared.dataSource.asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) { (tableView, index, userInfo) -> UITableViewCell in
                let indexPath = IndexPath(row: index, section: 0)
                if userInfo.isLoadingCell {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "footer", for: indexPath) as! LoadingCell
                    cell.indicatorView.startAnimating()
                    
                    return cell
                }
                
                let cell: UserCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                    as? UserCell ?? UserCell(style: .default, reuseIdentifier: "Cell")
                
                
                cell.userNameLabel.text = userInfo.login
                cell.scoreLabel.text = "score: \((userInfo.score) ?? 0.0)"
                cell.profileImageView.kf.setImage(with: URL(string: (userInfo.avatarUrl ?? "")!))
                
                cell.stackView.subviews.forEach{
                    $0.removeFromSuperview()
                }
                
                userInfo.organizationAvatarUrls.forEach{
                    let avatarImageView = UIImageView()
                    avatarImageView.clipsToBounds = true
                    avatarImageView.translatesAutoresizingMaskIntoConstraints  = false
                    avatarImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
                    avatarImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
                    avatarImageView.contentMode = UIView.ContentMode.scaleAspectFit
                    avatarImageView.layer.cornerRadius = 20
                    avatarImageView.kf.setImage(with: URL(string: $0), placeholder: UIImage())
                    
                    cell.stackView.addArrangedSubview(avatarImageView)
                }
                
                cell.profileImageView.tag = index
                cell.userNameLabel.tag = index
                
                cell.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showOrganizationAvatarURLs)))
                cell.userNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showOrganizationAvatarURLs)))
                
                
                return cell
            }
            .disposed(by: disposeBag)
    }
}


extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isExpanded = ViewModel.shared.users[indexPath.row].isExpanded
        if isExpanded {
            return 143
        }
        return 100
    }
}
