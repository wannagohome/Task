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
    
    let UserCell_Identifier: String = "UserCell"
    let LoadingCell_Identifier: String = "LoadingCell"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupTableView()
        setupNextPageLoading()
        showTableViewItems()
        checkSearchAvailable()
    }
    
    
    
    @objc func userCellAction(_ sender: UITapGestureRecognizer) {
        guard let view: UIView = sender.view,
        let url = URL(string: ViewModel.shared.users[view.tag].organizationsUrl ?? "") else {
            return
        }
        let index: Int = view.tag
        
        // 펼쳐져 있는 경우 다시 접음
        if ViewModel.shared.users[index].isExpanded {
            ViewModel.shared.users[index].isExpanded = false
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
                    
                    // 표시할 Organization이 없다면 UI에 변화를 주지 않음
                    if urls.isEmpty { return }
                    
                    ViewModel.shared.users[index].showOrganizationsWithURLs(urls: urls)
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
    }
    
    
    func foldIfExpanded(index: Int) {
        
    }
    
    
    
    func setupNextPageLoading() {
        tableView.rx.contentOffset
            .filter{ _ in
                self.tableView.isNearBottomEdge() &&
                ViewModel.shared.isNextPageLoading == false
            }
            .map{ _ in "nextPage"}
            .bind(to: ViewModel.shared.tableContentOffset)
            .disposed(by: disposeBag)
    }
    
    
    
    func setupSearchBar() {
        searchBar.rx.text.orEmpty
            .bind(to: ViewModel.shared.searchText)
            .disposed(by: disposeBag)
        
        // 영문과 숫자 외의 입력 방지
        ViewModel.shared.searchText
            .subscribe{
                if $0.element?.isAlphanumeric == false {
                    self.searchBar.text = String((self.searchBar.text?.dropLast()) ?? "")
                }
        }
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
        
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell_Identifier)
        tableView.register(LoadingCell.self, forCellReuseIdentifier: LoadingCell_Identifier)
    }
    
    
    
    func checkSearchAvailable() {
        ViewModel.shared.xRateRemain
            .filter{ $0 == 0 }
            .subscribe{ _ in
                self.searchController.isActive = false
                self.showAlert(message: """
                    분당 조회 가능 횟수(\(ViewModel.shared.xRateLimit)회) 초과
                    1분뒤 다시 시도해 주세요
                    """)
            }
            .disposed(by: disposeBag)
    }
    
    
    
    func showTableViewItems() {
        ViewModel.shared.dataSource.asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) { (tableView, index, userInfo) -> UITableViewCell in
                let indexPath = IndexPath(row: index, section: 0)
                
                // 셀 마지막에 activity indicator 표시
                if userInfo.isLoadingCell {
                    let cell = tableView.dequeueReusableCell(withIdentifier: self.LoadingCell_Identifier, for: indexPath) as! LoadingCell
                    cell.indicatorView.startAnimating()
                    
                    return cell
                }
              
                
                let cell: UserCell = tableView.dequeueReusableCell(withIdentifier: self.UserCell_Identifier, for: indexPath) as! UserCell
                
                cell.userNameLabel.text = userInfo.login
                cell.scoreLabel.text = "score: \((userInfo.score) ?? 0.0)"
                cell.profileImageView.kf.setImage(with: URL(string: (userInfo.avatarUrl ?? "")!))
                
                
                // Cell 재활용으로 인해 view가 깨는 현상 방지
                //    & imageview가 계속 쌓이는 현상 방지
                cell.stackView.subviews.forEach{
                    $0.removeFromSuperview()
                }
                
                if userInfo.isExpanded {
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
                }
                
                // Tag를 index로 활용
                cell.profileImageView.tag = index
                cell.userNameLabel.tag = index
                
                cell.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.userCellAction)))
                cell.userNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.userCellAction)))
                
                
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
