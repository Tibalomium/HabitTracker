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
    private var habits: FetchedResults<Habit>
    
    /*@FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DatesHabits.date, ascending: true)],
        animation: .default)
    private var datesHabits: FetchedResults<DatesHabits>*/
    
    @State var progress: Double = 0.0
    @State var habitsForToday: [Habit] = []
    
    var body: some View {
        let dataManager = DataManager(viewContext: viewContext)

        NavigationView {
            VStack {
                CircularProgressView(progress: progress)
                    .frame(width: UIScreen.main.bounds.width/2)
                    .aspectRatio(contentMode: .fit)
                    
                List {
                    ForEach(habitsForToday) { habit in
                        HStack {
                            NavigationLink {
                                DetailsHabitView(habit: habit)
                                //Text("Habit \(habit.name!)")
                            } label: {
                                Text("\(habit.name!)")
                            }.buttonStyle(.plain)
                            Button() {
                                dataManager.toggleDone(habit: habit, date: Date())
                            } label: {
                                Image(systemName: dataManager.habitIsDone(habit: habit, date: Date()) ? "checkmark.square" : "square")
                                //Label("Done", systemImage: "square")
                            }.buttonStyle(.plain)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .onAppear {
                    update()
                }
                .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)) {_ in
                    update()
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
        }
    }
    
    public func update() {
        let dataManager = DataManager(viewContext: viewContext)
        habitsForToday = dataManager.getHabitsForDate(date: Date())
        
        if let datesHabits = dataManager.getDatesHabits(date: Date()) {
            let done = Double(datesHabits.habitsDone?.count ?? 0)
            let all = Double(datesHabits.habitsNotDone?.count ?? 1) + done
            progress = done / all
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
