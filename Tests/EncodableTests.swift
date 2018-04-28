//
//  EncodableTest.swift
//  CodableAlamofire-iOS
//
//  Created by BYTEPOETS on 28.04.18.
//

import XCTest
import Foundation
import Alamofire

struct EncodableObject: Encodable {
    let foo: String
    let bar: Int
}

struct EncodableObjectWithDifferentKeys: Encodable {
    let customerId: String
    let customerName: String
    
    enum CodingKeys: String, CodingKey {
        case customerId
        case customerName = "customer_name"
    }
}

struct EncodableObjectWithOneKeyThatWillNotBeEncoded: Encodable {
    let test: String
    let notExist: Int
    
    enum CodingKeys: String, CodingKey {
        case test
    }
}

struct Customer: Encodable {
    let name: String
    let address: Address
}

struct CustomerWithManyAddresses: Encodable {
    let name: String
    let addresses: [Address]
}

struct Address: Encodable {
    let street: String
    let countryCode: String
}

final class EncodableTests: XCTestCase {
    var subEncodableObject: Encodable?
    var encodedParameters: Parameters?
    
    func testSimpleObjectEncoding() {
        let fooTest = "Test1"
        let barTest = 1
        givenEncodableObject(foo: fooTest, bar: barTest)
        whenEncodingParameters()
        thenParameterWith(key: "foo", is: fooTest)
        thenParameterWith(key: "bar", is: barTest)
    }
    
    func testEncodingObjectWithCodingKeys() {
        let customerId = "AB143244"
        let customerName = "Company XY"
        givenEncodableObject(customerId: customerId, customerName: customerName)
        whenEncodingParameters()
        thenParameterWith(key: "customerId", is: customerId)
        thenParameterWith(key: "customer_name", is: customerName)
    }
    
    //if the coding key for a given parameter isn't entered in the coding keys, that specific parameter won't be encoded
    func testKeyWillNotBeEncodedIfItIsNotGivenInTheCodingKeys() {
        givenNotFullyEncodableObject()
        whenEncodingParameters()
        thenParameterWithKeyDoesNotExist("notExist")
    }
    
    func testNestedObject() {
        let name = "John Appleseed"
        let street = "Apple street 1"
        let countryCode = "339"
        givenNestedObjects(name: name,
                           address: givenAddress(street: street, countryCode: countryCode))
        whenEncodingParameters()
        thenParameterWith(key: "name", is: name)
        thenNestedParameterWith(key: "address", nestedKey: "street", is: street)
    }
    
    func testNestedObjects() {
        let name = "John Appleseed"
        let street1 = "Apple street 1"
        let street2 = "Apple street 2"
        let countryCode = "339"
        givenNestedObjects(name: name,
                           addresses: [givenAddress(street: street1, countryCode: countryCode),
                                       givenAddress(street: street2, countryCode: countryCode)])
        whenEncodingParameters()
        thenParameterWith(key: "name", is: name)
        thenNestedParameterWith(key: "addresses", at: 1, nestedKey: "street", is: street2)
    }
    
    // MARK: - Given
    
    private func givenEncodableObject(foo: String, bar: Int) {
        subEncodableObject = EncodableObject(foo: foo, bar: bar)
    }
    
    private func givenEncodableObject(customerId: String, customerName: String) {
        subEncodableObject = EncodableObjectWithDifferentKeys(customerId: customerId, customerName: customerName)
    }
    
    private func givenNotFullyEncodableObject() {
        subEncodableObject = EncodableObjectWithOneKeyThatWillNotBeEncoded(test: "Test", notExist: 0)
    }
    
    private func givenAddress(street: String, countryCode: String) -> Address {
        return Address(street: street, countryCode: countryCode)
    }
    
    private func givenNestedObjects(name: String, address: Address) {
        subEncodableObject = Customer(name: name, address: address)
    }
    
    private func givenNestedObjects(name: String, addresses: [Address]) {
        subEncodableObject = CustomerWithManyAddresses(name: name, addresses: addresses)
    }
    
    // MARK: - When
    
    private func whenEncodingParameters() {
        encodedParameters = subEncodableObject?.parameters
    }
    
    // MARK: - Then
    
    private func thenParameterWith<T: Equatable>(key: String, is value: T) {
        guard let parameterValue = encodedParameters?[key] as? T else {
            assertionFailure("encoded parameters not given or of wrong type")
            return
        }
        assert(parameterValue == value)
    }
    
    private func thenParameterWithKeyDoesNotExist(_ key: String) {
        if let encodedParameter = encodedParameters?[key] {
            assertionFailure("the key '\(key)' should not exist, but does: \(encodedParameter)")
        }
    }
    
    private func thenNestedParameterWith<T: Equatable>(key: String, nestedKey: String, is value: T) {
        guard let nestedParameter = encodedParameters?[key] as? Parameters,
            let parameterValue = nestedParameter[nestedKey] as? T else {
                assertionFailure("encoded parameters not given or of wrong type")
                return
        }
        assert(parameterValue == value)
    }
    
    private func thenNestedParameterWith<T: Equatable>(key: String, at index: Int, nestedKey: String, is value: T) {
        guard let nestedParameters = encodedParameters?[key] as? [Parameters],
            nestedParameters.indices.contains(index) else {
                assertionFailure("parameter not founc in array or not in index")
                return
        }
        
        let nestedParameter = nestedParameters[index]
        guard
            let parameterValue = nestedParameter[nestedKey] as? T else {
                assertionFailure("encoded parameters not given or of wrong type")
                return
        }
        assert(parameterValue == value)
    }
}
