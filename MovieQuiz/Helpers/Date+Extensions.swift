import Foundation

extension Date {
    var dateTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YY HH:mm"
        return dateFormatter.string(from: self)
    }
}
