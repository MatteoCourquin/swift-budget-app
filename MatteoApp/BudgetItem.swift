import SwiftUI

struct BudgetItem: Identifiable {
    var id = UUID()
    var name: String
    var amount: Double
    var tags: [String]
    var date: Date
    var priority: String
    var imageURL: String?
    
    init(name: String, amount: Double, tags: [String], date: Date, priority: String, imageURL: String? = nil) {
        self.name = name
        self.amount = amount
        self.tags = tags
        self.date = date
        self.priority = priority
        self.imageURL = imageURL
    }
}
