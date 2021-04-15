// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct ContentView: View {
    let tests: TestSession
    
    var body: some View {
        VStack {
            Text("Hello, world!")
            Button(action: handleTest) {
                Text("Run Tests")
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
    
    func handleTest() {
        tests.test()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let tests = TestSession()
        ContentView(tests: tests)
    }
}
