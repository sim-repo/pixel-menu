import AVFoundation
import UIKit

public class AudioVisualizationView: UIView{
    
    var meteringLevelBarWidth: CGFloat = 30.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var meteringLevelBarInterItem: CGFloat = 2 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var meteringLevelBarCornerRadius: CGFloat = 2.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    public var audioVisualizationTimeInterval: TimeInterval = 1 // Time interval between each metering bar representation

    private var meteringLevelsArray: [Float] = []    // Mutating recording array (values are percentage: 0.0 to 1.0)
    private var meteringLevelsClusteredArray: [Float] = [] // Generated read mode array (values are percentage: 0.0 to 1.0)
    
    private var currentMeteringLevelsArray: [Float] {
        if !self.meteringLevelsClusteredArray.isEmpty {
            return meteringLevelsClusteredArray
        }
        return meteringLevelsArray
    }
    
    private var playChronometer: Chronometer?
    
    static var audioVisualizationDefaultGradientStartColor: UIColor {
        return UIColor(red: 61.0 / 255.0, green: 20.0 / 255.0, blue: 117.0 / 255.0, alpha: 1.0)
    }
    
    static var audioVisualizationDefaultGradientMidColor: UIColor {
        return #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
    }
    
    static var gradientMid2Color: UIColor {
        return #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
    }
    
    static var gradientMid3Color: UIColor {
        return #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    }
    
    static var audioVisualizationDefaultGradientEndColor: UIColor {
        return UIColor(red: 166.0 / 255.0, green: 150.0 / 255.0, blue: 225.0 / 255.0, alpha: 1.0)
    }
    
    @IBInspectable public var gradientStartColor: UIColor = AudioVisualizationView.audioVisualizationDefaultGradientStartColor {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable public var gradientMidColor: UIColor = AudioVisualizationView.audioVisualizationDefaultGradientMidColor {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable public var gradientEndColor: UIColor = AudioVisualizationView.audioVisualizationDefaultGradientEndColor {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let context = UIGraphicsGetCurrentContext() {
            self.drawLevelBarsMaskAndGradient(inContext: context)
        }
    }
    
    public func reset() {
        self.meteringLevelsClusteredArray.removeAll()
        self.meteringLevelsArray.removeAll()
        self.setNeedsDisplay()
    }
    
    // MARK: - Record Mode Handling
    
    public func add(meteringLevel: Float) {
        self.meteringLevelsArray.append(meteringLevel)
        self.setNeedsDisplay()
    }
    
    
    public func stop() {
        self.playChronometer?.stop()
        self.playChronometer = nil
        self.setNeedsDisplay()
    }
    
    // MARK: - Mask + Gradient
    
    private func drawLevelBarsMaskAndGradient(inContext context: CGContext) {
        if self.currentMeteringLevelsArray.isEmpty {
            return
        }
        context.saveGState()
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        
        let maskContext = UIGraphicsGetCurrentContext()
        UIColor.black.set()
        
        self.drawMeteringLevelBars(inContext: maskContext!)
        
        let mask = UIGraphicsGetCurrentContext()?.makeImage()
        UIGraphicsEndImageContext()
        
        context.clip(to: self.bounds, mask: mask!)
        
        self.drawGradient(inContext: context)
        
        context.restoreGState()
    }
    
    
    private func drawGradient(inContext context: CGContext) {
        if self.currentMeteringLevelsArray.isEmpty {
            return
        }
        
        context.saveGState()
        
        let startPoint = CGPoint(x: 0.0, y: self.centerY)
        let endPoint = CGPoint(x: self.xLeftMostBar() + self.meteringLevelBarWidth, y: self.centerY)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        
        let colorLocations: [CGFloat] = [0.0, 0.3, 0.5, 0.7,  1.0]
        let colors = [self.gradientStartColor.cgColor,
                      self.gradientMidColor.cgColor,
                      AudioVisualizationView.gradientMid2Color.cgColor,
                      AudioVisualizationView.gradientMid3Color.cgColor,
                      self.gradientEndColor.cgColor]
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
        
        context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
        context.restoreGState()

    }
    
    
    // MARK: - Bars
    
    private func drawMeteringLevelBars(inContext context: CGContext) {
        let offset = max(self.currentMeteringLevelsArray.count - self.maximumNumberBars, 0)
        
        for index in offset..<self.currentMeteringLevelsArray.count {
            self.drawBar(index - offset, meteringLevelIndex: index, context: context)
        }

    }
    
    private func drawBar(_ barIndex: Int, meteringLevelIndex: Int,  context: CGContext) {
        context.saveGState()
        
        let xPointForMeteringLevel = self.xPointForMeteringLevel(barIndex)
        let heightForMeteringLevel = self.heightForMeteringLevel(self.currentMeteringLevelsArray[meteringLevelIndex])
        
        var barPath: UIBezierPath!
    
            var barRect2 = CGRect(x: xPointForMeteringLevel,
                                  y: self.centerY  - heightForMeteringLevel * 2,
                                  width: self.meteringLevelBarWidth,
                                  height: heightForMeteringLevel)
            barPath = UIBezierPath(roundedRect: barRect2, cornerRadius: self.meteringLevelBarCornerRadius)
            UIColor.black.set()
            barPath.fill()
            
            barRect2 = CGRect(x: xPointForMeteringLevel,
                                  y: self.centerY + heightForMeteringLevel * 2,
                                  width: self.meteringLevelBarWidth,
                                  height: heightForMeteringLevel)
            barPath = UIBezierPath(roundedRect: barRect2, cornerRadius: self.meteringLevelBarCornerRadius)
            UIColor.black.set()
            barPath.fill()
            
            
        
        context.restoreGState()
    }
    
   
    
    // MARK: - Points Helpers
    
    private var centerY: CGFloat {
        return self.frame.size.height / 2.0
    }
    
    private var maximumBarHeight: CGFloat {
        return self.frame.size.height / 6.0
    }
    
    private var maximumNumberBars: Int {
        return Int(self.frame.size.width / (self.meteringLevelBarWidth + self.meteringLevelBarInterItem))
    }
    
    private func xLeftMostBar() -> CGFloat {
        return self.xPointForMeteringLevel(min(self.maximumNumberBars - 1, self.currentMeteringLevelsArray.count - 1))
    }
    
    private func heightForMeteringLevel(_ meteringLevel: Float) -> CGFloat {
        return CGFloat(meteringLevel) * self.maximumBarHeight
    }
    
    private func xPointForMeteringLevel(_ atIndex: Int) -> CGFloat {
        return CGFloat(atIndex) * (self.meteringLevelBarWidth + self.meteringLevelBarInterItem)
    }
}
