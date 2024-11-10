//
//  BudgetAppTests.swift
//  BudgetAppTests
//
//  Created by Dongjun Lee on 11/10/24.
//

import XCTest
import SwiftData
@testable import BudgetApp

final class TDDBudgetAppTests: XCTestCase {
    
    private var container: ModelContainer!
    private var context: ModelContext!
    
    @MainActor
    override func setUp() { // equal to @BeforeEach in JVM
        container = try! ModelContainer(for: Budget.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        context = container.mainContext // @MainActor Needed
    }
    
    // BAD Test - what is the point of this test?
    func testItemAddedToAnArray() {
        var customers: [String] = []
        let name = "John"
        
        customers.append(name)
        
        XCTAssertTrue(customers.count == 1)
    }
    
    // BAD Test - this is testing the framework, not any business rules
    @MainActor
    func testBudgetCreate() throws {
        
        let budget = Budget(name: "Groceries", limit: 500)
        context.insert(budget)
        
        // fetch the budget
        let fetchDescriptor = FetchDescriptor<Budget>(predicate: #Predicate { $0.name == "Groceries" })
        let budgets: [Budget] = try context.fetch(fetchDescriptor)
        
        guard let savedBudget = budgets.first else {
            XCTFail("Unable to get the budget.")
            return
        }
        
        XCTAssertEqual("Groceries", savedBudget.name)
        XCTAssertEqual(500, savedBudget.limit)
        
    }
    
    
    // throw duplicate name exception when saving budget with the same name twice
    @MainActor
    func testThrowDuplicateNameExceptionWhenSavingBudgetWithSameNameTwice() {
        
        let budget = Budget(name: "Groceries", limit: 500)
        context.insert(budget)
        
        // create another budget with the same name
        let anotherBudget = Budget(name: "Groceries", limit: 250)
        
        XCTAssertThrowsError(try anotherBudget.save(context: context)) { error in
            let thrownError = error as? BudgetError
            XCTAssertNotNil(thrownError)
            XCTAssertEqual(BudgetError.duplicateName, thrownError)
        }
    }
    
    @MainActor
    func testCalculateBudgetExpensesTotal() throws {
        
        let budget = Budget(name: "Groceries", limit: 500)
        try! budget.save(context: context)
        
        let expenses = [
            Expense(name: "Milk", price: 4.50, quantity: 2),
            Expense(name: "Bread", price: 5, quantity: 10)
        ]
        budget.expenses = expenses
        
        XCTAssertEqual(59, budget.spent)
    }
    
    @MainActor
    func testCalculateBudgetRemainingTotal() throws {
        
        let budget = Budget(name: "Groceries", limit: 500)
        try! budget.save(context: context)
        
        let expenses = [
            Expense(name: "Milk", price: 4.50, quantity: 2),
            Expense(name: "Bread", price: 5, quantity: 10)
        ]
        budget.expenses = expenses
        
        // 500 - 49
        XCTAssertEqual(441, budget.remaining)
    }
    
    override func tearDown() { // Equal to @AfterEach in JVM
        
    }
}
