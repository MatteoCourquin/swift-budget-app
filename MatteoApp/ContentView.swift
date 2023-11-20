import SwiftUI

struct BudgetItem: Identifiable {
    var id = UUID()
    var name: String
    var amount: Double
    var tags: [String]
    var date: Date
}

struct AddItemView: View {
    @Binding var isPresented: Bool
    @Binding var budgetItems: [BudgetItem]
    @State private var newItemName: String = ""
    @State private var newItemAmount: String = ""
    @State private var selectedTag: String = ""
    @State private var selectedDate = Date()
    let availableTags = ["Alimentation", "Services", "Divertissement", "Loisirs", "Épicerie", "Transport", "Factures", "Cadeaux", "Santé"]

    var body: some View {
        VStack {
            Text("Nouvel élément")
                .font(.title)
                .padding()

            VStack(alignment: .leading, spacing: 8) {
                Text("Nom de l'élément:")
                TextField("", text: $newItemName)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Montant:")
                TextField("", text: $newItemAmount)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    .keyboardType(.decimalPad)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Tag:")
                Picker("Sélectionnez un tag", selection: $selectedTag) {
                    ForEach(availableTags, id: \.self) { tag in
                        Text(tag)
                    }
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                .frame(maxWidth: .infinity)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Date:")
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                Spacer()
            }
            
            Spacer()

            HStack {
                Button("Annuler") {
                    isPresented = false
                }
                .padding(10)

                Button("Ajouter") {
                    addItem()
                }
                .padding(10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
            }
        }
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
        .padding()
    }

    func addItem() {
        guard let amount = Double(newItemAmount) else { return }
        let newItem = BudgetItem(name: newItemName, amount: amount, tags: [selectedTag], date: selectedDate)
        budgetItems.append(newItem)
        print("Nom: \(newItemName), Montant: \(amount), Tag: \(selectedTag), Date: \(selectedDate)")
        isPresented = false
    }
}


struct ContentView: View {
    @State private var budgetItems: [BudgetItem] = [
        BudgetItem(name: "Épicerie", amount: 50.0, tags: ["Alimentation", "Santé"], date: Date(timeIntervalSince1970: 1644962400)),
        BudgetItem(name: "Factures", amount: 100.0, tags: ["Services"], date: Date(timeIntervalSince1970: 1643344800)),
        BudgetItem(name: "Loisirs", amount: 30.0, tags: ["Divertissement"], date: Date(timeIntervalSince1970: 1642586400)),
    ]
    @State private var isAddItemViewPresented: Bool = false

    var totalAmount: Double {
        budgetItems.reduce(0) { $0 + $1.amount }
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
            List {
                ForEach(budgetItems) { item in
                    VStack {
                        HStack {
                            Text(item.name)
                            Text((formattedDate(item.date)))
                                .foregroundColor(.gray)
                                .italic()
                                .font(.caption)
                            Spacer()
                            Text(String(format: "%.2f", item.amount) + " €")
                                .contextMenu {
                                    Button(action: {
                                        deleteItem(item)
                                    }) {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
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
                                Spacer()
                            }
                            .padding(.vertical, 0)
                        }
                    }
                }.onDelete(perform: deleteItems)
            }
            .listStyle(.plain)
            .navigationTitle("Budget")
            .navigationBarItems(
                trailing: Button("Ajouter") {
                    isAddItemViewPresented = true
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
                            .padding(.vertical, 8.0)
                            .padding(.horizontal, 16.0)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
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
