import UIKit

class MyViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
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
    
    private func showSoundSpectrum(){
        self.viewModel.startRecording { [weak self] soundRecord, error in
            if let error = error {
                self?.showAlert(with: error)
                return
            }
            self?.chronometer = Chronometer()
            self?.chronometer?.start()
        }
    }
}





extension MyViewController: UICollectionViewDelegate {
    
}

extension MyViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Model.list().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionCell", for: indexPath) as! My_CollectionViewCell
        
        let model = Model.list()[indexPath.row]
        
        cell.setup(url: model.url!)
        return cell
    }
}


extension MyViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let indexPaths = collectionView.indexPathsForVisibleItems
        for idx in indexPaths {
            
            let cell = collectionView.cellForItem(at: idx) as! My_CollectionViewCell
            cell.backgroundColor = UIColor.blue
            cell.stopVideo()
            do {
                try self.viewModel.resetRecording()
            } catch (let err) {
                print(err.localizedDescription)
            }
            view.layoutIfNeeded()
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidEndScrolling(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidEndScrolling(scrollView)
        }
    }
    
    private func scrollViewDidEndScrolling(_ scrollView: UIScrollView) {
        
        let centerPoint = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        let collectionViewCenterPoint = self.view.convert(centerPoint, to: collectionView)
        
        if let indexPath = collectionView.indexPathForItem(at: collectionViewCenterPoint) {
            let cell = collectionView.cellForItem(at: indexPath) as! My_CollectionViewCell
            cell.backgroundColor = UIColor.red
            cell.startVideo()
            showSoundSpectrum()
            view.layoutIfNeeded()
        }
    }
    
}
