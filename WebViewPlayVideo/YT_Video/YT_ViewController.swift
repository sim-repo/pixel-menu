import UIKit

class YT_ViewController: UIViewController {
    
    @IBOutlet weak var audioVisualizationView: AudioVisualizationView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var bkgView: MyView_GradiendBackground!
    @IBOutlet var shimmerView: MyView_Shimmer!
    @IBOutlet weak var pixelView: PixelView!
    var timer: Timer?
    
    
    private var chronometer: Chronometer?
    private let viewModel = ViewModel()
    private var distance: CGFloat = 0
    private var currPos: CGFloat = 0
    private var halfItemHeight: CGFloat = 0
    
    lazy var videoDidReady: (()->Void)? = {[weak self] in
        self?.stopRedrawPixel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.askAudioRecordingPermission()
        setupShimmer()
        setupComet()
        self.viewModel.audioMeteringLevelUpdate = { [weak self] meteringLevel in
            guard let self = self else { return }
            self.audioVisualizationView.add(meteringLevel: meteringLevel)
        }
        
        self.viewModel.audioDidFinish = { [weak self] in
            self?.audioVisualizationView.stop()
        }
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        halfItemHeight = layout.itemSize.height / 2
    }
    
    
    
    
    
    private func setupShimmer(){
        shimmerView.setup(text: "Prototype", font: arcadeFont!, color: .green)
    }
    
    private func redrawPixel(){
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    private func stopRedrawPixel(){
        print("")
        print("")
        print("")
        print("")
        
        print("")
        print("Stop")
        timer?.invalidate()
    }
 
    @objc func fireTimer() {
        pixelView.setNeedsDisplay()
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
    
    private func setupComet(){
        let width = shimmerView.bounds.width
        let height = shimmerView.bounds.height
        let comets = [Comet(startPoint: CGPoint(x: 100, y: 0),
                            endPoint: CGPoint(x: 0, y: 100),
                            lineColor: UIColor.green.withAlphaComponent(0.1),
                            cometColor: UIColor.green),
                      Comet(startPoint: CGPoint(x: 0.4 * width, y: 0),
                            endPoint: CGPoint(x: width, y: 0.8 * width),
                            lineColor: UIColor.green.withAlphaComponent(0.1),
                            cometColor: UIColor.green),
                      Comet(startPoint: CGPoint(x: 0.8 * width, y: 0),
                            endPoint: CGPoint(x: width, y: 0.2 * width),
                            lineColor: UIColor.green.withAlphaComponent(0.1),
                            cometColor: UIColor.green),
                      Comet(startPoint: CGPoint(x: width, y: 0.2 * height),
                            endPoint: CGPoint(x: 0, y: 0.25 * height),
                            lineColor: UIColor.green.withAlphaComponent(0.1),
                            cometColor: UIColor.green),
                      Comet(startPoint: CGPoint(x: 0, y: height - 0.8 * width),
                            endPoint: CGPoint(x: 0.6 * width, y: height),
                            lineColor: UIColor.green.withAlphaComponent(0.1),
                            cometColor: UIColor.green),
                      Comet(startPoint: CGPoint(x: width - 100, y: height),
                            endPoint: CGPoint(x: width, y: height - 100),
                            lineColor: UIColor.green.withAlphaComponent(0.1),
                            cometColor: UIColor.green),
                      Comet(startPoint: CGPoint(x: 0, y: 0.8 * height),
                            endPoint: CGPoint(x: width, y: 0.75 * height),
                            lineColor: UIColor.green.withAlphaComponent(0.1),
                            cometColor: UIColor.green)]
        for comet in comets {
            shimmerView.layer.addSublayer(comet.drawLine())
            shimmerView.layer.addSublayer(comet.animate())
        }
    }
}




extension YT_ViewController: UICollectionViewDelegate {
    
}

extension YT_ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Model.list().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YTCollectionViewCell", for: indexPath) as! YT_CollectionViewCell
        
        let model = Model.list()[indexPath.row]
        
        cell.setup(url: model.url!, videoDidReadyCompletion: videoDidReady)
        return cell
    }
}


extension YT_ViewController: UIScrollViewDelegate {
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard cleanupVideo(scrollView) else {return}
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidEndScrolling(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidEndScrolling(scrollView)
        }
    }
    
    private func cleanupVideo(_ scrollView: UIScrollView) -> Bool {
        
        let distance = abs(scrollView.contentOffset.y - currPos)
        guard distance > halfItemHeight else { return false}
        
        let indexPaths = collectionView.indexPathsForVisibleItems
        for idx in indexPaths {
            let cell = collectionView.cellForItem(at: idx) as! YT_CollectionViewCell
            cell.backgroundColor = UIColor.blue
            cell.stopVideo()
            do {
                try self.viewModel.resetRecording()
            } catch (let err) {
                print(err.localizedDescription)
            }
            view.layoutIfNeeded()
        }
        return true
    }
    
    
    private func scrollViewDidEndScrolling(_ scrollView: UIScrollView) {
        
        guard cleanupVideo(scrollView) else {return}
        
        currPos = scrollView.contentOffset.y
        
        let centerPoint = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        let collectionViewCenterPoint = self.view.convert(centerPoint, to: collectionView)
        
        if let indexPath = collectionView.indexPathForItem(at: collectionViewCenterPoint) {
            let cell = collectionView.cellForItem(at: indexPath) as! YT_CollectionViewCell
            redrawPixel()
            cell.startVideo()
            showSoundSpectrum()
            
            view.layoutIfNeeded()
        }
    }
    
}
