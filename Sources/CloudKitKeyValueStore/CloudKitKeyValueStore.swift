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

    func decodeValue(forKey key: String) -> NSValue? {
        if let data = decodeData(forKey: key) {
            do {
                let coder = try NSKeyedUnarchiver(forReadingFrom: data)
                return NSValue(coder: coder)
            } catch {
                print(error)
            }
        }
        
        return nil
    }
    
    func decodeNumber(forKey key: String) -> NSNumber? {
        return decodeValue(forKey: key) as? NSNumber
    }
    
    func encodeData(_ data: Data, forKey key: String) {
        let id = CKRecord.ID.init(recordName: key)
        database.fetch(withRecordID: id) { found,error in
            let record = found ?? CKRecord(recordType: "Value", recordID: id)
            record["data"] = data
            self.scheduleSave(record: record)
        }
    }
    
    func encodeNumber(_ number: NSNumber, forKey key: String) {
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        archiver.encode(number)
        encodeData(archiver.encodedData, forKey: key)
    }
    
    func encodeObject(_ object: Any?, forKey key: String) {
        if let object = object {
            let archiver = NSKeyedArchiver(requiringSecureCoding: true)
            archiver.encode(object)
            encodeData(archiver.encodedData, forKey: key)
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
        guard let data = decodeData(forKey: key) else { return nil }
        do {
            let coder = try NSKeyedUnarchiver(forReadingFrom: data)
            if let string = NSString(coder: coder) {
                return string as String
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    
    public func bool(forKey key: String) -> Bool {
        return decodeNumber(forKey: key)?.boolValue ?? false
    }
    
    public func integer(forKey key: String) -> Int {
        return decodeNumber(forKey: key)?.intValue ?? 0
    }
    
    public func double(forKey key: String) -> Double {
        return decodeNumber(forKey: key)?.doubleValue ?? 0.0
    }
    
    public func array(forKey key: String) -> [Any]? {
        guard let data = decodeData(forKey: key) else { return nil }
        do {
            let coder = try NSKeyedUnarchiver(forReadingFrom: data)
            return NSArray(coder: coder) as? [Any]
        } catch {
            print(error)
        }
        
        return nil
    }
    
    public func dictionary(forKey key: String) -> [String:Any]? {
        guard let data = decodeData(forKey: key) else { return nil }
        do {
            let coder = try NSKeyedUnarchiver(forReadingFrom: data)
            return NSDictionary(coder: coder) as? [String:Any]
        } catch {
            print(error)
        }
        
        return nil
    }
    
    public func data(forKey key: String) -> Data? {
        return decodeData(forKey: key)
    }
    
    public func set(_ string: String?, forKey key: String) {
        encodeObject(string, forKey: key)
    }
    
    public func set(_ bool: Bool, forKey key: String) {
        encodeNumber(NSNumber(booleanLiteral: bool), forKey: key)
    }
    
    public func set(_ double: Double, forKey key: String) {
        encodeNumber(NSNumber(floatLiteral: double), forKey: key)
    }
    
    public func set(_ integer: Int, forKey key: String) {
        encodeNumber(NSNumber(integerLiteral: integer), forKey: key)
    }
    
    public func set(_ array: [Any]?, forKey key: String) {
        encodeObject(array, forKey: key)
    }
    
    public func set(_ dictionary: [String : Any]?, forKey key: String) {
        encodeObject(dictionary, forKey: key)
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
