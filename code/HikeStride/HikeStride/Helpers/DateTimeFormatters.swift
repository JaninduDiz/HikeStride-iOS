//
//  DateTimeFormatters.swift
//  HikeStride
//
//  Created by Janindu Dissanayake on 2024-06-11.
//

import Foundation

 func formatTime(_ time: TimeInterval) -> String {
    let hours = Int(time) / 3600
    let minutes = (Int(time) % 3600) / 60
    let seconds = Int(time) % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}

 func convertDateString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm MMM dd"
        return dateFormatter.string(from: date)
}

func formatTimeString(_ timeString: String) -> String {
    let components = timeString.split(separator: ":").map { String($0) }
    
    guard components.count == 3 else {
        return "Invalid time format"
    }
    
    let hours = Int(components[0]) ?? 0
    let minutes = Int(components[1]) ?? 0
    let seconds = Int(components[2]) ?? 0
    
    var formattedString = ""
    
    if hours > 0 {
        formattedString += "\(hours)h "
    }
    
    formattedString += "\(String(format: "%02d", minutes))m "
    formattedString += "\(String(format: "%02d", seconds))s"
    
    return formattedString.trimmingCharacters(in: .whitespaces)
}
