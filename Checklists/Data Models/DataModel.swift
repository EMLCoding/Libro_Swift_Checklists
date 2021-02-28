//
//  DataModel.swift
//  Checklists
//
//  Created by Eduardo Martin Lorenzo on 04/02/2021.
//

import Foundation

// No es necesario que sea NSObject
class DataModel {
    var lists = [Checklist]()
    
    init() {
        // No hay que poner superInit( ) porque no es un NSObject
        loadChecklists()
        registerDefaults()
        handleFirstTime()
    }
    
    // Esto es una propiedad calculada
    var indexOfSelectedChecklist: Int {
        get {
            return UserDefaults.standard.integer(forKey: "ChecklistIndex")
        }
        set {
            // newValue se coge automaticamente del valor que le estas pasando, en otros archivos, a dataModel.indexOfSelectedChecklist
            UserDefaults.standard.setValue(newValue, forKey: "ChecklistIndex")
        }
    }
    
    // Esta funcion sirve para que cuando se abre la app por primera vez y aun no hay Checklist, se le mande a UserDefaults el valor -1. Si no, le llegaria el valor 0 y buscaria esa posicion en el array y daria un error la app.
    func registerDefaults() {
        let dictionary = ["ChecklistIndex":-1, "FirstTime":true] as [String:Any]
        UserDefaults.standard.register(defaults: dictionary)
    }

    // Permite crear una checklist automaticamente si es la primera vez que se abre la app
    func handleFirstTime() {
        let userDefaults = UserDefaults.standard
        let firstTime = userDefaults.bool(forKey: "FirstTime")
        
        if firstTime {
            let checklist = Checklist(name: "List")
            lists.append(checklist)
            
            indexOfSelectedChecklist = 0
            userDefaults.set(false, forKey: "FirstTime")
            userDefaults.synchronize()
        }
    }
    
    func sortChecklists() {
        // Lo que hay entre las {} es un closure
        lists.sort(by: {list1, list2 in
            return list1.name.localizedStandardCompare(list2.name) == .orderedAscending
        })
    }
    
    // MARK:- Métodos para guardar y leer ficheros
    // Método que devuelve la url de la carpeta Documetns
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    // Devuelve la ruta completa del archivo donde se guardan las checklists
    func dataFilePath() -> URL{
        return documentsDirectory().appendingPathComponent("Checklists.plist")
    }
    
    func saveChecklistItems() {
        // Crea un objeto que podrá codificar el array items
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(lists)
            // Intenta escribir los datos en un archivo
            try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
        } catch {
            print("Error encoding item array: \(error.localizedDescription)")
        }
    }
    
    func loadChecklists() {
        print(dataFilePath())
        let path = dataFilePath()
        // Se usa "if let" porque puede devolver nil. El "try?" es lo mismo que poner "do { try ... }"
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            do {
                lists = try decoder.decode([Checklist].self, from: data)
                sortChecklists()
            } catch {
                print("Error decoding item array: \(error.localizedDescription)")
            }
        }
    }
    
    // Esta funcion lleva 'class' para que desde otro archivo se pueda hacer DataModel.nextChecklistItemID
    class func nextChecklistItemID() -> Int {
        let userDefaults = UserDefaults.standard
        // Si no se encuentra la clave "ChecklistItemID" en userDefaults entonces devuelve un 0
        let itemID = userDefaults.integer(forKey: "ChecklistItemID")
        userDefaults.set(itemID + 1, forKey: "ChecklistItemID")
        userDefaults.synchronize()
        return itemID
    }
}
