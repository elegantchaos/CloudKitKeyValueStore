// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CloudKitKeyValueStore
import Foundation

class TestSession {
    let store = CloudKitKeyValueStore(identifier: "iCloud.com.elegantchaos.cloudkitkeyvaluestore.test")
    
    init() {
    }
    
    func test() {
        print(store.bool(forKey: "bool"))
        print(store.string(forKey: "string") ?? "<missing>")
        print(store.integer(forKey: "integer"))
        print(store.double(forKey: "double"))
        print(store.array(forKey: "array") ?? "<missing>")
        print(store.dictionary(forKey: "dictionary") ?? "<missing>")

        store.set(true, forKey: "bool")
        store.set("string", forKey: "string")
        store.set(123, forKey: "integer")
        store.set(123.456, forKey: "double")
        store.set([1,2,3], forKey: "array")
        store.set([ "bool": true, "integer": 123], forKey: "dictionary")
    }
}
