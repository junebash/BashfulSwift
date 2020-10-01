// MARK: - Precedence Groups

precedencegroup ParameterPipePrecedence {
	associativity: left
	higherThan: NilCoalescingPrecedence
}

precedencegroup FunctionCompositionPrecedence {
	associativity: left
	higherThan: ParameterPipePrecedence
}

// MARK: - Operators

infix operator |>: ParameterPipePrecedence

infix operator >>>: FunctionCompositionPrecedence

infix operator <<<: FunctionCompositionPrecedence

/// if non-nil _ else _
infix operator <?>: FunctionCompositionPrecedence

/// Throw-unwrap
infix operator -?>

/// Curry
prefix operator <~>

/// Uncurry
prefix operator >~<

/// Zurry
prefix operator |~>

/// Flip
prefix operator /~/

/// Dethrow
postfix operator |?

/// Force-Dethrow
postfix operator |!

postfix operator <?

// MARK: - Implementations

/// Pipe a parameter into a function.
///
/// Example:
/// ```
/// [3, 4, 5].map(String.init)
/// ```
public func |> <A, B>(a: A, f: (A) -> B) -> B {
	f(a)
}

public func |> <A, B, C>(
	a: A,
	f: @escaping (A, B) -> C
) -> (B) -> C {
	{ b in
		f(a, b)
	}
}

public func >>> <A, B, C>(
	a2b: @escaping (A) -> B,
	b2c: @escaping (B) -> C
) -> ((A) -> C) {
	{ a in
		b2c(a2b(a))
	}
}

public func <<< <A, B, C>(
	b2c: @escaping (B) -> C,
	a2b: @escaping (A) -> B
) -> ((A) -> C) {
	{ a in
		b2c(a2b(a))
	}
}

public func <?> <A, R>(
	_ caseSome: @escaping (A) -> R,
	_ caseNone: @escaping @autoclosure () -> R?
) -> (A?) -> R? {
	ifNonNil(caseSome, else: caseNone())
}

/// Curry
public prefix func <~> <A, B, C>(
	_ f: @escaping (A, B) -> C
) -> (A) -> (B) -> C {
	curry(f)
}

/// Uncurry
public prefix func >~< <A, B, C>(
	_ f: @escaping (A) -> (B) -> C
) -> (A, B) -> C {
	uncurry(f)
}

public prefix func >~< <A1, A2, A3, R>(
	_ f: @escaping (A1) -> (A2) -> (A3) -> R
) -> (A1, A2, A3) -> R {
	uncurry(f)
}

/// Flip
public prefix func /~/ <A, B, C>(
	_ f: @escaping (A, B) -> C
) -> (B, A) -> C {
	flip(f)
}

/// flip
public prefix func /~/ <A, B, C>(
	_ f: @escaping (A) -> (B) -> C
) -> (B) -> (A) -> C {
	flip(f)
}

/// Zurry
public prefix func |~> <A, R>(
	_ f: @escaping () -> (A) -> R
) -> (A) -> R {
	zurry(f)
}

/// Dethrow
public postfix func |? <A, B>(
	_ f: @escaping (A) throws -> B
) -> (A) -> B? {
	{ a in
		try? f(a)
	}
}

/// Force-Dethrow
public postfix func |! <A, B>(
	_ f: @escaping (A) throws -> B
) -> (A) -> B {
	{ a in
		try! f(a)
	}
}

/// throwUnwrap
public func -?> <A>(
	lhs: A?,
	error: Error
) throws -> A {
	try lhs.throwUnwrap(else: error)
}

/// throwUnwrap
public postfix func <? <A>(_ a: A?) throws -> A {
	try a.throwUnwrap()
}
