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
    
    var body: some View {
        let datesDone = Array(habit.datesDone as? Set<DatesHabits> ?? [])
        let datesNotDone = Array(habit.datesNotDone as? Set<DatesHabits> ?? [])
        NavigationStack {
            VStack {
                CircularProgressView(progress: progress)
                    .frame(width: UIScreen.main.bounds.width/2)
                    .aspectRatio(contentMode: .fit)
                Text("\(habit.name!)").font(.title)
                Text("Completed")
                List {
                    ForEach(datesDone) { date in
                        Text("\(date.date!)")
                    }
                }
                Text("Not completed")
                List {
                    ForEach(datesNotDone) { date in
                        Text("\(date.date!)")
                    }
                }
                Spacer()
            }
            .onAppear() {
                progress = Double(datesDone) / (Double(datesDone) + Double(datesNotDone))
            }
        }
    }
}
