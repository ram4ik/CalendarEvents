//
//  ContentView.swift
//  CalendarEvents
//
//  Created by ramil on 07.09.2020.
//

import SwiftUI
import EventKit

struct ContentView: View {
    var body: some View {
        Button(action: {
            checkPermission(startDate: Date(), eventName: "Meeting")
        }, label: {
            Text("Set up event")
        })
    }
    
    func checkPermission(startDate: Date, eventName: String) {
        
        let eventStore = EKEventStore()
        
        switch EKEventStore.authorizationStatus(for: .event) {
        
        
        case .notDetermined:
            eventStore.requestAccess(to: .event) { (status, error) in
                if status {
                    insertEvent(store: eventStore, startDate: startDate, eventName: eventName)
                } else {
                    print(error?.localizedDescription)
                }
            }
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        case .authorized:
            insertEvent(store: eventStore, startDate: startDate, eventName: eventName)
        @unknown default:
            print("Unknown")
        }
    }
    
    func insertEvent(store: EKEventStore, startDate: Date, eventName: String) {
        
        let calendars = store.calendars(for: .event)
        
        for calendar in calendars {
            if calendar.title == "Calendar" {
                let event = EKEvent(eventStore: store)
                event.calendar = calendar
                event.startDate = startDate
                event.title = eventName
                event.endDate = event.startDate.addingTimeInterval(60)
                event.recurrenceRules = [EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil)]
                
                let reminder1 = EKAlarm(relativeOffset: -60)
                let reminder2 = EKAlarm(relativeOffset: -300)
                
                event.alarms = [reminder1, reminder2]
                
                do {
                    try store.save(event, span: .thisEvent)
                    print("event insert")
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

