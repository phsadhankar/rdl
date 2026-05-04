QDL.nowrap :Benchmark

QDL.type :Benchmark, 'self.benchmark', '(String, ?Integer, ?String, *String) -> Array<Benchmark::Tms>'
QDL.type :Benchmark, 'self.bm', '(?Integer, *String) { (Benchmark::Process) -> nil} -> Array<Benchmark::Tms>'
# QDL.type :Benchmark, 'self.benchmark', '(Caption: String, Label_Width: ?Integer, Format: ?String, Labels: *String) -> Benchmark::Tms'
# QDL.type :Benchmark, 'self.bm', '(Label_Width: ?Integer, Labels: *String) { (Benchmark::Process) -> nil} -> Array<Benchmark::Tms>'
QDL.type :Benchmark, 'self.bmbm', '(?Integer label_width) { (Benchmark::Process) -> nil} -> Array<Benchmark::Tms>'
QDL.type :Benchmark, 'self.measure', '(?String label) -> Benchmark::Tms'
QDL.type :Benchmark, 'self.realtime', '() {(*%any) -> %any} -> Integer'
