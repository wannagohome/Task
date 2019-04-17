//
//  LoadingCell.swift
//  Task
//
//  Created by Peter Jang on 17/04/2019.
//  Copyright © 2019 Peter Jang. All rights reserved.
//

import UIKit

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
