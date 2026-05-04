QDL.nowrap :Math

QDL.type :Math, 'self.acos', '(%real x) -> Float'
QDL.pre(:Math, 'self.acos') { |x| -1 <= x && x <= 1 }
QDL.post(:Math, 'self.acos') { |r, _| 0 <= r && r <= Math::PI }
QDL.type :Math, 'self.acosh', '(%real x) -> Float'
QDL.pre(:Math, 'self.acosh') { |x| 1 <= x }
QDL.post(:Math, 'self.acosh') { |r, _| 0 <= r }
QDL.type :Math, 'self.asin', '(%real x) -> Float'
QDL.pre(:Math, 'self.asin') { |x| -1 <= x && x <= 1 }
QDL.post(:Math, 'self.asin') { |r, _| -Math::PI/2 <= r && r <= Math::PI/2 }
QDL.type :Math, 'self.asinh', '(%real x) -> Float'
QDL.type :Math, 'self.atan', '(%real x) -> Float'
QDL.post(:Math, 'self.atan') { |r, _| -Math::PI/2 <= r && r <= Math::PI/2 }
QDL.type :Math, 'self.atan2', '(%real y, %real x) -> Float'
QDL.post(:Math, 'self.atan2') { |r, _| -Math::PI <= r && r <= Math::PI }
QDL.type :Math, 'self.atanh', '(%real x) -> Float'
QDL.pre(:Math, 'self.atanh') { |x| -1 < x && x < 1 }
QDL.type :Math, 'self.cbrt', '(%real x) -> Float'
QDL.pre(:Math, 'self.cbrt') { |x| 0 <= x }
QDL.post(:Math, 'self.cbrt') { |x| 0 <= x }
QDL.type :Math, 'self.cos', '(%real x) -> Float'
QDL.post(:Math, 'self.cos') { |r, _| -1 <= r && r <= 1 }
QDL.type :Math, 'self.cosh', '(%real x) -> Float'
QDL.post(:Math, 'self.cosh') { |r, _| 1 <= r }
QDL.type :Math, 'self.erf', '(%real x) -> Float'
QDL.post(:Math, 'self.erf') { |r, _| -1 < r && r < 1 }
QDL.type :Math, 'self.erfc', '(%real x) -> Float'
QDL.post(:Math, 'self.erfc') { |r, _| 0 < r && r < 2 }
QDL.type :Math, 'self.exp', '(%real x) -> Float'
QDL.post(:Math, 'self.exp') { |r, _| 0 < r }
QDL.type :Math, 'self.frexp', '(%real x) -> [%real, %real]'
QDL.type :Math, 'self.gamma', '(%real x) -> Float'
QDL.type :Math, 'self.hypot', '(%real x, %real y) -> Float'
QDL.type :Math, 'self.ldexp', '(%real fraction, %real exponent) -> Float'
QDL.type :Math, 'self.lgamma', '(%real x) -> -1 or 1 or Float'
QDL.type :Math, 'self.log', '(%real x, ?(%real) base) -> Float'
QDL.type :Math, 'self.log10', '(%real x) -> Float'
QDL.pre(:Math, 'self.log10') { |x| 0 < x }
QDL.type :Math, 'self.log2', '(%real x) -> Float'
QDL.pre(:Math, 'self.log2') { |x| 0 < x }
QDL.type :Math, 'self.sin', '(%real x) -> Float'
QDL.post(:Math, 'self.sin') { |r, _| -1 <= r && r <= 1 }
QDL.type :Math, 'self.sinh', '(%real x) -> Float'
QDL.type :Math, 'self.sqrt', '(%real x) -> Float'
QDL.pre(:Math, 'self.sqrt') { |x| 0 <= x }
QDL.post(:Math, 'self.sqrt') { |r, _| 0 <= r }
QDL.type :Math, 'self.tan', '(%real x) -> Float'
QDL.type :Math, 'self.tanh', '(%real x) -> Float'
QDL.post(:Math, 'self.tanh') { |r, _| -1 < r && r < 1 }
