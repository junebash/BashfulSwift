
/// A function that returns whatever is passed into it unchanged. Useful with methods that take in a transform closure, such as `compactMap` or `flatMap`.
///
/// **Example**:
/// ```
/// [1, nil, 2, 3, nil, 4].compactMap(id) // [1, 2, 3, 4]
/// [[1, 2], [3, 4, 5], [6]].flatMap(id) // [1, 2, 3, 4, 5, 6]
/// ```
public func id<A>(_ a: A) -> A { a }

public func curry<A1, A2, R>(
	_ f: @escaping (A1, A2) -> R
) -> (A1) -> (A2) -> R {
	{ a in
		{ b in
			f(a, b)
		}
	}
}

public func uncurry<A1, A2, R>(
	_ f: @escaping (A1) -> (A2) -> R
) -> (A1, A2) -> R {
	{ a, b in
		f(a)(b)
	}
}

public func uncurry<A1, A2, A3, R>(
	_ f: @escaping (A1) -> (A2) -> (A3) -> R
) -> (A1, A2, A3) -> R {
	{ a1, a2, a3 in
		f(a1)(a2)(a3)
	}
}

public func ifNonNil<A, R>(
	_ caseSome: @escaping (A) -> R,
	else caseNone: @escaping @autoclosure () -> R?
) -> (A?) -> R? {
	{ possA in
		if let a = possA {
			return caseSome(a)
		} else {
			return caseNone()
		}
	}
}

public func zurry<A, R>(
	_ f: @escaping () -> (A) -> (R)
) -> (A) -> R {
	{ a in
		f()(a)
	}
}

public func dethrow<A, R>(
	_ f: @escaping (A) -> R
) -> (A) -> R? {
	{ a in
		f(a)
	}
}

public func flip<A1, A2, R>(
	_ f: @escaping (A1, A2) -> R
) -> (A2, A1) -> R {
	{ b, a in
		f(a, b)
	}
}

public func flip<A1, A2, R>(
	_ f: @escaping (A1) -> (A2) -> R
) -> (A2) -> (A1) -> R {
	{ b in
		{ a in
			f(a)(b)
		}
	}
}


