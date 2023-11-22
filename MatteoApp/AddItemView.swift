import SwiftUI

struct ImageObject: Decodable {
    let id: Int
    let url: String
    let name: String
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
    let randomUrlImages = [
        "https://images.unsplash.com/photo-1554068865-24cecd4e34b8?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
        "https://images.unsplash.com/photo-1572883454114-1cf0031ede2a?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=987&q=80",
        "https://images.unsplash.com/photo-1466442929976-97f336a657be?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=987&q=80"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ticket de caisse")) {
                    AsyncImage(url: URL(string: newItemImage)){
                        image in image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.gray)
                    }
                    .frame(width: 300, height: 300)
                    .padding()
                    
                    HStack {
                        TextField("URL de l'image", text: $newItemImage)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.URL)
                            .textContentType(.URL)
                        Button(action: {
                            randomUrlImage()
                        }) {
                            Text("Générer")
                        }
                        
                    }
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
            .navigationBarItems(
                leading: Button("Fermer") {
                    isPresented = false
                },
                trailing: Button("Ajouter") {
                    addItem()
                }
            )
        }
    }
    
    func randomUrlImage() {
        guard let apiUrl = URL(string: "https://api-css-tools.vercel.app/images/\(Int.random(in: 1...30))") else {
            return
        }
        
        URLSession.shared.dataTask(with: apiUrl) { (data, _, error) in
            if let data = data {
                do {
                    let image = try JSONDecoder().decode(ImageObject.self, from: data)
                    DispatchQueue.main.async {
                        newItemImage = image.url
                    }
                } catch {
                    print("Erreur lors de la désérialisation des données JSON : \(error)")
                }
            } else if let error = error {
                print("Erreur lors de la récupération de l'image depuis l'API : \(error)")
            }
        }.resume()
    }
    
    
    func addItem() {
        guard let amount = Double(newItemAmount) else { return }
        let imageURL = newItemImage.isEmpty ? "URL_PAR_DEFAUT" : newItemImage
        let newItem = BudgetItem(name: newItemName, amount: amount, tags: [selectedTag], date: selectedDate, priority: selectedPriority, imageURL: imageURL)
        budgetItems.append(newItem)
        print("Nom: \(newItemName), Montant: \(amount), Tags: \(selectedTag), Date: \(selectedDate), Priorité: \(selectedPriority), Image: \(newItemImage)")
        isPresented = false
    }
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView(isPresented: .constant(true), budgetItems: .constant([]))
    }
}
