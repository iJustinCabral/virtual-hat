//
//  Hat.swift
//  SwiftUI-Testbed
//
//  Created by Justin Cabral on 6/23/20.
//

import Foundation
import CoreData
import SwiftUI

final class Hat : ObservableObject {
    
    enum Status: Error {
        case empty(message: String)
        case duplicate
        case unknown
    }
    
   @Published public var names: [Person] = []
   @Published public var pulledNames: [Person] = []
   @Published public var savedNames: [Person] = []
    
    let defaults = UserDefaults.standard
       
    var isEmpty: Bool {
        return names.isEmpty
    }
    
    var count: Int {
        return names.count
    }
    
    public init(names: [Person], pulledNames: [Person], savedNames: [Person]) {
        
        self.names = names
        self.pulledNames = pulledNames
        self.savedNames = savedNames
                
    }
    
    @inlinable
    func shuffleHat() {
        self.names.shuffle()
    }
    
    func pickRandomPerson()  {
        guard let person = self.names.randomElement() else { return }
        for (index, element) in names.enumerated() {
            if element.name == person.name {
                self.names.remove(at: Int(index))

            }
        }
        self.pulledNames.append(person)
    }
    
    @inlinable
    func add(_ person: Person) {
        self.names.insert(person, at: 0)
    }
    
    @inlinable
    func save(_ person: Person) {
        self.savedNames.append(person)
    }
    
    func delete(_ person: Person) {
        for (index, element) in names.enumerated() {
            if element.name == person.name {
                self.names.remove(at: Int(index))
            }
        }
    }
    
    func deleteSaved(_ person: Person) {

        for (index, element) in savedNames.enumerated() {
            if element.name == person.name {
                self.savedNames.remove(at: Int(index))
            }
        }
    }
    
    @inlinable
    func deleteSaved(at offsets: IndexSet) {
        savedNames.remove(atOffsets: offsets)
    }
    
    @inlinable
    func emptyTheHat() {
        self.names.removeAll()
        self.pulledNames.removeAll()
    }
    
    func checkDuplicate(person: Person) -> Bool {
        for p in names {
            if person.name == p.name {
                return true
            }
        }
        return false
    }
    
    func checkSavedDuplicates(person: Person) -> Bool {
        for p in savedNames {
            if person.name == p.name {
                return true
            }
        }
        return false
    }
    
}
