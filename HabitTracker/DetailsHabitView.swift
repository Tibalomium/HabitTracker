//
//  DetailsHabitView.swift
//  HabitTracker
//
//  Created by Håkan Johansson on 2023-05-04.
//

import SwiftUI

struct DetailsHabitView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let habit: Habit
    @State var progress: Double = 0.0
    @State var streak: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                CircularProgressView(progress: progress)
                    .frame(width: UIScreen.main.bounds.width/2)
                    .aspectRatio(contentMode: .fit)
                
                Text("\(habit.name!)").font(.title)
                Text("Streak: \(streak)").font(.title)
                Text("Completed")
                List {
                    let datesDone = Array(habit.datesDone as? Set<DatesHabits> ?? [])
                    ForEach(datesDone) { date in
                        Text("\(date.date!)")
                    }
                }
                Text("Not completed")
                List {
                    let datesNotDone = Array(habit.datesNotDone as? Set<DatesHabits> ?? [])
                    ForEach(datesNotDone) { date in
                        Text("\(date.date!)")
                    }
                }
            }
            .onAppear() {
                let datesNotDone = Double(habit.datesNotDone?.count ?? 1)
                let datesDone = Double(habit.datesDone?.count ?? 0)
                progress = datesDone / (datesDone + datesNotDone)
                calculateStreak()
            }
        }
    }
    
    private func calculateStreak() {
        
        //Add hours and minutes to check
        
        var datesDone = Array(habit.datesDone as? Set<DatesHabits> ?? []).compactMap {$0.date}
        datesDone.sort {
            $0 < $1
        }
        
        var datesNotDone = Array(habit.datesNotDone as? Set<DatesHabits> ?? []).compactMap {$0.date}
        datesNotDone.sort {
            $0 < $1
        }
        /*let datesDone = Array(habit.datesDone as? Set<DatesHabits> ?? []).sorted {
            $0.date! < $1.date!
        }
        let datesNotDone = Array(habit.datesNotDone as? Set<DatesHabits> ?? []).sorted {
            $0.date! < $1.date!
        }
         */
        
        let filtered = datesNotDone.filter { $0 <= Date() }
        print(datesDone)
        print(datesNotDone)
        print(filtered)
        streak = filtered.last != nil ? datesDone.filter { $0 > filtered.last ?? Date()}.count : datesDone.count
    }
}
