QDL.type :Time, 'self.zone', '() -> ActiveSupport::TimeZone'
QDL.type :Time, :+, '(ActiveSupport::Duration) -> Time'
QDL.type :Time, :-, '(ActiveSupport::Duration) -> Time'
