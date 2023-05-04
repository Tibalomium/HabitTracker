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
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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
    
    public func getDatesHabits(date: Date) -> DatesHabits? {
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
