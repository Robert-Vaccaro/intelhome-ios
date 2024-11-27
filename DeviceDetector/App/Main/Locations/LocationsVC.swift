//
//  LocationsVC.swift
//  DeviceDetector
//
//  Created by Bobby on 11/22/24.
//
import UIKit

class LocationsVC: BaseVC, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    var locations: [String] = SessionData.user?.locations ?? [] // Array of strings
    private let tableView = UITableView()
    private var saveButton: UIButton?
    private var tableViewBottomConstraint: NSLayoutConstraint!
    private var isEditingTable = false
    
    private let noLocationsLabel: UILabel = {
        let label = UILabel()
        label.text = """
No Locations

Press the plus button
to create a location
"""
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Locations"
        
        // Setup Edit Button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(toggleEditing)
        )
        
        // Setup Add Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addLocation)
        )
        if let index = locations.firstIndex(of: "All") {
            locations.remove(at: index)
        }
        
        if locations.isEmpty {
            noLocationsLabel.isHidden = false
        }
        
        view.addSubview(noLocationsLabel)
        NSLayoutConstraint.activate([
            noLocationsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noLocationsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        // Setup TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LocationCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.isEditing = false // Default to not editing
        view.addSubview(tableView)
        
        // Setup Save Button
        saveButton = UIButton(type: .system)
        saveButton?.setTitle("Save", for: .normal)
        saveButton?.backgroundColor = .systemBlue
        saveButton?.setTitleColor(.white, for: .normal)
        saveButton?.layer.cornerRadius = 10
        saveButton?.translatesAutoresizingMaskIntoConstraints = false
        saveButton?.alpha = 0 // Initially hidden
        saveButton?.addTarget(self, action: #selector(saveChanges), for: .touchUpInside)
        if let saveButton = saveButton {
            view.addSubview(saveButton)
        }
        
        // Constraints
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([
            // TableView
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableViewBottomConstraint,
            
            // Save Button
            saveButton!.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton!.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton!.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        
        // Clear cell content
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        
        let location = locations[indexPath.row]
        
        // Create container view
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 8
        containerView.backgroundColor = .black
        containerView.layer.borderColor = primaryColor.cgColor
        containerView.layer.borderWidth = 1
        cell.contentView.addSubview(containerView)
        
        // Add label inside container view
        let label = UILabel()
        label.text = location
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        
        // Constraints for container view
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 16),
            containerView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -16),
            containerView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            
            // Label constraints
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
        ])
        
        return cell
    }
    
    // Enable dragging
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedLocation = locations.remove(at: sourceIndexPath.row)
        locations.insert(movedLocation, at: destinationIndexPath.row)
        
        // Show save button when order changes
        //        toggleSaveButton(show: true)
        replaceLocations(newLocations: locations)
        
    }
    
    // MARK: - Swipe Actions
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            let location = self.locations[indexPath.row]
            self.deleteLocation(location: location)
            self.locations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            let alertController = UIAlertController(title: "Edit Location", message: "Update the location name", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.text = self.locations[indexPath.row]
            }
            let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
                guard let self = self, let updatedLocation = alertController.textFields?.first?.text, !updatedLocation.isEmpty else { return }
                let oldLocation = self.locations[indexPath.row]
                self.updateLocationName(oldLocation: oldLocation, newLocation: updatedLocation)
                self.locations[indexPath.row] = updatedLocation
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            completionHandler(true)
        }
        
        editAction.backgroundColor = .systemOrange
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    // MARK: - API Integration
    func updateLocationName(oldLocation: String, newLocation: String) {
        let parameters = [
            "oldLocation": oldLocation,
            "newLocation": newLocation
        ]
        self.makeAPICall(path: "/locations/update", method: .PUT, parameters: parameters, responseType: LocationResponse.self) { results in
            switch(results) {
            case .success(let data):
                SessionData.user.locations = data.locations
                if SessionData.currectLocation == oldLocation {
                    SessionData.currectLocation = "All" //reset current location page
                }
            case .failure(let error):
                print(error)
                self.showAlert(message: "Failed to update the location, please try again later")
            }
        }
    }
    
    func replaceLocations(newLocations: [String]) {
        let parameters = [
            "newLocations": newLocations
        ]
        self.noLocationsLabel.isHidden = true
        self.makeAPICall(path: "/locations/replace", method: .PUT, parameters: parameters, responseType: LocationResponse.self, showLoader: false) { results in
            switch(results) {
            case .success(let data):
                SessionData.user.locations = data.locations
                if SessionData.user.locations!.isEmpty {
                    self.noLocationsLabel.isHidden = false
                }
                if newLocations.contains(SessionData.currectLocation) {
                    SessionData.currectLocation = "All" //reset current location page
                }
            case .failure(let error):
                print(error)
                self.showAlert(message: "Failed to udpate locations, please try again later")
            }
        }
    }
    
    func deleteLocation(location: String) {
        let parameters = [
            "location": location
        ]
        self.noLocationsLabel.isHidden = true
        self.makeAPICall(path: "/locations/delete", method: .DELETE, parameters: parameters, responseType: LocationResponse.self) { results in
            switch(results) {
            case .success(let data):
                SessionData.user.locations = data.locations
                if SessionData.user.locations!.isEmpty {
                    self.noLocationsLabel.isHidden = false
                }
                if SessionData.currectLocation == location {
                    SessionData.currectLocation = "All" //reset current location page
                }
            case .failure(let error):
                print(error)
                self.showAlert(message: "Failed to delete the location, please try again later")
            }
        }
    }
    
    // MARK: - Actions
    @objc private func toggleEditing() {
        isEditingTable.toggle()
        tableView.setEditing(isEditingTable, animated: true)
        navigationItem.leftBarButtonItem?.title = isEditingTable ? "Done" : "Edit"
    }
    
    @objc private func addLocation() {
        let alertController = UIAlertController(
            title: "Add Location",
            message: "Enter a new location",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "Location name"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self, let location = alertController.textFields?.first?.text, !location.isEmpty else { return }
            
            if location.count > 32 {
                // Show an alert if the location name exceeds 32 characters
                self.showAlert(message: "Location name cannot be more than 32 characters long.")
            } else if (location == "All" || location == "all") {
                self.showAlert(message: "Invalid Name")
            } else {
                // Add the location if it's valid
                SessionData.currectLocation = location
                self.locations.append(location)
                self.replaceLocations(newLocations: self.locations)
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    @objc private func saveChanges() {
        //        toggleSaveButton(show: false)
        replaceLocations(newLocations: locations)
        let alert = UIAlertController(title: "Success", message: "Locations updated successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func toggleSaveButton(show: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.saveButton?.alpha = show ? 1 : 0
            self.tableViewBottomConstraint.constant = show ? -66 : 0
            self.view.layoutIfNeeded()
        }
    }
}
