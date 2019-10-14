//
//  ThemeProtocol.swift
//  Assignment2
//
//  Created by Ayaz Rahman on 3/10/19.
//  Copyright © 2019 M Rahman. All rights reserved.
//

import UIKit

protocol ThemeProtocol {
    var primary: UIColor {get}
    var text: UIColor {get}
    var barStyle: UIStatusBarStyle {get}
}
