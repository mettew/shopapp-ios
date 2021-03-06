//
//  AddressListTableViewCell.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 12/27/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import UIKit

import ShopApp_Gateway

protocol AddressListTableCellDelegate: class {
    func tableViewCell(_ cell: AddressListTableViewCell, didSelect address: Address)
    func tableViewCell(_ cell: AddressListTableViewCell, didTapEdit address: Address)
    func tableViewCell(_ cell: AddressListTableViewCell, didTapDelete address: Address)
    func tableViewCell(_ cell: AddressListTableViewCell, didTapDefault address: Address)
}

class AddressListTableViewCell: UITableViewCell {
    @IBOutlet private weak var customerNameLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var phoneLabel: UILabel!
    @IBOutlet private weak var selectButton: UIButton!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var defaultAddressButton: UIButton!
    
    private var address: Address!
    
    weak var delegate: AddressListTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        setupViews()
    }
    
    func configure(with address: Address, isSelected: Bool = false, isDefault: Bool, showSelectionButton: Bool) {
        self.address = address
        populateViews(with: address, isSelected: isSelected, isDefault: isDefault, showSelectionButton: showSelectionButton)
    }
        
    private func setupViews() {
        editButton.setTitle("Button.Edit".localizable.uppercased(), for: .normal)
        deleteButton.setTitle("Button.Delete".localizable.uppercased(), for: .normal)
        defaultAddressButton.setTitle("Button.Default".localizable.uppercased(), for: .normal)
    }
    
    private func populateViews(with address: Address, isSelected: Bool, isDefault: Bool, showSelectionButton: Bool) {
        customerNameLabel.text = address.fullName
        addressLabel.text = address.fullAddress
        if let phoneText = address.phone {
            let customerNameLocalized = "Label.Phone".localizable
            phoneLabel.text = String.localizedStringWithFormat(customerNameLocalized, phoneText)
        } else {
            phoneLabel.text = nil
        }
        selectButton.isSelected = isSelected
        selectButton.isHidden = !showSelectionButton
        deleteButton.isEnabled = !isDefault
        defaultAddressButton.isEnabled = !isDefault
    }
    
    // MARK: - Actions
    
    @IBAction func selectButtonDidPress(_ sender: UIButton) {
        delegate?.tableViewCell(self, didSelect: address)
    }
    
    @IBAction func editButtonDidPress(_ sender: UIButton) {
        delegate?.tableViewCell(self, didTapEdit: address)
    }
    
    @IBAction func deleteButtonDidPress(_ sender: UIButton) {
        delegate?.tableViewCell(self, didTapDelete: address)
    }
    
    @IBAction func defaultAddressButtonDidPress(_ sender: UIButton) {
        delegate?.tableViewCell(self, didTapDefault: address)
    }
}
