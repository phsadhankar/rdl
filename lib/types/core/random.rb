QDL.nowrap :Random

QDL.type :Random, :initialize, '(?Integer seed) -> self' # Floats can be passed also, but just truncated to int?
QDL.type :Random, 'self.new_seed', '() -> Integer'
QDL.type :Random, 'self.rand', '(?(Integer or Range<Numeric>) max) -> Numeric'
QDL.type :Random, 'self.srand', '(?Integer number) -> Numeric old_seed'

QDL.type :Random, :==, '(%any) -> %bool'
QDL.type :Random, :bytes, '(Integer size) -> String'
QDL.type :Random, :rand, '(?(Integer or Range<Integer>) max) -> Integer'
QDL.type :Random, :rand, '(?(Float or Range<Float>) max) -> Float'
QDL.pre(:Random, :rand) { |max| max > 0 }
QDL.type :Random, :seed, '() -> Integer'
