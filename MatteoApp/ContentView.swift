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



struct AddItemView: View {
    @Binding var isPresented: Bool
    @Binding var budgetItems: [BudgetItem]
    @State private var newItemName: String = ""
    @State private var newItemAmount: String = ""
    @State private var newItemImage: String = ""
    @State private var selectedTag: String = ""
    @State private var selectedDate = Date()
    @State private var selectedPriority: String = "Medium"
    let availableTags = ["Alimentation", "Services", "Divertissement", "Loisirs", "Épicerie", "Transport", "Factures", "Cadeaux", "Santé", "Moto", "Sport", "Amis"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ticket de caisse")) {
                    if let imageURL = URL(string: newItemImage), let image = try? Data(contentsOf: imageURL) {
                        Image(uiImage: UIImage(data: image)!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300)
                            .padding()
                    } else {
                        Rectangle()
                            .foregroundColor(.gray)
                            .frame(width: 300, height: 300)
                            .padding()
                    }
                    TextField("URL de l'image", text: $newItemImage)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                }
                
                Section(header: Text("Informations de la dépense")) {
                    TextField("Nom de l'élément", text: $newItemName)
                    TextField("Montant", text: $newItemAmount)
                        .keyboardType(.decimalPad)
                    Picker("Sélectionnez un tag", selection: $selectedTag) {
                        ForEach(availableTags, id: \.self) { tag in
                            Text(tag)
                        }
                    }
                }
                
                Section(header: Text("Autres")) {
                    Picker("Sélectionnez une priorité", selection: $selectedPriority) {
                        Text("High").tag("High")
                        Text("Medium").tag("Medium")
                        Text("Low").tag("Low")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    DatePicker("Date de la dépense", selection: $selectedDate, displayedComponents: .date)
                }
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            .navigationTitle("Nouvelle dépense")
            .navigationBarItems(trailing: Button("Fermer") {
                isPresented = false
            })
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Ajouter") {
                        addItem()
                    }
                }
            }
        }
    }
    
    func addItem() {
        guard let amount = Double(newItemAmount) else { return }
        let newItem = BudgetItem(name: newItemName, amount: amount, tags: [selectedTag], date: selectedDate, priority: selectedPriority, imageURL: newItemImage)
        budgetItems.append(newItem)
        print("Nom: \(newItemName), Montant: \(amount), Tags: \(selectedTag), Date: \(selectedDate), Priorité: \(selectedPriority), Image: \(newItemImage)")
        isPresented = false
    }
}



struct DetailView: View {
    var item: BudgetItem
    @State private var isEditViewPresented = false
    @State private var imageData: Data?

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: item.imageURL ?? "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Placeholder_view_vector.svg/1362px-Placeholder_view_vector.svg.png")) {
                image in image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .foregroundColor(.gray)
            }
            .frame(width: 300, height: 300)
            .padding()

            HStack {
                Text(item.name)
                    .font(.title)
                PriorityDot(priority: item.priority)
            }

            Text("Montant: \(String(format: "%.2f", item.amount)) €")
                .foregroundColor(.gray)
                .italic()
                .font(.caption)

            if !item.tags.isEmpty {
                HStack {
                    Spacer()
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

            if !item.priority.isEmpty {
                Text("Priorité: \(item.priority)")
                    .font(.caption)
                    .foregroundColor(.black)
            }
            Spacer()
            Button(action: {
                isEditViewPresented.toggle()
            }) {
                Label("Modifier", systemImage: "pencil")
            }
            .sheet(isPresented: $isEditViewPresented) {
                EditView(isPresented: $isEditViewPresented, budgetItems: .constant([]), itemToEdit: item)
            }
        }
        .padding()
        .navigationTitle(item.name)
    }
}



