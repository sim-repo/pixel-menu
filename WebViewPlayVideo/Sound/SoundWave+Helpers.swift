import UIKit

extension URL {
    static func checkPath(_ path: String) -> Bool {
        let isFileExist = FileManager.default.fileExists(atPath: path)
        return isFileExist
    }
	
	static func documentsPath(forFileName fileName: String) -> URL? {
		let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
		let writePath = URL(string: documents)!.appendingPathComponent(fileName)
		
		var directory: ObjCBool = ObjCBool(false)
		if FileManager.default.fileExists(atPath: documents, isDirectory:&directory) {
			return directory.boolValue ? writePath : nil
		}
		return nil
	}
}

extension UIViewController {
	func showAlert(with error: Error) {
		let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
			alertController.dismiss(animated: true, completion: nil)
		})
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
	}
}
