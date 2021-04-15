// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/04/2021.
//  All code (c) 2021 - present day, Elegant Chaos.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest

@testable import CloudKitKeyValueStore

final class CloudKitKeyValueStoreTests: XCTestCase {
    func testExample() {
        let store = CloudKitKeyValueStore(identifier: "com.elegantchaos.cloudkitstore.test")
        store.set(true, forKey: "bool")
        XCTAssertEqual(store.bool(forKey: "bool"), true)
    }
}
