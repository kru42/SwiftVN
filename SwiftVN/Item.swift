//
//  Item.swift
//  SwiftVN
//
//  Created by Kru on 28/09/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
