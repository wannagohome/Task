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
    
    var viewModel = ViewModel()
    let disposeBag = DisposeBag()
    var isNextPageLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchController()
        
        
        view.addSubview(tableView)
        tableView.fillSuperview()
        viewModel.loaded.asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) { (tableView, index, userInfo) -> UITableViewCell in
                let indexPath = IndexPath(row: index, section: 0)
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserCell
                cell.user = userInfo
                return cell
        }
        .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        
        

        
        tableView.register(UserCell.self, forCellReuseIdentifier: "Cell")
    
        
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
      
        

    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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

class UserCell: UITableViewCell {
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        return imageView
    }()
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "score: "
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        return label
    }()
    
    var user: User? {
        didSet {
            userNameLabel.text = user?.login
            scoreLabel.text!.append(String(format: "%.5f", (user?.score) ?? 0.0))
            
            
            profileImageView.kf.setImage(with: URL(string: (user?.avatarUrl)!))
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
