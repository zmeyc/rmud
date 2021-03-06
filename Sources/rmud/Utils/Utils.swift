import Foundation

private let nameParentheses = CharacterSet(charactersIn: "()")

func clamping<T>(_ value: T, to range: ClosedRange<T>) -> T {
    return min(max(value, range.lowerBound), range.upperBound)
}

func isFillWord(_ word: String) -> Bool {
    return fillWordsLowercased.contains(word.lowercased())
}

func trimCommentsAndSpacing(in line: String, commentStart: String) -> String {
    var line = line
    if let commentRange = line.range(of: commentStart) {
        line.removeSubrange(commentRange.lowerBound ..< line.endIndex)
    }
    return line.trimmingCharacters(in: .whitespaces)
}

func assignNameParts(nameCombined: String,
                     nominative: inout String,
                     genitive: inout String,
                     dative: inout String,
                     accusative: inout String,
                     instrumental: inout String,
                     prepositional: inout String) {
    var forms = nameCombined
        .trimmingCharacters(in: nameParentheses)
        .components(separatedBy: ",")
        .map { $0.trimmingCharacters(in: .whitespaces) }
    while forms.count < 6 {
        forms.append("")
    }
    for (index, form) in forms.enumerated() {
        switch index {
        case 0: nominative = form
        case 1: genitive = form
        case 2: dative = form
        case 3: accusative = form
        case 4: instrumental = form
        case 5: prepositional = form
        default: break
        }
    }

}

//extension Collection where Indices.Iterator.Element == Index {
//    /// Returns the element at the specified index if it is within bounds, otherwise nil
//    subscript (safe index: Index) -> Generator.Element? {
//        return indices.contains(index) ? self[index] : nil
//    }
//}

func shell(executableURL: URL, arguments: [String] = [], input: String? = nil) throws -> (String? , Int32) {
    let task = Process()
    task.executableURL = executableURL
    task.arguments = arguments
    
    var inputPipe: Pipe?
    if input != nil {
        inputPipe = Pipe()
        task.standardInput = inputPipe
    }
    
    let outputPipe = Pipe()
    task.standardOutput = outputPipe
    task.standardError = outputPipe
    try task.run()
    
    if let inputPipe = inputPipe, let input = input {
        let bytes: [UInt8] = Array(input.utf8)
        let fileHandle = inputPipe.fileHandleForWriting
        fileHandle.write(Data(bytes))
        fileHandle.closeFile()
    }
    
    let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    task.waitUntilExit()
    return (output, task.terminationStatus)
}

func shell(executable: String, arguments: [String] = [], input: String? = nil) throws -> (String? , Int32) {
    let url = URL(fileURLWithPath: executable, isDirectory: false)
    return try shell(executableURL: url, arguments: arguments, input: input)
}
