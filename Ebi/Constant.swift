//
//  Constant.swift
//  Created by macboy on 2022/08/01.
//

import Foundation
import UIKit

public func print(_ object: Any...){
    #if DEBUG
    for item in object {
        Swift.print(item)
    }
    #endif
}

public func print(_ object: Any){
    #if DEBUG
    Swift.print(object)
    #endif
}

extension UIScreen{
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}
