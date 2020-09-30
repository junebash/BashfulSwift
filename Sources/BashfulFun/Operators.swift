
precedencegroup FunctionCompositionPrecedence {
	associativity: left
}

infix operator |>: FunctionCompositionPrecedence

public func |> <A, B>(lhs: A, rhs: (A) -> B) -> B {
	rhs(lhs)
}