struct PriorityDot: View {
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



struct ContentView: View {
    @State private var budgetItems: [BudgetItem] = [
        BudgetItem(name: "Épicerie", amount: 50.0, tags: ["Alimentation", "Santé"], date: Date(timeIntervalSince1970: 1644962400), priority: "Medium", imageURL: "https://images.unsplash.com/photo-1692158962133-6c97ee651ab9?q=80&w=2960&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
        BudgetItem(name: "Factures", amount: 100.0, tags: ["Services"], date: Date(timeIntervalSince1970: 1643344800), priority: "High", imageURL: "https://images.unsplash.com/photo-1679810394015-c995ae9d5417?q=80&w=2604&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
        BudgetItem(name: "Loisirs", amount: 30.0, tags: ["Divertissement"], date: Date(timeIntervalSince1970: 1642586400), priority: "Low", imageURL: "https://images.unsplash.com/photo-1680789526837-4876e651fe52?q=80&w=2833&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
        BudgetItem(name: "Moto", amount: 1000.0, tags: ["Moto", "Sport"], date: Date(timeIntervalSince1970: 1642586400), priority: "Low", imageURL: "https://images.unsplash.com/photo-1650355984865-9ed9377f1a6c?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
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
                        NavigationLink(destination: DetailView(item: item)) {
                            HStack {
                                AsyncCoverImage(url: URL(string: item.imageURL ?? "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Placeholder_view_vector.svg/1362px-Placeholder_view_vector.svg.png"))
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
                                    PriorityDot(priority: item.priority)
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


struct EditView: View {
    @Binding var isPresented: Bool
    @Binding var budgetItems: [BudgetItem]
    var itemToEdit: BudgetItem

    @State private var editedItem: BudgetItem
    @State private var newItemName: String
    @State private var newItemAmount: String
    @State private var newItemImage: String
    @State private var selectedTag: String
    @State private var selectedDate: Date
    @State private var selectedPriority: String

    let availableTags = ["Alimentation", "Services", "Divertissement", "Loisirs", "Épicerie", "Transport", "Factures", "Cadeaux", "Santé", "Moto", "Sport", "Amis"]

    init(isPresented: Binding<Bool>, budgetItems: Binding<[BudgetItem]>, itemToEdit: BudgetItem) {
        _isPresented = isPresented
        _budgetItems = budgetItems
        self.itemToEdit = itemToEdit

        _editedItem = State(initialValue: itemToEdit)
        _newItemName = State(initialValue: itemToEdit.name)
        _newItemAmount = State(initialValue: String(itemToEdit.amount))
        _newItemImage = State(initialValue: itemToEdit.imageURL ?? "")
        _selectedTag = State(initialValue: itemToEdit.tags.first ?? "")
        _selectedDate = State(initialValue: itemToEdit.date)
        _selectedPriority = State(initialValue: itemToEdit.priority)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ticket de caisse")) {
                    if let imageURL = URL(string: newItemImage), let image = try? Data(contentsOf: imageURL) {
                        Image(uiImage: UIImage(data: image)!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300)
                            .padding()
                    } else {
                        Rectangle()
                            .foregroundColor(.gray)
                            .frame(width: 300, height: 300)
                            .padding()
                    }
                    TextField("URL de l'image", text: $newItemImage)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                }

                Section(header: Text("Informations de la dépense")) {
                    TextField("Nom de l'élément", text: $newItemName)
                    TextField("Montant", text: $newItemAmount)
                        .keyboardType(.decimalPad)
                    Picker("Sélectionnez un tag", selection: $selectedTag) {
                        ForEach(availableTags, id: \.self) { tag in
                            Text(tag)
                        }
                    }
                }

                Section(header: Text("Autres")) {
                    Picker("Sélectionnez une priorité", selection: $selectedPriority) {
                        Text("High").tag("High")
                        Text("Medium").tag("Medium")
                        Text("Low").tag("Low")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    DatePicker("Date de la dépense", selection: $selectedDate, displayedComponents: .date)
                }
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            .navigationTitle("Modifier la dépense")
            .navigationBarItems(
                trailing: Button("Enregistrer") {
                    saveChanges()
                }
            )
        }
    }

    func saveChanges() {
        print("Save changes tapped")

        guard let amount = Double(newItemAmount) else { return }

        editedItem.name = newItemName
        editedItem.amount = amount
        editedItem.imageURL = newItemImage
        editedItem.tags = [selectedTag]
        editedItem.date = selectedDate
        editedItem.priority = selectedPriority

        if let index = budgetItems.firstIndex(where: { $0.id == itemToEdit.id }) {
            budgetItems[index] = editedItem
        }

        isPresented = false
    }
}




struct AsyncCoverImage: View {
    private let url: URL?

    init(url: URL?) {
        self.url = url
    }

    @State private var imageData: Data?

    var body: some View {
        GeometryReader { geometry in
            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        guard let url = url else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    self.imageData = data
                }
            }
        }.resume()
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
