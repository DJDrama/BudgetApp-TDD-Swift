//
//  Expense.swift
//  BudgetApp
//
//  Created by Dongjun Lee on 11/10/24.
//

import Foundation
import SwiftData

@Model
class Expense {
    var name: String
    var price: Double
    var quantity: Int
    
    var budget: Budget?
    
    init(name: String, price: Double, quantity: Int) {
        self.name = name
        self.price = price
        self.quantity = quantity
    }
}
