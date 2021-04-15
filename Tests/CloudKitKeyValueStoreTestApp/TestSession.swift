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
        
        store.set(true, forKey: "bool")
        store.set("string", forKey: "string")
    }
}
