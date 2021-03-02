extension String.StringInterpolation {
    mutating func appendInterpolation<T: CustomStringConvertible>(_ val: T?) {
        if let val = val {
            appendInterpolation(val)
        } else {
            appendInterpolation("nil")
        }
    }

    mutating func appendInterpolation<T: Swift.Error>(_ val: T?) {
        if let val = val {
            appendInterpolation(val)
        } else {
            appendInterpolation("nil")
        }
    }
}
