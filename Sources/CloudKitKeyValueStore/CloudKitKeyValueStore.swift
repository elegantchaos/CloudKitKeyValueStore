// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CloudKit
import Combine
import KeyValueStore

protocol Unarchivable {
    init?(coder: NSKeyedUnarchiver)
}


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
    
    func deleteRecord(forKey key: String) {
        database.delete(withRecordID: CKRecord.ID(recordName: key)) { record, error in
            
        }
    }
    
    func decodeData2<T>(forKey key: String, as: T.Type) -> T? where T: Decodable {
        if let record = fetchRecord(forKey: key), let data = record["data"] as? Data {
            let coder = JSONDecoder()
            do {
                return try coder.decode(T.self, from: data)
            } catch {
                
            }
        }
        
        return nil
    }

    func decodeData(forKey key: String) -> Data? {
        let record = fetchRecord(forKey: key)
        return record?["data"] as? Data
    }

    func unarchiver(forKey key: String) -> NSKeyedUnarchiver? {
        let data = decodeData(forKey: key)
        if let data = data {
            do {
                return try NSKeyedUnarchiver(forReadingFrom: data)
            } catch {
                print(error)
            }
        }

        return nil
    }
 
    func decodeObject(forKey key: String) -> Any? {
        let data = decodeData(forKey: key)
        if let data = data {
            do {
                return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
            } catch {
                print(error)
            }
        }

        return nil
    }
//    func decodeValue(forKey key: String) -> NSValue? {
//        if let data = decodeData(forKey: key) {
//            do {
//                print(data.count)
//                let coder = try NSKeyedUnarchiver(forReadingFrom: data)
//                let value = NSValue(coder: coder.)
//                print(value)
//                return value
//            } catch {
//                print(error)
//            }
//        }
//
//        print("was nil")
//        return nil
//    }
//
//    func decodeNumber(forKey key: String) -> NSNumber? {
//        return decodeValue(forKey: key) as? NSNumber
//    }
    
    func encodeData(_ data: Data, forKey key: String) {
        let id = CKRecord.ID.init(recordName: key)
        database.fetch(withRecordID: id) { found,error in
            let record = found ?? CKRecord(recordType: "Value", recordID: id)
            record["data"] = data
            self.scheduleSave(record: record)
        }
    }
    
    func encodeNumber(_ number: NSNumber, forKey key: String) {
        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        archiver.encode(number)
        encodeData(archiver.encodedData, forKey: key)
    }
    
    func encodeObject(_ object: Any?, forKey key: String) {
        if let object = object {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
                encodeData(data, forKey: key)
            } catch {
                print(error)
            }
        } else {
            remove(key: key)
        }
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
    

    public func has(key: String) -> Bool {
        fetchRecord(forKey: key) != nil
    }
    
    public func object(forKey key: String) -> Any? {
        return nil
    }
    
    public func string(forKey key: String) -> String? {
        return unarchiver(forKey: key)?.decodeObject(forKey: "data") as? String
    }
    
    public func bool(forKey key: String) -> Bool {
        return unarchiver(forKey: key)?.decodeBool(forKey: "data") ?? false
    }
    
    public func integer(forKey key: String) -> Int {
        return unarchiver(forKey: key)?.decodeInteger(forKey: "data") ?? 0
    }
    
    public func double(forKey key: String) -> Double {
        return unarchiver(forKey: key)?.decodeDouble(forKey: "data") ?? 0
    }
    
    public func array(forKey key: String) -> [Any]? {
        return decodeObject(forKey: key) as? [Any]
    }
    
    public func dictionary(forKey key: String) -> [String:Any]? {
        return unarchiver(forKey: key)?.decodeObject(forKey: "data") as? [String:Any]
    }
    
    public func data(forKey key: String) -> Data? {
        return decodeData(forKey: key)
    }
    
    public func set(_ string: String?, forKey key: String) {
        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        archiver.encode(string, forKey: "data")
        encodeData(archiver.encodedData, forKey: key)
    }
    
    public func set(_ bool: Bool, forKey key: String) {
        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        archiver.encode(bool, forKey: "data")
        encodeData(archiver.encodedData, forKey: key)
    }
    
    public func set(_ double: Double, forKey key: String) {
        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        archiver.encode(double, forKey: "data")
        encodeData(archiver.encodedData, forKey: key)
    }
    
    public func set(_ integer: Int, forKey key: String) {
        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        archiver.encode(integer, forKey: "data")
        encodeData(archiver.encodedData, forKey: key)
    }
    
    public func set(_ array: [Any]?, forKey key: String) {
        if let array = array {
            encodeObject(array, forKey: key)
        } else {
            remove(key: key)
        }
    }
    
    public func set(_ dictionary: [String : Any]?, forKey key: String) {
        if let dictionary = dictionary {
            encodeObject(dictionary, forKey: key)
        } else {
            remove(key: key)
        }
    }
    
    public func set(_ data: Data?, forKey key: String) {
        if let data = data {
            encodeData(data, forKey: key)
        } else {
            remove(key: key)
        }
    }
    
    public func remove(key: String) {
        deleteRecord(forKey: key)
    }
}
