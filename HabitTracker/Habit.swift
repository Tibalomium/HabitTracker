//
//  Habit.swift
//  HabitTracker
//
//  Created by Håkan Johansson on 2023-04-27.
//

import Foundation

struct Habit {
    var name: String = ""
    var dates: [Date] = [] //Maybe tuples with date and bool
    var id: String = UUID().uuidString
    //Reminders set in settings
    //var done: Bool -> Needs check with date or different Habits per date
    var frequency: Int //0 for no frequency but be able to set manual dates?
}
