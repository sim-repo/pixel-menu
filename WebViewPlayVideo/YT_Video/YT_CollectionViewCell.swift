import UIKit
import youtube_ios_player_helper

protocol YT_ViewControllerDelegate {
    func didPressStartVideo(cell: YT_CollectionViewCell)
}

class YT_CollectionViewCell: UICollectionViewCell {
    
    enum StateEnum {
        case stopped, preparing, playing
    }
    
    var url: URL?
    var isMute = true
    var videoId: String!
    var videoDidReadyCompletion: (()->Void)?
    var playerState: StateEnum = .stopped
    var delegate: YT_ViewControllerDelegate?
    
    
    
    @IBOutlet weak var videoPlayerView: YTPlayerView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var speakerIconButton: UIButton!
    @IBOutlet weak var blackoutView: UIView!
    
    override func prepareForReuse() {
        setupLayers(isPrepared: false)
        setupSpeakerButton(isShow: false)
        isMute = true
        playerState = .stopped
    }
    
    
    private func setupLayers(isPrepared: Bool){
        if isPrepared {
            gradientView.alpha = 1
            blackoutView.alpha = 0
        } else {
            gradientView.alpha = 0
            blackoutView.alpha = 1
        }
    }
    
    private func setupSpeakerButton(isShow: Bool){
        speakerIconButton.layer.cornerRadius = speakerIconButton.bounds.size.width / 2
        
        if isShow {
            speakerIconButton.alpha = 1
            speakerIconButton.backgroundColor = #colorLiteral(red: 0.1758663952, green: 0.03264997154, blue: 0.3569124937, alpha: 1)
            let image = getSystemImage(name: "speaker.slash", pointSize: 20, color: #colorLiteral(red: 0.6882644296, green: 0.5694154501, blue: 1, alpha: 1))
            speakerIconButton.setImage(image, for: .normal)
        } else {
            speakerIconButton.alpha = 0
            speakerIconButton.setImage(.none, for: .normal)
        }
    }
    
    
    
    func setup(url: URL, videoDidReadyCompletion: (()->Void)?) {
        self.url = url
        gradientView.alpha = 0.0
        self.videoDidReadyCompletion = videoDidReadyCompletion
        setupSpeakerButton(isShow: false)
        videoPlayerView.delegate = self
        videoId = YouTubeConfigHTML.getYoutubeId(youtubeUrl: url.absoluteString)
        loadVideo()
    }
    
    func loadVideo(){
        let playvarsDic = ["controls": 0, "playsinline": 1, "autohide": 1, "showinfo": 1, "autoplay": 0, "modestbranding": 1]
        videoPlayerView.load(withVideoId: videoId, playerVars: playvarsDic)
    }
    
    func startVideo(){
        videoPlayerView.playVideo()
    }
    
    func stopVideo(){
        videoPlayerView.stopVideo()
        gradientView.alpha = 1.0
        playerState = .stopped
    }
    
    private func muteVideo(isMute: Bool) {
        let command = isMute ? "player.mute();" : "player.unMute();"
        videoPlayerView.webView?.stringByEvaluatingJavaScript(from: command)
    }
    
    
    @IBAction func mutePressButton(_ sender: Any) {
        if playerState == .stopped {
            playerState = .preparing
            delegate?.didPressStartVideo(cell: self)
        } else if playerState == .playing {
            isMute = !isMute
            muteVideo(isMute: isMute)
            setupSpeakerButton(isShow: isMute)
        }
    }
}


extension YT_CollectionViewCell: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        muteVideo(isMute: true)
        setupLayers(isPrepared: true)
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        if state == .playing {
            playerState = .playing
            videoDidReadyCompletion?()
            
            setupSpeakerButton(isShow: true)
            UIView.animate(
                withDuration: 1.0,
                animations: {
                    self.gradientView.alpha = 0.0
                    self.layoutIfNeeded()
            })
        }
        if state == .ended {
            playerState = .stopped
            videoPlayerView.seek(toSeconds: 0, allowSeekAhead: true)
        }
        if state == .paused {
            playerState = .stopped
            videoPlayerView.seek(toSeconds: 0, allowSeekAhead: true)
        }
    }
    
}

