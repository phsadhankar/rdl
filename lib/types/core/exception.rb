QDL.nowrap :Exception

QDL.type :Exception, :==, '(%any) -> %bool'
QDL.type :Exception, :backtrace, '() -> Array<String>'
QDL.type :Exception, :backtrace_locations, '() -> Array<Thread::Backtrace::Location>'
QDL.type :Exception, :cause, '() -> nil' # TODO exception is proper postcondition
QDL.type :Exception, :exception, '(?String) -> Exception' # or error
# QDL.type :Exception, :initialize, '() -> '
QDL.type :Exception, :inspect, '() -> String'
QDL.type :Exception, :message, '() -> String'
# QDL.type :Exception, :method_missing, '() -> '
# QDL.type :Exception, :respond_to?, '() -> '
# QDL.type :Exception, :respond_to_missing?, '() -> '
QDL.type :Exception, :set_backtrace, '(String or Array<String>) -> Array<String>'
QDL.type :Exception, :to_s, '() -> String'
