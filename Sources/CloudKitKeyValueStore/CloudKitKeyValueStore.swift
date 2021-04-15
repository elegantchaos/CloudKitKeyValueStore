// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CloudKit
import Foundation

class CloudKitKeyValueStore: KeyValueStore {
    let container: CKContainer
    let record: CKRecord

    init(identifier: String) {
        container = CKContainer(identifier: identifier)
        let id = CKRecord.ID(recordName: "values")
        record = CKRecord(recordType: "Values", recordID: id)
    }

    func has(key: String) -> Bool {
        record[key] != nil
    }
    
    func object(forKey key: String) -> Any? {
        record[key]
    }
    
    func string(forKey key: String) -> String? {
        record[key] as? String
    }
    
    func bool(forKey key: String) -> Bool {
        (record[key] as? Bool) ?? false
    }
    
    func integer(forKey key: String) -> Int {
        (record[key] as? Int) ?? 0
    }
    
    func double(forKey key: String) -> Double {
        (record[key] as? Double) ?? 0
    }
    
    func array(forKey key: String) -> [Any]? {
        if let data = record[key] as? Data {
            do {
                let coder = try NSKeyedUnarchiver(forReadingFrom: data)
                let array = NSArray(coder: coder) as? [Any]
                return array
            } catch {
                // report error?
            }
        }
        return nil
    }
    
    func dictionary(forKey key: String) -> [String:Any]? {
        if let data = record[key] as? Data {
            do {
                let coder = try NSKeyedUnarchiver(forReadingFrom: data)
                let dictionary = NSDictionary(coder: coder) as? [String:Any]
                return dictionary
            } catch {
                // report error?
            }
        }
        return nil
    }
    
    func data(forKey key: String) -> Data? {
        record[key] as? Data
    }
    
    func set(_ string: String?, forKey key: String) {
        record[key] = string
    }
    
    func set(_ bool: Bool, forKey key: String) {
        record[key] = bool
    }
    
    func set(_ double: Double, forKey key: String) {
        record[key] = double
    }
    
    func set(_ integer: Int, forKey key: String) {
        record[key] = integer
    }
    
    func set(_ array: [Any]?, forKey key: String) {
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        coder.encode(array)
        record[key] = coder.encodedData
    }
    
    func set(_ dictionary: [String : Any]?, forKey key: String) {
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        coder.encode(dictionary)
        record[key] = coder.encodedData
    }
    
    func set(_ data: Data?, forKey key: String) {
        record[key] = data
    }
    
    func remove(key: String) {
        record[key] = nil
    }
}
