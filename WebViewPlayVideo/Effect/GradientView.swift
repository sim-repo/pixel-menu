import UIKit

class GradientView: UIView {
    
    lazy fileprivate var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        
        layer.colors = [UIColor(white: 0.0, alpha: 0.7).cgColor,
                        UIColor.clear.cgColor,
                        UIColor(white: 0.0, alpha: 0.7).cgColor]
        layer.locations = [NSNumber(value: 0.0 as Float),
                           NSNumber(value: 0.3 as Float),
                           NSNumber(value: 0.8 as Float)]
        return layer
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = bounds
        CATransaction.commit()
    }
}


class MyView_GradiendBackground : UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let topColor: UIColor = #colorLiteral(red: 0.2935038209, green: 0.0494454354, blue: 0.6099740863, alpha: 1)
        let bottomColor: UIColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        let layer = self.layer as! CAGradientLayer
        layer.colors = [topColor, bottomColor].map{$0.cgColor}
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint (x: 0.5, y: 0.3)
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
}







class MyView_Shimmer: UIView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    
    func setup(text: String, font: UIFont, color: UIColor) {
        
        //dark:
        let darkLabel = UILabel()
        darkLabel.text = text
        darkLabel.textColor = color
        darkLabel.font = font
        darkLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        darkLabel.textAlignment = .center
        addSubview(darkLabel)
        
        
        let lightLabel = UILabel()
        lightLabel.text = text
        lightLabel.textColor = .white
        lightLabel.font = font
        lightLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        lightLabel.textAlignment = .center
        addSubview(lightLabel)
        
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0,0.5,1]
        gradientLayer.frame = lightLabel.frame
        let angle = 90 * CGFloat.pi / 180
        gradientLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
        
        lightLabel.layer.mask = gradientLayer
        animate(gradient: gradientLayer)
    }
    
    func animate(gradient: CAGradientLayer) {
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.duration = 10
        animation.fromValue = -frame.width
        animation.toValue = frame.width
        animation.repeatCount = Float.infinity
        gradient.add(animation, forKey: "fo")
    }
}
