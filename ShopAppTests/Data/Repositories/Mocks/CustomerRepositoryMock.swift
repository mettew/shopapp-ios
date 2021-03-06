//
//  CustomerRepositoryMock.swift
//  ShopAppTests
//
//  Created by Radyslav Krechet on 3/26/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import ShopApp_Gateway

@testable import ShopApp

class CustomerRepositoryMock: CustomerRepository {
    func getCustomer(callback: @escaping RepoCallback<Customer>) {}
    func updateCustomer(with email: String, firstName: String?, lastName: String?, phone: String?, callback: @escaping RepoCallback<Customer>) {}
    func updateCustomer(with promo: Bool, callback: @escaping RepoCallback<Customer>) {}
    func updateCustomer(with password: String, callback: @escaping RepoCallback<Customer>) {}
    func updateCustomerDefaultAddress(with addressId: String, callback: @escaping RepoCallback<Customer>) {}
    func updateCustomerAddress(with address: Address, callback: @escaping RepoCallback<Bool>) {}
    func addCustomerAddress(with address: Address, callback: @escaping RepoCallback<String>) {}
    func deleteCustomerAddress(with addressId: String, callback: @escaping RepoCallback<Bool>) {}
}
