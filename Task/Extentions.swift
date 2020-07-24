//
//  Extentions.swift
//  Task
//
//  Created by Peter Jang on 17/04/2019.
//  Copyright © 2019 Peter Jang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


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
