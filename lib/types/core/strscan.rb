QDL.nowrap :StringScanner

QDL.type :StringScanner, 'self.new', '(String, ?%bool) -> StringScanner'
QDL.type :StringScanner, :eos?, '() -> %bool'
QDL.type :StringScanner, :scan, '(Regexp) -> String'
QDL.type :StringScanner, :getch, '() -> String'
