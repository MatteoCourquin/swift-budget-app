import SwiftUI

struct ContentView: View {
    @State private var budgetItems: [BudgetItem] = [
        BudgetItem(name: "Épicerie", amount: 50.0, tags: ["Alimentation"], date: Date(timeIntervalSince1970: 1644962400), priority: "Medium", imageURL: "https://images.unsplash.com/photo-1692158962133-6c97ee651ab9?q=80&w=2960&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
        BudgetItem(name: "Factures", amount: 100.0, tags: ["Services"], date: Date(timeIntervalSince1970: 1643344800), priority: "High", imageURL: "https://images.unsplash.com/photo-1679810394015-c995ae9d5417?q=80&w=2604&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
        BudgetItem(name: "Loisirs", amount: 30.0, tags: ["Divertissement"], date: Date(timeIntervalSince1970: 1642586400), priority: "Low", imageURL: "https://images.unsplash.com/photo-1680789526837-4876e651fe52?q=80&w=2833&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
        BudgetItem(name: "Moto", amount: 1000.0, tags: ["Moto"], date: Date(timeIntervalSince1970: 1642586400), priority: "Low", imageURL: "https://images.unsplash.com/photo-1650355984865-9ed9377f1a6c?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
    ]
    @State private var isAddItemViewPresented: Bool = false
    @State private var selectedPriority: String = "All"
    
    var filteredItems: [BudgetItem] {
        if selectedPriority == "All" {
            return budgetItems
        } else {
            return budgetItems.filter { $0.priority == selectedPriority }
        }
    }
    
    var totalAmount: Double {
        filteredItems.reduce(0) { $0 + $1.amount }
    }
    
    var formattedTotalAmount: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: NSNumber(value: totalAmount)) ?? ""
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Picker("Filtrer par priorité", selection: $selectedPriority) {
                        Text("All").tag("All")
                        Text("Medium").tag("Medium")
                        Text("High").tag("High")
                        Text("Low").tag("Low")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(4)
                    ForEach(filteredItems) { item in
                        NavigationLink(destination: DetailView(item: item, budgetItems: $budgetItems)) {
                            HStack {
                                AsyncImage(url: URL(string: item.imageURL!)){
                                    image in image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Rectangle()
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 50, height: 50)
                                .cornerRadius(.infinity)
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(item.name)
                                        Text((formattedDate(item.date)))
                                            .foregroundColor(.gray)
                                            .italic()
                                            .font(.caption)
                                    }
                                    if !item.tags.isEmpty {
                                        HStack {
                                            ForEach(item.tags, id: \.self) { tag in
                                                Text(tag)
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                                            }
                                        }
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(String(format: "%.2f", item.amount) + " €")
                                    PriorityDotView(priority: item.priority)
                                }
                            }
                        }
                        .swipeActions {
                            Button {
                                deleteItem(item)
                            } label: {
                                Label("Supprimer", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                    }
                    .onDelete { indexSet in
                        deleteItems(at: indexSet)
                    }
                    .onMove { indices, newOffset in
                        budgetItems.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
            }
            .navigationTitle("Budget")
            .navigationBarItems(
                leading: EditButton(),
                trailing: Button {
                    isAddItemViewPresented = true
                } label: {
                    Label("Ajouter", systemImage: "plus.circle")
                }
                    .sheet(isPresented: $isAddItemViewPresented) {
                        AddItemView(isPresented: $isAddItemViewPresented, budgetItems: $budgetItems)
                    }
            )
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        Text("Total • \(formattedTotalAmount) €")
                            .font(.headline)
                    }
                }
            }
        }
    }
    
    func deleteItem(_ item: BudgetItem) {
        if let index = budgetItems.firstIndex(where: { $0.id == item.id }) {
            budgetItems.remove(at: index)
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        budgetItems.remove(atOffsets: offsets)
    }
    
    func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
