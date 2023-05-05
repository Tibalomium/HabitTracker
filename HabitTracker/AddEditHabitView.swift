//
//  AddEditHabitView.swift
//  HabitTracker
//
//  Created by Håkan Johansson on 2023-04-28.
//

import SwiftUI
import Foundation
import CoreData

struct AddEditHabitView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var name: String = ""
    @State private var dates: Set<DateComponents> = []
    @State private var date = Date.now
    @State private var repeating: Bool = true
    @State private var repeatFreq: String = "0"
    @FocusState private var nameIsFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Name")
                TextField("Name of habit", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .focused($nameIsFocused)
                    .onChange(of: nameIsFocused) { changed in
                        if(!nameIsFocused) {
                            //Check if need to update
                            update()
                        }
                    }
                Toggle("Repeating", isOn: $repeating)
                if(repeating) {
                    TextField("Number of times", text: $repeatFreq)
                        .textFieldStyle(.roundedBorder)
                    DatePicker(selection: $date, in: Date.now..., displayedComponents: .date) {
                        Text("Select a date")
                    }
                    .datePickerStyle(GraphicalDatePickerStyle())
                }
                else {
                    MultiDatePicker("Dates Available", selection: $dates, in: Date()...)
                        .fixedSize(horizontal: false, vertical: true)
                }
                //Add description?
                Spacer()
            }.padding()//.padding()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            save()
                        }
                    }
                }
        }
    }
    
    private func dateExists(dateToCheck: Date) -> Bool {
        return false
    }
    
    //TODO: Add this for editing exisiting habits
    private func update() {
        /*if let hab = getHabit(name: name) {
            name = hab.name
            repeatFreq = String(hab.frequency)
            if(hab.frequency == Int("0")) {
                repeating = true
                
                var dateArray = Array(hab.datesDone as? Set<DatesHabits> ?? [])
                dateArray.append(contentsOf: Array(hab.datesNotDone as? Set<DatesHabits> ?? []))
                date = dateArray.first?.date ?? Date()

                //let fetchRequest: NSFetchRequest<DatesHabits> = DatesHabits.fetchRequest()
                //fetchRequest.predicate = NSPredicate(format: "%K CONTAINS %@", #keyPath(DatesHabits.habitsDone), hab)

                // Another option:
                //fetchRequest.predicate = NSPredicate(format: "SELF IN %@", library.books!)
            } else {
                repeating = false
                
                var dateArray = Array(hab.datesDone as? Set<DatesHabits> ?? [])
                dateArray.append(contentsOf: Array(hab.datesNotDone as? Set<DatesHabits> ?? []))
                for dh in dateArray {
                    if let dateToInsert = dh.date {
                        dates.insert(Calendar.current.dateComponents([.year, .month, .day], from: dateToInsert))
                    }
                }
            }
        }*/
    }
    
    private func save() {
        withAnimation {
            let newHabit = Habit(context: viewContext)
            newHabit.name = name
            if(repeating) {
                newHabit.frequency = Int32(repeatFreq) ?? 0
                saveDate(habit: newHabit, date: date)
                
            } else {
                newHabit.frequency = 0
                let datesToSave = Array(dates).compactMap { Calendar.current.date(from: $0) }
                for dts in datesToSave {
                    saveDate(habit: newHabit, date: dts)
                }
            }
            do {
                viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print(nsError)
            }
        }
    }
    
    private func saveDate(habit: Habit, date: Date) {
        let dataManager = DataManager(viewContext: viewContext)
        let dateHabit = dataManager.getDatesHabits(date: date)
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        if let dateHabit {
            dateHabit.addToHabitsNotDone(habit)
            habit.addToDatesNotDone(dateHabit)
        }
        else {
            let newDatesHabits = DatesHabits(context: viewContext)
            newDatesHabits.date = date
            newDatesHabits.addToHabitsNotDone(habit)
            habit.addToDatesNotDone(newDatesHabits)
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print(nsError)
        }
    }
}
