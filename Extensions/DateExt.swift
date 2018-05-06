import Foundation

private var _localizedDateFormatter: DateFormatter?

extension Date {
    public func localizedString(with format: String) -> String
    {
        if _localizedDateFormatter == nil
        {
            _localizedDateFormatter = DateFormatter()
            _localizedDateFormatter?.locale = Locale.current
            _localizedDateFormatter?.timeZone = TimeZone.autoupdatingCurrent
        }
        _localizedDateFormatter!.dateFormat = format
        let strTimeFormatted = _localizedDateFormatter!.string(from: self)
        return strTimeFormatted
    }
    
    public func stringWithRFC3339Format() -> String
    {
        return localizedString(with: "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'")
    }
    
    init(RFC3339: String)
    {
        if _localizedDateFormatter == nil
        {
            _localizedDateFormatter = DateFormatter()
            _localizedDateFormatter?.locale = Locale.current
            _localizedDateFormatter?.timeZone = TimeZone.autoupdatingCurrent
        }
        
        _localizedDateFormatter!.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZ'"
        var date = _localizedDateFormatter!.date(from: RFC3339)
        if date == nil {
            // ah, shit, try with another format
            _localizedDateFormatter!.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            date = _localizedDateFormatter!.date(from: RFC3339)
        }
        self = date!
    }
}
