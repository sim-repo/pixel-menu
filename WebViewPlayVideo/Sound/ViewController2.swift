import UIKit

final class ViewController2: UIViewController {
    
    @IBOutlet private var recordButton: UIButton!
    @IBOutlet weak var audioVisualizationView: AudioVisualizationView!
    
    private var chronometer: Chronometer?
    private let viewModel = ViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.askAudioRecordingPermission()
        
        self.viewModel.audioMeteringLevelUpdate = { [weak self] meteringLevel in
            guard let self = self else { return }
            self.audioVisualizationView.add(meteringLevel: meteringLevel)
        }
        
        self.viewModel.audioDidFinish = { [weak self] in
            self?.audioVisualizationView.stop()
        }
    }
    
    
    @IBAction func recordButtonDidTouchDown(_ sender: Any) {
            self.viewModel.startRecording { [weak self] soundRecord, error in
                if let error = error {
                    self?.showAlert(with: error)
                    return
                }
                self?.chronometer = Chronometer()
                self?.chronometer?.start()
            }
    }
    
    
    
    @IBAction func removeRecord(_ sender: Any) {
        do {
            try self.viewModel.resetRecording()
        }catch (let err) {
            print(err.localizedDescription)
        }
    }
    
}




