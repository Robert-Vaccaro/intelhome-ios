//
//  DeviceCell.swift
//  DeviceDetector
//
//  Created by Bobby on 11/23/24.
//

import UIKit

class DeviceCell: UITableViewCell {

    // Container view for the cell content
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.borderColor = primaryColor.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let deviceNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        // Add the container view
        contentView.addSubview(containerView)

        // Add subviews to the container view
        containerView.addSubview(deviceNameLabel)
        containerView.addSubview(detailsLabel)
        containerView.addSubview(statusIcon)

        // Apply constraints
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Device name label
            deviceNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            deviceNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            deviceNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusIcon.leadingAnchor, constant: -8),

            // Details label
            detailsLabel.topAnchor.constraint(equalTo: deviceNameLabel.bottomAnchor, constant: 8),
            detailsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            detailsLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusIcon.leadingAnchor, constant: -8),
            detailsLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16),

            // Status icon
            statusIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            statusIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            statusIcon.widthAnchor.constraint(equalToConstant: 24),
            statusIcon.heightAnchor.constraint(equalToConstant: 24)
        ])

    }

    func configure(with device: Devices) {
        deviceNameLabel.text = device.name
        detailsLabel.text = device.type

        // Set the status icon based on whether the device needs an update
        if device.needsUpdate {
            statusIcon.image = UIImage(systemName: "exclamationmark.circle.fill")
            statusIcon.tintColor = .red
        } else {
            statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
            statusIcon.tintColor = .green
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
