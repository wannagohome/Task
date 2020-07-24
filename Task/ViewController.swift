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
import Then
import SnapKit

protocol ViewBindable {
    var searchText: PublishSubject<String> { get }
    var loadNext: PublishSubject<Void> { get }
    
    var cellData: Driver<[UserList]> { get }
}

class ViewController: UIViewController {
    //MARK: - Constants
    let viewModel: ViewBindable
    let disposeBag = DisposeBag()
    
    //MARK: - Views
    let searchController = UISearchController(searchResultsController: nil)
    let tableView = UITableView(frame: .zero, style: .plain)
    
    //MARK: - Life Cycle
    init(viewModel: ViewBindable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bind(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
        layout()
    }
    
    //MARK: - Bind
    private func bind(viewModel: ViewBindable) {
        self.searchController.searchBar.rx.text.orEmpty
            .debounce(.milliseconds(5), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filterEmpty()
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        
        viewModel.cellData
            .drive(tableView.rx.items) { tb, row, data in
                let cell = tb.dequeueReusableCell(withIdentifier: UserCell.description(), for: IndexPath(row: row, section: 0)) as! UserCell
                cell.setData(data)
                return cell
        }
        .disposed(by: disposeBag)
        
        self.tableView.rx.isReachedBottom
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .bind(to: viewModel.loadNext)
            .disposed(by: disposeBag)
    }
    
    private func layout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { m in
            m.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func attribute() {
        tableView.do {
            $0.rowHeight = 60
            $0.tableHeaderView = searchController.searchBar
            $0.register(UserCell.self, forCellReuseIdentifier: UserCell.description())
        }
    }
}

extension Reactive where Base: UIScrollView {
  var isReachedBottom: ControlEvent<Void> {
    let source = self.contentOffset
      .filter { [weak base = self.base] offset in
        guard let base = base else { return false }
        return base.contentOffset.y + 1 >= (base.contentSize.height - base.frame.size.height)
      }
      .map { _ in Void() }
    return ControlEvent(events: source)
  }
}
