//
//  listModel.swift
//  SQliteDid
//
//  Created by TJ on 2024/05/14.
//

import Foundation

struct SaveData{
    var id: Int
    var title: String
    var state: String
    var order: Int
    
    init(id: Int, title: String, state: String, order: Int) {
        self.id = id
        self.title = title
        self.state = state
        self.order = order
    }
    
}
