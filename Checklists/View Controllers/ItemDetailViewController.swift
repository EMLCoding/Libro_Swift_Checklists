//
//  AddItemViewController.swift
//  Checklists
//
//  Created by Eduardo Martin Lorenzo on 02/02/2021.
//
// PANTALLA DE DETALLE DE UN CHECKLISTITEM

import UIKit
import UserNotifications

// Para que la pantalla B (AddITemViewController) pueda comunicarse con la pantalla A (ChecklistViewController) al crear un nuevo ChecklistItem es necesario crear un Protocolo propio
protocol ItemDetailViewControllerDelegate: class {
    // Para cuando se presiona en el Bar Button -> Cancel
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController)
    // Para cuando se presiona en el Bar Button -> Done
    func addItemViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem)
    
    func addItemViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem)
}

// Clase de UITableViewController creada a mano utilizando la plantilla Cocoa Touch Class
// Se añade el UITextFieldDelegate (AddItemViewController se vuelve delegado de UITextField) porque se quiere controlar el funcionamiento de un Bar Button en función de un Text Field. Nota: Desde el inspector de atributos de Text Field, hay que indicar que Delegate es Add Item
class ItemDetailViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    // Necesario para controlar el Bar Button
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    // Para la Table View Cell extra del DatePicker
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // Los delegados siempre deben ser 'weak'
    weak var delegate: ItemDetailViewControllerDelegate?
    
    var itemToEdit: ChecklistItem?
    
    var dueDate = Date()
    var datePickerVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hay que desempaquetar itemToEdit, por eso el "if let item = "
        if let item = itemToEdit {
            title = "Edit Item"
            textField.text = item.text
            doneBarButton.isEnabled = true
            shouldRemindSwitch.isOn = item.shouldRemind
            dueDate = item.dueDate
        }
        
        updateDueDateLabel()
    }
    
    func showDatePicker() {
        datePickerVisible = true
        // Esto permite agregar una nueva celda en la seccion 1 (que no la primera) en la fila 2
        let indexPathDatePicker = IndexPath(row: 2, section: 1)
        tableView.insertRows(at: [indexPathDatePicker], with: .fade)
        datePicker.setDate(dueDate, animated: false)
        dueDateLabel.textColor = dueDateLabel.tintColor
    }
    
    func hideDatePicker() {
        if datePickerVisible {
            datePickerVisible = false
            let indexPathDatePicker = IndexPath(row: 2, section: 1)
            tableView.deleteRows(at: [indexPathDatePicker], with: .fade)
            dueDateLabel.textColor = UIColor.black
        }
    }

    // MARK:- Actions
    @IBAction func cancel() {
        delegate?.itemDetailViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        if let item = itemToEdit {
            item.text = textField.text!
            item.shouldRemind = shouldRemindSwitch.isOn
            item.dueDate = dueDate
            item.scheduleNotification()
            delegate?.addItemViewController(self, didFinishEditing: item)
        } else {
            let item = ChecklistItem()
            item.text = textField.text!
            item.checked = false
            item.shouldRemind = shouldRemindSwitch.isOn
            item.dueDate = dueDate
            item.scheduleNotification()
            delegate?.addItemViewController(self, didFinishAdding: item)
        }
    }
    
    @IBAction func dateChanged(_ datePicker: UIDatePicker) {
        dueDate = datePicker.date
        print("Se cambia la fecha")
        updateDueDateLabel()
    }
    
    // Metodo necesario para que se le solicite al usuario permisos de notificaciones si no se han dado y el Switch Control esta en ON.
    @IBAction func shouldRemindToggled(_ switchControl: UISwitch) {
        textField.resignFirstResponder()
        
        if switchControl.isOn {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) {
                granted, error in
                // do nothing
            }
        }
    }
    
    // MARK:- Table View Delegates
    // Esta función se llama cuando se toca la celda. El return nil evita que se seleccione la celda que se ha tocado
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 && indexPath.row == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        textField.resignFirstResponder()
        // Cuando pulsemos en la celda que tiene los label Due Date y Detail haremos que se muestre la celda del Date Picker View
        if indexPath.section == 1 && indexPath.row == 1 {
            if !datePickerVisible {
                showDatePicker()
            } else {
                hideDatePicker()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    
    
    // MARK:- Table View Delegates Metodos ñapeados
    // Hay que usar estos metodos, de celdas DINAMICAS de un Table View, para poder trabajar con una celda que aparece y desaparece como es la del Date Picker View
    // Este metodo solo se debe usar con celdas dinamicas, no con estaticas como es en este caso. Pero esta es una excepcion
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 2 {
            // Esto funciona porque en este momento la Table View no conoce lo que hay en la seccion 1 celda 2 (que es la tercera en realidad)
            return datePickerCell
        } else {
            // El else es un truco para que las demas celdas estaticas funcione
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Si el Date Picker esta visible entonces hay que forzar a que la Table View devuelva 3 celdas
        if section == 1 && datePickerVisible {
            return 3
        } else {
            // Si no dejamos que haga el funcionamient normal de Table View
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 2 {
            return 217
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    // Es necesario añadir este metodo porque sino la app peta al crear la celda del Date Picker, ya que esta celda no es parte del diseño del Table View
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        var newIndexPath = indexPath
        if indexPath.section == 1 && indexPath.row == 2 {
            newIndexPath = IndexPath(row: 0, section: indexPath.section)
        }
        return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
    }
    
    // MARK:- Text Field Delegates
    // Se invoca cada vez que el usuario cambia el texto del Text Field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Este método devuelve el rango de caracteres a cambiar y el string por el que se cambia
        let oldText = textField.text!
        
        // Es necesario transformar el NSRange que recibe la funcioon (que es de Objective-C) a Range (que ya es de Swift)
        let stringRange = Range(range, in:oldText)!
        
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        
        doneBarButton.isEnabled = !newText.isEmpty
        
        return true
    }
    
    // Esta funcion se invoca cuando se toca la "X" para eliminar el texto escrito de un Text Field
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        doneBarButton.isEnabled = false
        return true
    }
    
    // Esta funcion se invoca cuando va a aparecer el teclado en pantalla
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideDatePicker()
    }
    
    // MARK:- Helper Methods
    // Funcion para convertir una fecha en un texto y colocarla en la label detail de la celda Due Date
    func updateDueDateLabel() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dueDateLabel.text = formatter.string(from: dueDate)
    }

}
