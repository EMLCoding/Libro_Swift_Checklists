//
//  ViewController.swift
//  Checklists
//
//  Created by Eduardo Martin Lorenzo on 01/02/2021.
//
// PANTALLA DONDE APARECEN TODOS LOS CHECKLISTITEM DE UNA CHECKLIST

import UIKit

class ChecklistViewController: UITableViewController, ItemDetailViewControllerDelegate {
    
    // Se le pone la "!" porque durante un breve periodo de tiempo este objeto va a ser nil (entre que se prepara el segue desde AllListsViewController hasta que carga el valor de checklist
    var checklist: Checklist!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = checklist.name
    }
    
    func configureCheckmark(for cell: UITableViewCell, with item: ChecklistItem) {
        let label = cell.viewWithTag(1001) as! UILabel
        
        if item.checked {
            label.text = "✅"
        } else {
            label.text = "🔲"
        }
    }
    
    func configureText(for cell: UITableViewCell, with item: ChecklistItem) {
        // Obtiene la celda con el TAG 1000 como un UILabel
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = item.text
    }

    // MARK:- Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklist.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
        
        let item = checklist.items[indexPath.row]
        
        configureText(for: cell, with: item)
        
        configureCheckmark(for: cell, with: item)
        
        return cell
    }
    
    // MARK:- Table View Delegate
    // Se ejecuta cuando se toca una celda
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // El if solo se ejecutará si "cell" obtiene valor
        if let cell = tableView.cellForRow(at: indexPath) {
            
            let item = checklist.items[indexPath.row]
            item.toggleChecked()
            
            configureCheckmark(for: cell, with: item)
        }
        
        // Hace que se deseleccione la celda tocada
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Este método habilita la opción de deslizar para eliminar en el Table View Controller
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        checklist.items.remove(at: indexPath.row)
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    // MARK:- AddItemViewController Delegate
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
        // Este método oculta la pantalla en la que estamos siempre y cuando no sea la pantalla "root" del navigation controller
        navigationController?.popViewController(animated: true)
    }
    
    func addItemViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem) {
        let newRowIndex = checklist.items.count
        checklist.items.append(item)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        
        navigationController?.popViewController(animated: true)
    }
    
    func addItemViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem) {
        // Primero hay que obtener el indice del elemento editado
        if let index = checklist.items.firstIndex(of: item) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                configureText(for: cell, with: item)
            }
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK:- Navigation
    // Esta función se invoca cuando se va a pasar de una pantalla a otra
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 1
        if segue.identifier == "AddItem" {
            //2
            let controller = segue.destination as! ItemDetailViewController
            
            //3: Le dice a AddItemViewController que su delegado es ChecklistViewController (self)
            controller.delegate = self
        } else if segue.identifier == "EditItem" {
            let controller = segue.destination as! ItemDetailViewController
            
            controller.delegate = self
            
            // El método prepare devuelve el sender, que contiene una referencia al control que desencadena la transicion a la nueva pantalla
            // Como tableView.indexPath(for:) devuelve un opcional, es necesario desempaquetarlo (if let). Devuelve la posicion de la celda tocada.
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                //Le pasa, a la var itemToEdit de AddItemViewController, el item del array de items
                controller.itemToEdit = checklist.items[indexPath.row]
            }
        }
    }
}

