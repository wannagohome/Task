//
//  ViewController.swift
//  Task
//
//  Created by Peter Jang on 09/04/2019.
//  Copyright © 2019 Peter Jang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol ViewBindable {
    var searchText: PublishSubject<String> { get }
}

class ViewController: UIViewController {
    //MARK: - Constants
    let viewModel: ViewBindable
    let disposeBag = DisposeBag()
    
    //MARK: - Views
    let searchController = UISearchController(searchResultsController: nil)
    
    //MARK: - Life Cycle
    init(viewModel: ViewBindable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bind(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Bind
    func bind(viewModel: ViewBindable) {
        self.searchController.searchBar.rx.text.orEmpty
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
    }
}
