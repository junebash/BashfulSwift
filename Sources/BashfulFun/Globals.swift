
/// A function that returns whatever is passed into it unchanged. Useful with methods that take in a transform closure, such as `compactMap` or `flatMap`.
///
/// **Example**:
/// ```
/// [1, nil, 2, 3, nil, 4].compactMap(id) // [1, 2, 3, 4]
/// [[1, 2], [3, 4, 5], [6]].flatMap(id) // [1, 2, 3, 4, 5, 6]
/// ```
public func id<A>(_ a: A) -> A { a }
