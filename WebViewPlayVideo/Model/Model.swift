import Foundation


class Model {
    var url: URL?
    
    init(url: String) {
        self.url = URL(string: url)!
    }
    
    
    public static func list()->[Model] {
        var arr = [Model]()
        
        arr.append(Model(url: "https://youtu.be/kXeQJnbc9bA"))
        arr.append(Model(url: "https://youtu.be/7dnlTNfwGyA"))
        arr.append(Model(url: "https://youtu.be/zFW_zflkMfs"))
        arr.append(Model(url: "https://youtu.be/gp04aRTNLsU"))
        return arr
    }
}
