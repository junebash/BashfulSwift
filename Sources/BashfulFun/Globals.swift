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
	else caseNone: @escaping () -> R?
) -> (A?) -> R? {
	{ a in
		a.map(caseSome) ?? caseNone()
	}
}

public func zurry<A, R>(
	_ f: @escaping () -> (A) -> (R)
) -> (A) -> R {
	{ a in
		f()(a)
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


