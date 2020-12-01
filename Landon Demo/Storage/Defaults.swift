//
//  UserDefaults.swift
//  LandonDemo
//
//  Created by Jack Mousseau on 11/30/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

import Foundation

public struct Defaults {

    static var exportDirectory: Data? {
        get { UserDefaults.standard.data(forKey: #function) }
        set { UserDefaults.standard.setValue(newValue, forKey: #function) }
    }

}
