//
//  FileListViewController.swift
//  gexporter
//
//  Created by clawoo on 19/09/2018.
//  Copyright © 2018 clawoo. All rights reserved.
//

import UIKit
import ConnectIQ

class FileListViewController: UITableViewController {
    
    struct Section {
        var title: String
        var rows: [File]
    }
    
    var serviceManager: ServiceManager = ServiceManager.shared
    
    private var sections: [Section] = []
    private var hasAutomaticallyShownDevicesScreen = false
    
    private func reload() {
        serviceManager.storage.refresh()
        
        var sections = [Section]()
        
        if !serviceManager.storage.gpxFiles.isEmpty {
            sections.append(Section(title: "GPX", rows: serviceManager.storage.gpxFiles))
        }
        if !serviceManager.storage.fitFiles.isEmpty {
            sections.append(Section(title: "FIT", rows: serviceManager.storage.fitFiles))
        }
        
        self.sections = sections
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serviceManager.storage.onShouldRefresh = { [weak self] in
            self?.reload()
            self?.tableView.reloadData()
        }
        reload()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if serviceManager.devicesManager.devices.isEmpty && !hasAutomaticallyShownDevicesScreen {
            hasAutomaticallyShownDevicesScreen = true
            performSegue(withIdentifier: "DevicesSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController,
            let devicesController = navController.topViewController as? DevicesViewController {
            devicesController.devicesManager = serviceManager.devicesManager
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath)
        cell.textLabel?.text = sections[indexPath.section].rows[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let file = sections[indexPath.section].rows[indexPath.row]
            if serviceManager.storage.remove(file) {
                self.reload()
                tableView.deleteRows(at: [indexPath], with: .right)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = sections[indexPath.section].rows[indexPath.row]
        let actionSheet = UIAlertController.init(title: file.name, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Rename", style: .default, handler: { [weak self] (action) in
            
            let alert = UIAlertController.init(title: "Rename", message: nil, preferredStyle: .alert)
            alert.addTextField(configurationHandler: {
                $0.placeholder = file.name
                $0.text = file.name
            })
            alert.addAction(UIAlertAction.init(title: "Rename", style: .default) { [weak alert, weak self] action in
                guard let newName = alert?.textFields?.first?.text, !newName.isEmpty else {
                    return
                }
                
                if self?.serviceManager.storage.rename(file, name: newName) == true {
                    self?.reload()
                    self?.tableView.reloadData()
                }
            })
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] (action) in
            let actionSheet = UIAlertController.init(title: "Confirmation", message: "Are you sure you want to delete \(file.name)?", preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] (action) in
                if self?.serviceManager.storage.remove(file) == true {
                    self?.reload()
                    self?.tableView.reloadData()
                }
            }))
            actionSheet.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            self?.present(actionSheet, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
}

// MARK: - IBAction
extension FileListViewController {
    @IBAction func onRefreshFilesBtnTapped(_ sender: Any) {
        reload()
        tableView.reloadData()
    }
    
    @IBAction func onDevicesBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "DevicesSegue", sender: nil)
    }
    
    @IBAction func onHelpBtnTapped(_ sender: Any) {
        let text = "To add a track simply share it from another app and gexporter will show up in the sharing sheet.\nIf you don't see gexporter in the list, tap the \"More\" button in the sheet and enable it.\nAdditionally, you can also add tracks via iTunes file sharing."
        let alert = UIAlertController(title: "Help", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
