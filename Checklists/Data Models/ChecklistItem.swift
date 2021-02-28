//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Eduardo Martin Lorenzo on 01/02/2021.
//

import Foundation
import UserNotifications

class ChecklistItem: NSObject, Codable {
    var text = ""
    var checked = false
    var dueDate = Date()
    var shouldRemind = false
    var itemID = -1
    
    override init() {
        super.init()
        itemID = DataModel.nextChecklistItemID()
    }
    
    // Este metodo se llama automaticamente cuando se va a eliminar un ChecklistItem
    deinit {
        removeNotification()
    }
    
    func toggleChecked() {
        checked.toggle()
    }
    
    func scheduleNotification() {
        // Elimina la notificacion que ya estaba establecida (si es que habia) para este ChecklistItem
        removeNotification()
        if shouldRemind && dueDate > Date() {
            let content = UNMutableNotificationContent()
            content.title = "Reminder:"
            content.body = text
            content.sound = UNNotificationSound.default
            
            // Extra el año, mes, dia, hora y minuto de dueDate
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            
            // Permite mostrar la notificacion en la fecha establecida
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            // El identificador de la notificacion debe ser el itemID para que mas adelante se pueda encontrar para cancelar si es necesario
            let request = UNNotificationRequest(identifier: "\(itemID)", content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(request)
            
            print("Scheduled: \(request) for itemID: \(itemID)")
        }
    }
    
    func removeNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["\(itemID)"])
    }
}
