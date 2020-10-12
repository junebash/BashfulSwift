//
//  File.swift
//  
//
//  Created by Jon Bash on 2020-10-10.
//

import Foundation


public enum Either<A, B> {
	case a(A)
	case b(B)

	public var a: A? {
		if case .a(let a) = self { return a } else { return nil }
	}
	public var b: B? {
		if case .b(let b) = self { return b } else { return nil }
	}
}


extension Either {
	var flipped: Either<B, A> {
		switch self {
		case .a(let a): return .b(a)
		case .b(let b): return .a(b)
		}
	}

	func map<NewA>(transformA: (A) -> NewA) -> Either<NewA, B> {
		switch self {
		case .a(let a): return .a(transformA(a))
		case .b(let b): return .b(b)
		}
	}

	func mapB<NewB>(_ transform: (B) -> NewB) -> Either<A, NewB> {
		switch self {
		case .a(let a): return .a(a)
		case .b(let b): return .b(transform(b))
		}
	}

	func flatMap<NewA>(
		_ transform: (A) -> Either<NewA, B>
	) -> Either<NewA, B> {
		switch self {
		case .a(let a): return transform(a)
		case .b(let b): return .b(b)
		}
	}

	func flatMapB<NewB>(
		_ transform: (B) -> Either<A, NewB>
	) -> Either<A, NewB> {
		switch self {
		case .a(let a): return .a(a)
		case .b(let b): return transform(b)
		}
	}
}


extension Either where A == B {
	var unwrapped: A {
		switch self {
		case .a(let x), .b(let x): return x
		}
	}
}


extension Either where A == Void {
	var asOptional: B? {
		switch self {
		case .a: return nil
		case .b(let b): return b
		}
	}
}

extension Either where B == Void {
	var asOptional: A? {
		switch self {
		case .a(let a): return a
		case .b: return nil
		}
	}
}

extension Optional {
	var asEither: Either<Wrapped, Void> {
		switch self {
		case .some(let wrapped): return .a(wrapped)
		case .none: return .b(())
		}
	}
}
