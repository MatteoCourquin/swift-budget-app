import SwiftUI

struct EditViewData {
    var name: String
    var amount: String
    var imageURL: String
    var tag: String
    var date: Date
    var priority: String
}

struct EditView: View {
    @Binding var isPresented: Bool
    @Binding var budgetItems: [BudgetItem]
    var itemToEdit: BudgetItem
    
    @State private var editData: EditViewData
    
    let availableTags = ["Alimentation", "Services", "Divertissement", "Loisirs", "Épicerie", "Transport", "Factures", "Cadeaux", "Santé", "Moto", "Sport", "Amis"]
    
    init(isPresented: Binding<Bool>, budgetItems: Binding<[BudgetItem]>, itemToEdit: BudgetItem) {
        _isPresented = isPresented
        _budgetItems = budgetItems
        self.itemToEdit = itemToEdit
        
        _editData = State(initialValue: EditViewData(
            name: itemToEdit.name,
            amount: String(itemToEdit.amount),
            imageURL: itemToEdit.imageURL ?? "",
            tag: itemToEdit.tags.first ?? "",
            date: itemToEdit.date,
            priority: itemToEdit.priority
        ))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ticket de caisse")) {
                    AsyncImage(url: URL(string: editData.imageURL)){
                        image in image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.gray)
                    }
                    .frame(width: 300, height: 300)
                    .padding()
                    
                    TextField("URL de l'image", text: $editData.imageURL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                }
                
                Section(header: Text("Informations de la dépense")) {
                    TextField("Nom de l'élément", text: $editData.name)
                    TextField("Montant", text: $editData.amount)
                        .keyboardType(.decimalPad)
                    Picker("Sélectionnez un tag", selection: $editData.tag) {
                        ForEach(availableTags, id: \.self) { tag in
                            Text(tag)
                        }
                    }
                }
                
                Section(header: Text("Autres")) {
                    Picker("Sélectionnez une priorité", selection: $editData.priority) {
                        Text("High").tag("High")
                        Text("Medium").tag("Medium")
                        Text("Low").tag("Low")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    DatePicker("Date de la dépense", selection: $editData.date, displayedComponents: .date)
                }
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            .navigationTitle("Modifier la dépense")
            .navigationBarItems(
                leading: Button("Fermer") {
                    isPresented = false
                },
                trailing: Button("Enregistrer") {
                    saveChanges()
                }
            )
        }
    }
    
    func saveChanges() {
        guard let amount = Double(editData.amount) else { return }
        
        var editedItem = itemToEdit
        editedItem.name = editData.name
        editedItem.amount = amount
        editedItem.imageURL = editData.imageURL.isEmpty ? "URL_PAR_DEFAUT" : editData.imageURL
        editedItem.tags = [editData.tag]
        editedItem.date = editData.date
        editedItem.priority = editData.priority
        
        if let index = budgetItems.firstIndex(where: { $0.id == itemToEdit.id }) {
            budgetItems[index] = editedItem
            isPresented = false
        } else {
            print("Item NOT found in the array")
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(isPresented: .constant(true), budgetItems: .constant([]), itemToEdit: BudgetItem(name: "Tennis", amount: 350.0, tags: ["Loisirs"], date: Date(), priority: "High", imageURL: "https://images.unsplash.com/photo-1554068865-24cecd4e34b8?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"))
    }
}
