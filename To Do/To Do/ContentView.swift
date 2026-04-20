//
//  ContentView.swift
//  To Do
//
//  Created by Collin Le on 4/20/26.
//

import SwiftUI
import Foundation

struct TodoItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}
    

struct ContentView: View {
    @StateObject private var viewModel = TodoViewModel()
    @State private var newTaskTitle = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter new task", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        guard
                        !newTaskTitle.trimmingCharacters(in:
                                .whitespaces).isEmpty else { return }
                        viewModel.addItem(title: newTaskTitle)
                        newTaskTitle = ""
                    }) {
                        Image(systemName: "plus").padding(8)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .padding()
                List {
                    ForEach(viewModel.items) {
                        item in TodoRow(item: item, viewModel: viewModel)
                    }
                    .onDelete(perform: viewModel.deleteItem)
                    }
                }
            .navigationTitle("To-Do List")
            }
        }
    }

struct TodoRow: View {
    @State private var isEditing = false
    @State private var editedTitle: String = ""
    var item: TodoItem
    var viewModel: TodoViewModel
    
    var body: some View {
        HStack {
            Button(action: {
                
                viewModel.toggleCompletion(item)
            }) {
                Image(systemName:
                        item.isCompleted ? "checkmark.circle.fill" :
                "circle")
                
                .foregroundColor(item.isCompleted ? .green :
                        .gray)
            }
            if isEditing {
                TextField("Edit task", text:
                $editedTitle)
                Button("Save"){
                    viewModel.updateItem(item, newTitle:
                    editedTitle)
                    isEditing = false
                }
            } else {
                Text(item.title)
                    .strikethrough(item.isCompleted)
                
                    .foregroundColor(item.isCompleted ? .gray :
                            .primary)
                Spacer()
                Button("Edit") {
                    editedTitle = item.title
                    isEditing = true
                }
            }
        }
        .padding(.vertical, 5)
    }
}

class TodoViewModel: ObservableObject {
    @Published var items: [TodoItem] = []
    
    func addItem(title: String) {
        let newItem = TodoItem(id: UUID(),title: title, isCompleted: false)
        items.append(newItem)
    }
    
    func updateItem(_ item: TodoItem, newTitle: String) {
        if let index = items.firstIndex(where: {$0.id == item.id}) {
            items[index].title = newTitle
        }
    }
    
    func toggleCompletion(_ item: TodoItem) {
        if let index = items.firstIndex(where: {$0.id == item.id}) {
            items[index].isCompleted.toggle()
        }
    }
    
    func deleteItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}
