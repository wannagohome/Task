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

extension UIScrollView {
    func  isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
}

class ViewController: UIViewController, UITableViewDelegate {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.separatorColor = UIColor.clear
        return tableView
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar { return searchController.searchBar }
    
    let disposeBag = DisposeBag()
    var isNextPageLoading: Bool = false
    var userCell: [UserCell] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchController()
        
        
        view.addSubview(tableView)
        tableView.fillSuperview()
        ViewModel.shared.loaded.asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) { (tableView, index, userInfo) -> UITableViewCell in
                let indexPath = IndexPath(row: index, section: 0)
                if userInfo.isLoadingCell {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "footer", for: indexPath) as! LoadingCell
                    cell.indicatorView.startAnimating()
                    
                    return cell
                }
                let cell: UserCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? UserCell ?? UserCell()
                cell.user = userInfo
                cell.index = index
                return cell
                
                
        }
        .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .bind(to: ViewModel.shared.searchText)
            .disposed(by: disposeBag)
        
        
        tableView.register(UserCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(LoadingCell.self, forCellReuseIdentifier: "footer")
        
        tableView.rx.contentOffset
            .filter{ point in self.tableView.isNearBottomEdge(edgeOffset: 20.0) && !self.isNextPageLoading }
            .debounce(0.5, scheduler: MainScheduler.instance)
            .map{ "\($0.y )"}
            .bind(to: ViewModel.shared.loadNextPageTrigger)
            .disposed(by: disposeBag)
    

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isExpanded = ViewModel.shared.user[indexPath.row].isExpanded
        if isExpanded {
            return 143
        }
        return 100
    }
    
    func configureSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchBar.showsCancelButton = true
        searchBar.placeholder = "검색할 ID"
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
    }
    
    
}

class LoadingCell: UITableViewCell {
    let indicatorView = UIActivityIndicatorView(style: .gray)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(indicatorView)
        indicatorView.fillSuperview()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class UserCell: UITableViewCell {
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.isUserInteractionEnabled = true
        return label
    }()
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        return label
    }()
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        return stackView
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    var organizationsUrl: String?
    var organizationAvatarUrls: [String] = [] {
        didSet {
            showOrganizationAvatar()
        }
    }
    var index: Int = 0
    
    
    var user: User? {
        didSet {
            userNameLabel.text = user?.login
            scoreLabel.text = "score: \((user?.score) ?? 0.0)"
            profileImageView.kf.setImage(with: URL(string: (user?.avatarUrl)!))
            organizationsUrl = user?.organizationsUrl
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        
    }
    
    
    func setupViews() {
        addSubview(profileImageView)
        addSubview(userNameLabel)
        addSubview(scoreLabel)
        
        
        profileImageView.anchor(top: contentView.topAnchor,
                                leading: contentView.leadingAnchor,
                                bottom: nil,
                                trailing: nil,
                                padding: .init(top: 25, left: 25, bottom: 0, right: 0),
                                size: .init(width: 50, height: 50))
        userNameLabel.anchor(top: profileImageView.topAnchor,
                             leading: profileImageView.trailingAnchor,
                             bottom: nil,
                             trailing: nil,
                             padding: .init(top: 0, left: 5, bottom: 0, right: 0))
        scoreLabel.anchor(top: userNameLabel.bottomAnchor,
                          leading: userNameLabel.leadingAnchor,
                          bottom: contentView.bottomAnchor,
                          trailing: nil,
                          padding: .init(top: 3, left: 0, bottom: 0, right: 0))
        
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(getOrganizationAvatarURLs)))
        userNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(getOrganizationAvatarURLs)))
    }
    
    func showOrganizationAvatar() {
        organizationAvatarUrls.forEach{
            let avatarImageView = UIImageView()
            avatarImageView.clipsToBounds = true
            avatarImageView.translatesAutoresizingMaskIntoConstraints  = false
            avatarImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            avatarImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            avatarImageView.contentMode = UIView.ContentMode.scaleAspectFit
            avatarImageView.layer.cornerRadius = 20
            avatarImageView.kf.setImage(with: URL(string: $0))
            
            stackView.addArrangedSubview(avatarImageView)
        }
        addSubview(scrollView)
        scrollView.anchor(top: profileImageView.bottomAnchor,
                         leading: profileImageView.leadingAnchor,
                         bottom: nil,
                         trailing: contentView.trailingAnchor,
                         padding: .init(top: 5, left: 0, bottom: 0, right: 25),
                         size: .init(width: contentView.bounds.width - 50, height: 40))
        
        scrollView.addSubview(stackView)
        stackView.anchor(top: scrollView.topAnchor,
                         leading: scrollView.leadingAnchor,
                         bottom: scrollView.bottomAnchor,
                         trailing: scrollView.trailingAnchor)
        scrollView.showsHorizontalScrollIndicator = false
        ViewModel.shared.user[index].isExpanded = true
    }
    
    @objc func getOrganizationAvatarURLs() {
        guard let url = URL(string: organizationsUrl ?? ""),
            ViewModel.shared.user[index].isExpanded == false else {
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
                    self.organizationAvatarUrls = urls
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

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
