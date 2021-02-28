//
//  Checklist.swift
//  Checklists
//
//  Created by Eduardo Martin Lorenzo on 03/02/2021.
//

import UIKit

class Checklist: NSObject, Codable {
    var name = ""
    var items = [ChecklistItem]()
    var iconName = "No Icon"
    
    init(name: String, iconName: String = "No Icon") {
        super.init()
        self.name = name
        self.iconName = iconName
    }
    
    func countUncheckedItems() -> Int {
        /*
        var count = 0
        for item in items where !item.checked {
            count += 1
        }
        return count*/
        // reduce() analiza cada elemento del array, crea una variable 'cnt' y le suma 1 a cnt si el item.checked es false
        return items.reduce(0) { cnt, item in cnt + (item.checked ? 0 : 1)}
    }
}
