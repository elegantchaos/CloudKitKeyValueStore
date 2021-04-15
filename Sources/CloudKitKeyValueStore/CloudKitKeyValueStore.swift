// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CloudKit
import Combine
import KeyValueStore

public class CloudKitKeyValueStore: ObservableObject {
    let container: CKContainer
    let database: CKDatabase
    var watcher: AnyCancellable?
    @Published var needsSave: [CKRecord] = []
    
    public init(identifier: String) {
        // TODO: prefetch and/or cache records
        let container = CKContainer(identifier: identifier)
        
        self.container = container
        self.database = container.privateCloudDatabase
        
        watcher = objectWillChange
            .debounce(for: 1.0, scheduler: RunLoop.main)
            .sink {
                DispatchQueue.main.async { [self] in
                    if !needsSave.isEmpty {
                        save()
                    }
                }
            }
    }

    func scheduleSave(record: CKRecord) {
        needsSave.append(record)
    }
    
    func save() {
        print("saving")
        let database = container.privateCloudDatabase
        let saveList = needsSave
        needsSave = []
        for record in saveList {
            database.save(record) { record, error in
                if let error = error {
                    print("Error: \(error)")
                } else if let record = record {
                    print("saved \(record)")
                }
            }
        }
    }

}

extension CloudKitKeyValueStore: KeyValueStore {
    
    func fetchRecord(forKey key: String) -> CKRecord? {
        var result: CKRecord? = nil
        let sem = DispatchSemaphore(value: 0)
        database.fetch(withRecordID: CKRecord.ID(recordName: key)) { record, error in
            sem.signal()
            result = record
        }
        
        sem.wait()
        return result
    }
    
    public func has(key: String) -> Bool {
        fetchRecord(forKey: key) != nil
    }
    
    public func object(forKey key: String) -> Any? {
        return nil
    }
    
    public func string(forKey key: String) -> String? {
        return nil
    }
    
    public func bool(forKey key: String) -> Bool {
        if let record = fetchRecord(forKey: key), let data = record["data"] as? Data {
            let coder = JSONDecoder()
            do {
                return try coder.decode(Bool.self, from: data)
            } catch {
                
            }
        }
        return false
    }
    
    public func integer(forKey key: String) -> Int {
        return 0
    }
    
    public func double(forKey key: String) -> Double {
        return 0
    }
    
    public func array(forKey key: String) -> [Any]? {
        return nil
    }
    
    public func dictionary(forKey key: String) -> [String:Any]? {
        return nil
    }
    
    public func data(forKey key: String) -> Data? {
        return nil
//        record[key] as? Data
    }
    
    public func set(_ string: String?, forKey key: String) {
//        record[key] = string
//        scheduleSave()
    }
    
    public func set(_ bool: Bool, forKey key: String) {
//        record[key] = bool
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(bool)
            let id = CKRecord.ID.init(recordName: key)
            database.fetch(withRecordID: id) { found,error in
                let record = found ?? CKRecord(recordType: "Value", recordID: id)
                record["data"] = data
                self.scheduleSave(record: record)
            }
        } catch {
            print("coding error \(error)")
        }
    }
    
    public func set(_ double: Double, forKey key: String) {
//        record[key] = double
//        scheduleSave()
    }
    
    public func set(_ integer: Int, forKey key: String) {
//        record[key] = integer
        //        scheduleSave()
    }
    
    public func set(_ array: [Any]?, forKey key: String) {
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        coder.encode(array)
//        record[key] = coder.encodedData
        //        scheduleSave()
    }
    
    public func set(_ dictionary: [String : Any]?, forKey key: String) {
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        coder.encode(dictionary)
//        record[key] = coder.encodedData
        //        scheduleSave()
    }
    
    public func set(_ data: Data?, forKey key: String) {
//        record[key] = data
        //        scheduleSave()
    }
    
    public func remove(key: String) {
//        record[key] = nil
    }
}
