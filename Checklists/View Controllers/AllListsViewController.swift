//
//  AllListsViewController.swift
//  Checklists
//
//  Created by Eduardo Martin Lorenzo on 03/02/2021.
//
// PANTALLA PRINCIPAL DE LA APP DONDE APARECEN TODAS LAS CHECKLIST

import UIKit

// AllListsViewController es el DELEGADO de ListDetailViewController y de UINavigationController
class AllListsViewController: UITableViewController, ListDetailViewControllerDelegate, UINavigationControllerDelegate {
    
    let cellIfentifier = "ChecklistCell"
    
    // Esta variable se carga desde el SceneDelegate.swift
    var dataModel: DataModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Habilita el texto grande para el titulo de la barra de navegacion del NavigationController
        navigationController?.navigationBar.prefersLargeTitles = true
        
        for list in dataModel.lists {
            let item = ChecklistItem()
            item.text = "Item for \(list.name)"
            list.items.append(item)
        }
    }
    
    // Esta funcion la llama automaticamente UIKit despues de que el view controller se vuelva visible. Tambien se llama cada vez que se carga esta pantalla al volver de otra pantalla de la app
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Se va a utilizar para cargar la checklist que estuviera viendo el usuario
        
        // El view controller, AllListsViewController, se vuelve el delegado del navigationController
        navigationController?.delegate = self
        
        let index = dataModel.indexOfSelectedChecklist
        
        if index >= 0 && index < dataModel.lists.count {
            let checklist = dataModel.lists[index]
            performSegue(withIdentifier: "ShowChecklist", sender: checklist)
        }
    }
    
    // Esta funcion se llama antes de viewDidAppear()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Recarga todas las celdas de la tabla
        tableView.reloadData()
        // El objetivo de este metodo es que se recargue el contador de tareas por realizar de cada Checklist cada vez que se vuelve a la pantalla de AllListsViewController
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.lists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        
        // Comprueba si hay alguna celda almacenada en cache para reutilizar y sino crea una celda nueva
        if let c = tableView.dequeueReusableCell(withIdentifier: cellIfentifier) {
            cell = c
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIfentifier)
        }

        let checklist = dataModel.lists[indexPath.row]
        
        if let label = cell.textLabel {
            label.text = checklist.name
        }
        
        cell.accessoryType = .detailDisclosureButton
        
        let count = checklist.countUncheckedItems()
        
        if let label = cell.detailTextLabel {
            if checklist.items.count == 0 {
                label.text = "No items"
            } else {
                label.text = count == 0 ? "All Done" : "\(count) Remaining"
            }
        }
        
        cell.imageView!.image = UIImage(named: checklist.iconName)

        return cell
    }
    
    // MARK:- Table View Delegate
    // Se invoca cuando se toca una fila
    // En este caso la segue se debe realizar manualmente porque no se han querido usar las celdas prototipo
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Almacena en UserDefaults el indice de la fila con la clave "ChecklistIndex"
        dataModel.indexOfSelectedChecklist = indexPath.row
        
        let checklist = dataModel.lists[indexPath.row]
        // Aquí le pasamos al segue el checklist por el sender
        performSegue(withIdentifier: "ShowChecklist", sender: checklist)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        dataModel.lists.remove(at: indexPath.row)
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    // Método que se ejecuta al tocar el accessory de una fila
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // En este metodo se establece una forma alternativa de ir a otra pantalla. La forma más utilizada es con los segue
        // Para que esta forma funcione es necesario indicar que la view, en el main.storyboard, tiene el storyboardID = ListDetailViewController
        if let controller = storyboard?.instantiateViewController(withIdentifier: "ListDetailViewController") as? ListDetailViewController {
            controller.delegate = self
            
            let checklist = dataModel.lists[indexPath.row]
            controller.checklistToEdit = checklist
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChecklist" {
            let controller = segue.destination as! ChecklistViewController
            // Y aquí, este sender, tiene el objeto Checklist que se ha establecido en tableView(_:didSelectRowAt:)
            controller.checklist = sender as? Checklist
        } else if segue.identifier == "AddChecklist" {
            let controller = segue.destination as! ListDetailViewController
            controller.delegate = self
        }
    }
    
    // MARK:- Navigation Controller Delegates
    // Esta funcion se llama cada vez que el navigation controller muestra una nueva pantalla
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // Si hemos vuelto a la pantalla de AllLists
        if viewController === self {
            // Entonces ponemos a -1 la clave de UserDefaults para indicar que el usuario no tenía ninguna Checklist abierta
            dataModel.indexOfSelectedChecklist = -1
        }
    }
    
    // MARK:- ListDetailViewControllerDelegate
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist) {
        dataModel.lists.append(checklist)
        dataModel.sortChecklists()
        
        tableView.reloadData()
        
        navigationController?.popViewController(animated: true)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist) {
        dataModel.sortChecklists()
        tableView.reloadData()
        
        navigationController?.popViewController(animated: true)
    }
    
}
