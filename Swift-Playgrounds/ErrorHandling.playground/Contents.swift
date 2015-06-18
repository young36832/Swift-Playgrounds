import Cocoa

// Error Handling
// Swift provides first-class support for throwing, catching, propagating, and manipulating recoverable errors at runtime (NOTE: recoverable).

// Representing Errors
enum VendingMachineError: ErrorType {
    case InvalidSelection
    case InsufficientFunds(required: Double)
    case OutOfStock
}

// Throwing Errors
func canThrowErrors() throws -> String { return "" }
func cannotThrowErrors() -> String { return "" }

struct Item {
    var price: Double
    var count: Int
}

var inventory = [
    "Candy Bar": Item(price: 1.25, count: 7),
    "Chips": Item(price: 1.00, count: 4),
    "Pretzels": Item(price: 0.75, count: 11)
]
var amountDeposited = 1.00

func vend(itemNamed name: String) throws {
    guard var item = inventory[name] else {
        throw VendingMachineError.InvalidSelection
    }
    
    guard item.count > 0 else {
        throw VendingMachineError.OutOfStock
    }
    
    if amountDeposited >= item.price {
        // Dispence the snack
        amountDeposited -= item.price
        --item.count
        inventory[name] = item
    } else {
        let amountRequired = item.price - amountDeposited
        throw VendingMachineError.InsufficientFunds(required: amountRequired)
    }
}

let favoriteSnacks = [
    "Alice": "Chips",
    "Bob": "Licorice",
    "Eve": "Pretzels",
]

func buyFavoriteSnack(person: String) throws {
    let snackName = favoriteSnacks[person] ?? "Candy Bar"
    try vend(itemNamed: snackName)
}
// Note that vend() must be marked with the try keyword. Also because the errors are not handled here the error is propagated up to buyFavoriteSnack() as noted by the throws keyword.


// Catching and Handling Errors
do {
    try vend(itemNamed: "Candy Bar")
    // Enjoy delicious snack
} catch VendingMachineError.InvalidSelection {
    print("Invalid Selection")
} catch VendingMachineError.OutOfStock {
    print("Out of Stock")
} catch VendingMachineError.InsufficientFunds(let amountRequired) {
    print("Insufficient funds. Please insert an additional $\(amountRequired).")
}


// Disabling Error Propagation
// Calling a throwing function or method with try! disables error propagation and wraps the call in a run-time assertion that no error will be thrown. If an error actually is thrown, you'll get a runtime error.

enum GeneralError: ErrorType {
    case someError
}

func willOnlyThrowIfTrue(value: Bool) throws {
    if value { throw GeneralError.someError }
}

do {
    try willOnlyThrowIfTrue(false)
} catch {
    // Handle Error
}

try! willOnlyThrowIfTrue(false)


// Specifying Clean-Up Actions
// A defer statement defers execution until the current scope is exited.
// Deferred statements may not contain any code that would transfer control out of the statements, such as a break or return statement, or by throwing an error. 
// Deferred actions are executed in reverse order of how they are specified.

enum FileError: ErrorType {
    case endOfFile
    case fileClosed
}

func exists(filename: String) -> Bool { return true }
class FakeFile {
    var isOpen = false
    var filename = ""
    var lines = 100
    func readline() throws -> String? {
        if self.isOpen {
            if lines > 0 {
                lines -= 1
                return "line number \(lines) of text\n"
            } else {
                throw FileError.endOfFile
                //return nil
            }
        } else {
            throw FileError.fileClosed
        }
    }
}

func open(filename: String) -> FakeFile {
    let file = FakeFile()
    file.filename = filename
    file.isOpen = true
    print("\(file.filename) has been opened")
    return file
}

func close(file: FakeFile) {
    file.isOpen = false
    print("\(file.filename) has been closed")
}

func processFile(filename: String) throws {
    if exists(filename) {
        let file = open(filename)
        defer {
            close(file)
        }
        while let line = try file.readline() {
            // Work with the file
            print(line)
        }
        // close(file) is called here, at the end of the scope.
    }
}

do {
    try processFile("myFakeFile")
} catch FileError.endOfFile {
    print("Reached the end of the file")
} catch FileError.fileClosed {
    print("The file isn't open")
}






