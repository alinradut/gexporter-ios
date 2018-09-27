//
//  DevicesViewController.swift
//  gexporter
//
//  Created by clawoo on 21/09/2018.
//  Copyright © 2018 clawoo. All rights reserved.
//

import UIKit
import ConnectIQ

class DevicesViewController: UITableViewController {
    
    var devicesManager: DevicesManager! {
        didSet {
            devicesManager.devices.forEach({ (device) in
                devicesManager.connectIq.register(forDeviceEvents: device, delegate: self)
            })
            
            devicesManager.onDevicesChanged = { [weak self] in
                self?.devicesManager.devices.forEach({ (device) in
                    self?.devicesManager.connectIq.register(forDeviceEvents: device, delegate: self)
                })
                self?.reload()
            }
        }
    }
    
    private var rows: [IQDevice] = []
    private var deviceStatuses: [IQDeviceStatus : String] = [
        IQDeviceStatus.connected : "Connected",
        IQDeviceStatus.bluetoothNotReady : "Bluetooth not ready",
        IQDeviceStatus.invalidDevice : "Invalid device",
        IQDeviceStatus.notConnected : "Not connected",
        IQDeviceStatus.notFound : "Not found"
    ]
    
    deinit {
        devicesManager.connectIq.unregister(forAllDeviceEvents: self)
    }
    
    private func reload() {
        rows = devicesManager.devices
        if isViewLoaded {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reload()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let device = rows[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath)
        cell.textLabel?.text = device.friendlyName
        cell.detailTextLabel?.text = deviceStatuses[devicesManager.connectIq.getDeviceStatus(device)] ?? "Unknown"
        return cell
    }
}

// MARK: - IBAction
extension DevicesViewController {
    @IBAction func onConnectBtnTapped(_ sender: Any) {
        devicesManager.refreshDevices()
    }
    
    @IBAction func onDoneBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - IQDeviceEventDelegate
extension DevicesViewController: IQDeviceEventDelegate {
    func deviceStatusChanged(_ device: IQDevice!, status: IQDeviceStatus) {
        tableView.reloadData()
    }
}
