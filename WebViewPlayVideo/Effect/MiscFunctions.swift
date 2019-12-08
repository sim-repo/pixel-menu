import UIKit


func getSystemImage(name: String, pointSize: CGFloat, color: UIColor) -> UIImage?{
    let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .light, scale: .large)
    return UIImage(systemName: name, withConfiguration: config)?.withTintColor(color, renderingMode: .alwaysOriginal)
}


let arcadeFont = UIFont(name: "Arcade", size: 45)
