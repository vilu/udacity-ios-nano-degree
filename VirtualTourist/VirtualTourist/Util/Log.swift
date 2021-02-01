import Foundation

enum Log {
    static func info(_ message: String) {
        message.enumerateLines(invoking: { (str, _) in
            print("### " + str)
        })
    }
}
