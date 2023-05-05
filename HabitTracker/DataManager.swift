//
//  DataManager.swift
//  HabitTracker
//
//  Created by Håkan Johansson on 2023-05-04.
//

import Foundation
import CoreData
import SwiftUI

struct DataManager {
    let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    public func habitIsDone(habit: Habit, date: Date) -> Bool {
        let datesHabits = getDatesHabits(date: date)
        if let datesDone = habit.datesDone {
            if(datesDone.contains(datesHabits)) {
                return true
            }
        }
        return false
    }
    
    //Toggles done by moving from not done to done and vice versa
    public func toggleDone(habit: Habit, date: Date) {
        let datesHabits = getDatesHabits(date: date)
        if let datesDone = habit.datesDone,
           let datesHabits {
            if(datesDone.contains(datesHabits)) {
                habit.removeFromDatesDone(datesHabits)
                habit.addToDatesNotDone(datesHabits)
                datesHabits.removeFromHabitsDone(habit)
                datesHabits.addToHabitsNotDone(habit)
            }
            else {
                habit.addToDatesDone(datesHabits)
                habit.removeFromDatesNotDone(datesHabits)
                datesHabits.addToHabitsDone(habit)
                datesHabits.removeFromHabitsNotDone(habit)
            }
        }
        do {
            //viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print(nsError)
        }
    }
    
    public func getHabitsForDate(date: Date) -> [Habit] {
        let dateHabits = getDatesHabits(date: date)
        var dateArray = Array(dateHabits?.habitsDone as? Set<Habit> ?? [])
        dateArray.append(contentsOf: Array(dateHabits?.habitsNotDone as? Set<Habit> ?? []))
        return dateArray
    }
    
    public func getHabit(name: String) -> Habit? {
        let habitFetchRequest = Habit.fetchRequest()
        
        let predicateName = NSPredicate(format: "name == %@", name)
        
        habitFetchRequest.predicate = predicateName
        do {
            if let firstHabit = try viewContext.fetch(habitFetchRequest).first {
                return firstHabit
            }
        }
        catch {
            print (error)
        }
        return nil
    }
    
    public func updateRepeatingHabits() {
        //Fetch
        let habitFetchRequest = Habit.fetchRequest()
        let predicateName = NSPredicate(format: "frequency > 0")
        habitFetchRequest.predicate = predicateName
        
        do {
            let habits = try viewContext.fetch(habitFetchRequest)
            let date = Date()
            
            for habit in habits {
                var datesDone = Array(habit.datesDone as? Set<DatesHabits> ?? []).compactMap {$0.date}
                let datesNotDone = Array(habit.datesNotDone as? Set<DatesHabits> ?? []).compactMap {$0.date}
                
                datesDone.append(contentsOf: datesNotDone)
                
                let dates = datesDone.filter { $0 > date || Calendar.current.isDateInToday($0)}
                //Check if we have any dates that's equal to or bigger than todays date
                if(dates.count == 0 && datesDone.count > 0) {
                    if let dateToCheck = datesDone.max() {
                        updateDates(startDate: dateToCheck, habit: habit)
                    }
                }
            }
        }
        catch {
            print (error)
        }
    }
    
    //Helper function to updateRepeatingHabits
    private func updateDates(startDate: Date, habit: Habit) {
        let date = Date()
        var dateToCheck = startDate
        
        while(dateToCheck < date) {
            if let addedDate = Calendar.current.date(byAdding: .day, value: Int(habit.frequency), to: dateToCheck) {
                dateToCheck = addedDate
                
                //Check if date exist already and add. Else create a new one
                if let dateHabit = getDatesHabits(date: dateToCheck) {
                    habit.addToDatesNotDone(dateHabit)
                    dateHabit.addToHabitsNotDone(habit)
                }
                else {
                    let newDatesHabits = DatesHabits(context: viewContext)
                    newDatesHabits.date = dateToCheck
                    newDatesHabits.addToHabitsNotDone(habit)
                    habit.addToDatesNotDone(newDatesHabits)
                }
            }
        }
    }
    
    public func getDatesHabits(date: Date) -> DatesHabits? {
        
        //To be able to do fetch on Date
        var components = Calendar.current.dateComponents(
            [
                .year,
                .month,
                .day
            ],
            from: date)
        
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        let fromDate = Calendar.current.date(from: components)
        
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let toDate = Calendar.current.date(from: components)
        
        if let fromDate,
           let toDate {
            let dateFetchRequest = DatesHabits.fetchRequest()
            let predicateDate = NSPredicate(format: "(date >= %@) AND (date <= %@)", fromDate as NSDate, toDate as NSDate)
            dateFetchRequest.predicate = predicateDate
            
            do {
                let firstDate = try viewContext.fetch(dateFetchRequest)
                return firstDate.first
            }
            catch {
                print (error)
            }
        }
        return nil
    }
}
