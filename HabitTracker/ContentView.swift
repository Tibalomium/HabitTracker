//
//  ContentView.swift
//  HabitTracker
//
//  Created by Håkan Johansson on 2023-04-24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Habit.name, ascending: true)],//\Item.timestamp, ascending: true)],
        animation: .default)
    //private var items: FetchedResults<Item>
    private var habits: FetchedResults<Habit>
    
    @State var progress: Double = 0.3

    var body: some View {
        NavigationView {
            VStack {
                CircularProgressView(progress: progress)
                    .frame(width: UIScreen.main.bounds.width/2)
                    .aspectRatio(contentMode: .fit)
                    
                List {
                    ForEach(habits) { habit in
                        NavigationLink {
                            Text("Habit \(habit.name!)")//"Item at \(item.timestamp!, formatter: itemFormatter)")
                        } label: {
                            Text(habit.name!) //, formatter: itemFormatter)
                                .swipeActions(edge: .leading) {
                                    Button {

                                    } label: {
                                        Label("Done", systemImage: "plus.circle")
                                    }
                                }
                                .tint(.green)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .scrollContentBackground(.hidden)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        NavigationLink("Add") {
                            AddEditHabitView()
                        }
                        /*Button(action: addItem) {
                            Label("Add Item", systemImage: "plus")
                        }*/
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { habits[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
