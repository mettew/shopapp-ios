//
//  CheckoutTableProvider.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 2/2/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import UIKit

import ShopApp_Gateway

class CheckoutTableProvider: NSObject {
    var checkout: Checkout?
    var cartProducts: [CartProduct] = []
    var billingAddress: Address?
    var creditCard: CreditCard?
    var selectedPaymentType: PaymentType?
    var customerHasEmail = false
    var customerEmail = ""
    
    weak var delegate: CheckoutCombinedDelegate?
}

// MARK: - UITableViewDataSource

extension CheckoutTableProvider: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return selectedPaymentType == .creditCard ? CheckoutSection.allValues.count : CheckoutSection.valuesWithoutShippingOptions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == CheckoutSection.customerEmail.rawValue {
            return customerHasEmail ? 0 : 1
        } else if section == CheckoutSection.shippingOptions.rawValue {
            return checkout?.availableShippingRates?.count ?? 1
        } else if section == CheckoutSection.payment.rawValue {
            return selectedPaymentType == .creditCard ? PaymentAddCellType.allValues.count : 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case CheckoutSection.cart.rawValue:
            return cartCell(with: tableView, indexPath: indexPath)
        case CheckoutSection.customerEmail.rawValue:
            return customerEmailCell(with: tableView, indexPath: indexPath)
        case CheckoutSection.shippingAddress.rawValue:
            return shippingAddressCell(with: tableView, indexPath: indexPath)
        case CheckoutSection.payment.rawValue:
            return paymentCell(with: tableView, indexPath: indexPath)
        case CheckoutSection.shippingOptions.rawValue:
            return shippingOptionsCell(with: tableView, indexPath: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    private func cartCell(with tableView: UITableView, indexPath: IndexPath) -> CheckoutCartTableViewCell {
        let cell: CheckoutCartTableViewCell = tableView.dequeueReusableCellForIndexPath(indexPath)
        let images = cartProducts.map({ $0.productVariant?.image ?? Image() })
        let productVariantIds = cartProducts.map({ $0.productVariant?.id ?? "" })
        cell.configure(with: images, productVariantIds: productVariantIds)
        cell.delegate = delegate
        return cell
    }
    
    private func customerEmailCell(with tableView: UITableView, indexPath: IndexPath) -> CustomerEmailTableViewCell {
        let cell: CustomerEmailTableViewCell = tableView.dequeueReusableCellForIndexPath(indexPath)
        cell.delegate = delegate
        return cell
    }
    
    private func shippingAddressCell(with tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if let shippingAddress = checkout?.shippingAddress {
            return shippingAddressEditCell(with: tableView, indexPath: indexPath, address: shippingAddress)
        } else {
            return shippingAddressAddCell(with: tableView, indexPath: indexPath)
        }
    }
    
    private func shippingAddressAddCell(with tableView: UITableView, indexPath: IndexPath) -> CheckoutShippingAddressAddTableViewCell {
        let cell: CheckoutShippingAddressAddTableViewCell = tableView.dequeueReusableCellForIndexPath(indexPath)
        cell.delegate = delegate
        return cell
    }
    
    private func shippingAddressEditCell(with tableView: UITableView, indexPath: IndexPath, address: Address) -> CheckoutShippingAddressEditTableCell {
        let cell: CheckoutShippingAddressEditTableCell = tableView.dequeueReusableCellForIndexPath(indexPath)
        cell.delegate = delegate
        cell.configure(with: address)
        return cell
    }
    
    private func paymentCell(with tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case PaymentAddCellType.type.rawValue:
            return paymentTypeCell(with: tableView, indexPath: indexPath)
        case PaymentAddCellType.card.rawValue:
            return paymentCardCell(with: tableView, indexPath: indexPath)
        case PaymentAddCellType.billingAddress.rawValue:
            return paymentBillingAddressCell(with: tableView, indexPath: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    private func paymentTypeCell(with tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if let selectedType = selectedPaymentType {
            return paymentEditCell(with: tableView, indexPath: indexPath, selectedType: selectedType)
        } else {
            return paymentAddCell(with: tableView, indexPath: indexPath)
        }
    }
    
    private func paymentAddCell(with tableView: UITableView, indexPath: IndexPath) -> CheckoutPaymentAddTableViewCell {
        let cell: CheckoutPaymentAddTableViewCell = tableView.dequeueReusableCellForIndexPath(indexPath)
        cell.delegate = delegate
        let type = PaymentAddCellType(rawValue: indexPath.row)
        cell.configure(type: type!)
        return cell
    }
    
    private func paymentEditCell(with tableView: UITableView, indexPath: IndexPath, selectedType: PaymentType) -> CheckoutSelectedTypeTableViewCell {
        let cell: CheckoutSelectedTypeTableViewCell = tableView.dequeueReusableCellForIndexPath(indexPath)
        cell.delegate = delegate
        cell.configure(type: selectedType)
        return cell
    }
    
    private func paymentCardCell(with tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if let card = creditCard {
            return paymentCardEditCell(with: tableView, indexPath: indexPath, creditCard: card)
        } else {
            return paymentAddCell(with: tableView, indexPath: indexPath)
        }
    }
    
    private func paymentCardEditCell(with tableView: UITableView, indexPath: IndexPath, creditCard: CreditCard) -> CheckoutCreditCardEditTableViewCell {
        let cell: CheckoutCreditCardEditTableViewCell = tableView.dequeueReusableCellForIndexPath(indexPath)
        cell.delegate = delegate
        cell.configure(with: creditCard)
        return cell
    }
    
    private func paymentBillingAddressCell(with tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if let address = billingAddress {
            return paymentBillingAddressEditCell(with: tableView, indexPath: indexPath, address: address)
        } else {
            return paymentAddCell(with: tableView, indexPath: indexPath)
        }
    }
    
    private func paymentBillingAddressEditCell(with tableView: UITableView, indexPath: IndexPath, address: Address) -> CheckoutBillingAddressEditTableViewCell {
        let cell: CheckoutBillingAddressEditTableViewCell = tableView.dequeueReusableCellForIndexPath(indexPath)
        cell.delegate = delegate
        cell.configure(with: address)
        return cell
    }
    
    private func shippingOptionsCell(with tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if checkout?.shippingAddress != nil, let rates = checkout?.availableShippingRates, let currencyCode = checkout?.currencyCode {
            let rate = rates[indexPath.row]
            let selected = checkout?.shippingLine?.handle == rate.handle
            return shippingOptionsEnabledCell(with: tableView, indexPath: indexPath, rate: rate, currencyCode: currencyCode, selected: selected)
        } else {
            return shippingOptionsDisabledCell(with: tableView, indexPath: indexPath)
        }
    }
    
    private func shippingOptionsEnabledCell(with tableView: UITableView, indexPath: IndexPath, rate: ShippingRate, currencyCode: String, selected: Bool) -> CheckoutShippingOptionsEnabledTableViewCell {
        let cell: CheckoutShippingOptionsEnabledTableViewCell = tableView.dequeueReusableCellForIndexPath(indexPath)
        cell.delegate = delegate
        cell.configure(with: rate, currencyCode: currencyCode, selected: selected)
        return cell
    }
    
    private func shippingOptionsDisabledCell(with tableView: UITableView, indexPath: IndexPath) -> CheckoutShippingOptionsDisabledTableViewCell {
        return tableView.dequeueReusableCellForIndexPath(indexPath) as CheckoutShippingOptionsDisabledTableViewCell
    }
}

// MARK: - UITableViewDelegate

extension CheckoutTableProvider: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case CheckoutSection.cart.rawValue:
            return kSeeAllTableHeaderViewHeight
        case CheckoutSection.customerEmail.rawValue:
            return customerHasEmail ? TableView.headerFooterMinHeight : kBoldTitleTableHeaderViewHeight
        default:
            return kBoldTitleTableHeaderViewHeight
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard checkout != nil, section == CheckoutSection.shippingOptions.rawValue else {
            return TableView.headerFooterMinHeight
        }
        return kPaymentDetailsFooterViewHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case CheckoutSection.cart.rawValue:
            let view = SeeAllTableHeaderView(type: .myCart, separatorVisible: true)
            view.hideSeeAllButton()
            return view
        case CheckoutSection.customerEmail.rawValue:
            return customerHasEmail ? nil : BoldTitleTableHeaderView(type: .customerEmail)
        case CheckoutSection.shippingAddress.rawValue:
            return BoldTitleTableHeaderView(type: .shippingAddress)
        case CheckoutSection.payment.rawValue:
            return BoldTitleTableHeaderView(type: .payment)
        case CheckoutSection.shippingOptions.rawValue:
            let disabled = checkout?.availableShippingRates == nil
            return BoldTitleTableHeaderView(type: .shippingOptions, disabled: disabled)
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let checkout = checkout, section == CheckoutSection.shippingOptions.rawValue {
            return PaymentDetailsFooterView(checkout: checkout)
        }
        return nil
    }
}
