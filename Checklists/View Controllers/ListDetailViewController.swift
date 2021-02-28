//
//  ListDetailViewController.swift
//  Checklists
//
//  Created by Eduardo Martin Lorenzo on 03/02/2021.
//
// PANTALLA DE DETALLE DE UNA CHECKLIST (CAMBIO DE NOMBRE Y DE ICONO)

import UIKit

protocol ListDetailViewControllerDelegate: class {
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController)
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist)
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist)
}

class ListDetailViewController: UITableViewController, UITextFieldDelegate, IconPickerViewControllerDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var iconImage: UIImageView!
    
    weak var delegate: ListDetailViewControllerDelegate?
    
    var checklistToEdit: Checklist?
    
    // Para el icono de una Checklist
    var iconName = "Folder"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let checklist = checklistToEdit {
            title = "Edit Checklist"
            textField.text = checklist.name
            doneBarButton.isEnabled = true
            iconName = checklist.iconName
        }
        iconImage.image = UIImage(named:iconName)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    // MARK:- Actions
    @IBAction func cancel() {
        delegate?.listDetailViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        if let checklist = checklistToEdit {
            checklist.name = textField.text!
            checklist.iconName = iconName
            delegate?.listDetailViewController(self, didFinishEditing: checklist)
        } else {
            let checklist = Checklist(name: textField.text!, iconName: iconName)
            delegate?.listDetailViewController(self, didFinishAdding: checklist)
        }
    }
    
    // MARK:- Table View Delegates
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Si la seccion es 0, es decir, la celda "Name of the list", se devuelve nil para que no se pueda tocar la celda
        return indexPath.section == 1 ? indexPath : nil
    }
    
    // MARK:- Text Field Delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        
        doneBarButton.isEnabled = !newText.isEmpty
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        doneBarButton.isEnabled = false
        return true
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickIcon" {
            let controller = segue.destination as! IconPickerViewController
            controller.delegate = self
        }
    }
    
    // MARK:- Icon Picker View Controller Delegate
    func iconPicker(_ picker: IconPickerViewController, didPick iconName: String) {
        print("Metodo delegado IconPickerViewController")
        self.iconName = iconName
        iconImage.image = UIImage(named: iconName)
        navigationController?.popViewController(animated: true)
    }
    
}
