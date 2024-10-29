import Foundation
/*
let genreColors: [String: String] = [
    "Architecture": "#5492fc",
    "Art": "#508cf9",
    "Biography & Autobiography": "#4d85f6",
    "Business & Economics": "#4a7ff3",
    "Comics": "#4779ef",
    "Cooking": "#4572ec",
    "Crafts & Hobbies": "#436ce8",
    "Design": "#4165e4",
    "Drama": "#405ee0",
    "Education": "#4058dc",
    "Fiction": "#3f51d8",
    "Games & Activities": "#3f4ad3",
    "Health & Fitness": "#3f42cf",
    "History": "#3f3bca",
    "Humor": "#4033c5",
    "Juvenile": "#402bc0",
    "Language Arts & Disciplines": "#4121ba",
    "Law": "#4116b5",
    "Literary Criticism": "#4204af",
    "Mathematics": "#5800ad",
    "Medical": "#6a00aa",
    "Music": "#7900a6",
    "Nature": "#8600a1",
    "Non-Classifiable": "#92009c",
    "Nonfiction": "#9c0097",
    "Performing Arts": "#a70093",
    "Philosophy": "#b10090",
    "Photography": "#ba008c",
    "Poetry": "#c40089",
    "Political Science": "#cd0085",
    "Psychology": "#d60081",
    "Religion": "#de007d",
    "Science": "#e50079",
    "Self-Help": "#ea0a75",
    "Social Science": "#f02071",
    "Sports & Recreation": "#f42f6d",
    "Technology & Engineering": "#f83c6a",
    "Travel": "#fc4766"
 ]
 
 let assetFolder = "GeneratedColors.xcassets"
 let colorPath = FileManager.default.currentDirectoryPath + "/" + assetFolder
 try? FileManager.default.createDirectory(atPath: colorPath, withIntermediateDirectories: true)
 
 for (genre, hex) in genreColors {
 let colorName = genre.replacingOccurrences(of: " ", with: "_") // Replace spaces with underscores for filenames
 let colorFolder = "\(colorPath)/\(colorName).colorset"
 try? FileManager.default.createDirectory(atPath: colorFolder, withIntermediateDirectories: true)
 
 // Get RGB values from the hex string
 let red = Int(hex.dropFirst(1).prefix(2), radix: 16) ?? 0
 let green = Int(hex.dropFirst(3).prefix(2), radix: 16) ?? 0
 let blue = Int(hex.dropFirst(5).prefix(2), radix: 16) ?? 0
 
 // Calculate a lighter shade (10% lighter)
 let lighterRed = min(Int(Double(red) * 1.1), 255)
 let lighterGreen = min(Int(Double(green) * 1.1), 255)
 let lighterBlue = min(Int(Double(blue) * 1.1), 255)
 
 let colorContents = """
 {
 "colors" : [
 {
 "appearances" : [
 {
 "appearance" : "luminosity",
 "value" : "dark"
 }
 ],
 "idiom" : "universal",
 "color" : {
 "color-space" : "srgb",
 "components" : {
 "red" : "\(Double(red) / 255.0)",
 "green" : "\(Double(green) / 255.0)",
 "blue" : "\(Double(blue) / 255.0)",
 "alpha" : "1.0"
 }
 }
 },
 {
 "idiom" : "universal",
 "color" : {
 "color-space" : "srgb",
 "components" : {
 "red" : "\(Double(lighterRed) / 255.0)",
 "green" : "\(Double(lighterGreen) / 255.0)",
 "blue" : "\(Double(lighterBlue) / 255.0)",
 "alpha" : "1.0"
 }
 }
 }
 ],
 "info" : {
 "version" : 1,
 "author" : "xcode"
 }
 }
 """
 
 let filePath = "\(colorFolder)/Contents.json"
 try? colorContents.write(toFile: filePath, atomically: true, encoding: .utf8)
 }

*/
