//
//  HelperFunctiomns.swift
//  Bookworm
//
//  Created by Silvan Dubach on 22.10.2024.
//

import Foundation

public func truncatedTitle(_ title: String, length: Int) -> String {
    if title.count > length {
        let index = title.index(title.startIndex, offsetBy: length)
        return String(title[..<index]) + "..."
    } else {
        return title
    }
}

func dateStringFormatter(date: Date, formattingString: String, isUppercase: Bool = false) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = formattingString
    
    if(isUppercase) {
        return formatter.string(from: date).uppercased()
    }
    
    return formatter.string(from: date)
}
