public extension Array {
    subscript(safeIndex index: Index) -> Element? {
        if indices ~= index {
            return self[index]
        } else {
            return nil
        }
    }
}
