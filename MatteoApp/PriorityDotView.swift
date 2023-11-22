import SwiftUI

struct PriorityDotView: View {
    var priority: String
    
    func colorForPriority(_ priority: String) -> Color {
        switch priority {
        case "High":
            return Color.red
        case "Medium":
            return Color.yellow
        case "Low":
            return Color.green
        default:
            return Color.gray
        }
    }
    
    var body: some View {
        Circle()
            .fill(colorForPriority(priority))
            .frame(width: 10, height: 10)
    }
}
