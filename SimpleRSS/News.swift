//
//  News.swift
//  SimpleRSS
//
//  Created by shuntaro on 2022/10/19.
//

import Foundation

struct News {
    var title: String
    var description: String
    var link: String
    init(_ title: String, link: String, description: String = "") {
        self.title = title
        self.description = description
        self.link = link
    }
}
