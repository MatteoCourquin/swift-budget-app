import SwiftUI

struct DetailView: View {
    var item: BudgetItem
    @State private var isEditViewPresented = false
    @State private var imageData: Data?
    
    @Binding var budgetItems: [BudgetItem]
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: item.imageURL!)) {
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
                PriorityDotView(priority: item.priority)
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
                EditView(isPresented: $isEditViewPresented, budgetItems: $budgetItems, itemToEdit: item)
            }
        }
        .padding()
        .navigationTitle(item.name)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(item: BudgetItem(name: "Tennis", amount: 350.0, tags: ["Loisirs"], date: Date(), priority: "High", imageURL: "https://images.unsplash.com/photo-1554068865-24cecd4e34b8?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"), budgetItems: .constant([]))
    }
}
