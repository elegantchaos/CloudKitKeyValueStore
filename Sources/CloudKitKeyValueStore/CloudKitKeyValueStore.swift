// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CloudKit
import Combine
import KeyValueStore

public class CloudKitKeyValueStore: ObservableObject {
    let container: CKContainer
    let record: CKRecord
    var watcher: AnyCancellable?
    @Published var needsSave = false
    
    public init(identifier: String) {
        container = CKContainer.default()
        let id = CKRecord.ID(recordName: "values")
        record = CKRecord(recordType: "Values", recordID: id)
        watcher = objectWillChange
            .debounce(for: 1.0, scheduler: RunLoop.main)
            .sink {
                DispatchQueue.main.async { [self] in
                    if needsSave {
                        save()
                        needsSave = false
                    }
                }
            }
    }

    func scheduleSave() {
        needsSave = true
    }
    
    func save() {
        print("saving")
        let database = container.privateCloudDatabase
        database.save(record) { record, error in
            if let error = error {
                print("Error: \(error)")
            } else if let record = record {
                print("saved \(record)")
            }
        }
    }

}

extension CloudKitKeyValueStore: KeyValueStore {
    
    public func has(key: String) -> Bool {
        record[key] != nil
    }
    
    public func object(forKey key: String) -> Any? {
        record[key]
    }
    
    public func string(forKey key: String) -> String? {
        record[key] as? String
    }
    
    public func bool(forKey key: String) -> Bool {
        (record[key] as? Bool) ?? false
    }
    
    public func integer(forKey key: String) -> Int {
        (record[key] as? Int) ?? 0
    }
    
    public func double(forKey key: String) -> Double {
        (record[key] as? Double) ?? 0
    }
    
    public func array(forKey key: String) -> [Any]? {
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
    
    public func dictionary(forKey key: String) -> [String:Any]? {
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
    
    public func data(forKey key: String) -> Data? {
        record[key] as? Data
    }
    
    public func set(_ string: String?, forKey key: String) {
        record[key] = string
        scheduleSave()
    }
    
    public func set(_ bool: Bool, forKey key: String) {
        record[key] = bool
        scheduleSave()
    }
    
    public func set(_ double: Double, forKey key: String) {
        record[key] = double
        scheduleSave()
    }
    
    public func set(_ integer: Int, forKey key: String) {
        record[key] = integer
        scheduleSave()
    }
    
    public func set(_ array: [Any]?, forKey key: String) {
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        coder.encode(array)
        record[key] = coder.encodedData
        scheduleSave()
    }
    
    public func set(_ dictionary: [String : Any]?, forKey key: String) {
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        coder.encode(dictionary)
        record[key] = coder.encodedData
        scheduleSave()
    }
    
    public func set(_ data: Data?, forKey key: String) {
        record[key] = data
        scheduleSave()
    }
    
    public func remove(key: String) {
        record[key] = nil
    }
}
