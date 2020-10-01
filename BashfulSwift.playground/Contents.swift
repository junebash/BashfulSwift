import BashfulCore
import BashfulUIKit
import BashfulFun


let x = [8, nil, 4, 2, nil, nil, 23]
let y = x.compactMap(id)

func log(_ x: Any) {
	print(x)
}

//[[8, nil], [2, 4, nil], [23, 544]]
//	.flatMap(_:)
//	<<< ([Int?].compactMap(_:)
//			<<< (Optional<Int>.map(_:)
//					<<< String.init))

([[8, nil], [2, 4, nil], [23, 544, nil, 69]]
	.flatMap {
		$0.compactMap(String.init <?> nil)
	}.joined()
	|> Int.init ?? 0
) |> log
