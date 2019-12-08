import UIKit



class PixelView: UIView {
    
    let colors = [
        #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),#colorLiteral(red: 0.1077902392, green: 0.1093362346, blue: 0.0949825123, alpha: 1),#colorLiteral(red: 0.1072580293, green: 0.1072837338, blue: 0.1072546914, alpha: 1),#colorLiteral(red: 0.1072580293, green: 0.1072837338, blue: 0.1072546914, alpha: 1),.clear
    ]
    var currPixel: CGPoint?
    var pixels = [Int:Int]()
    
    override func draw(_ rect: CGRect) {
        
        let elementSize: CGFloat = 5
        
        let context = UIGraphicsGetCurrentContext()!
        
        for y in stride(from: 0.0, to: rect.height, by: elementSize) {
            for x in stride(from: 0.0, to: rect.width, by: elementSize) {
                
                var idx = 0
                idx = Int.random(in: 0..<colors.count)

                let color = colors[idx]
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: x, y: y, width: elementSize, height: elementSize))
            }
        }
    }

}


class PixelViewBkg : UIView {
    
override func draw(_ rect: CGRect) {

       let elementSize: CGFloat = 80

       let context = UIGraphicsGetCurrentContext()!
       
       for y in stride(from: 0.0, to: rect.height, by: elementSize) {
        var color = UIColor.blue.withAlphaComponent(y / rect.height)
           for x in stride(from: 0.0, to: rect.width, by: elementSize) {
            color = UIColor.blue.withAlphaComponent(y / rect.height + x / rect.height)
               context.setFillColor(color.cgColor)
               context.fill(CGRect(x: x, y: y, width: elementSize, height: elementSize))
           }
       }
   }
}
