import Foundation

//Documentation:
//https://developers.google.com/youtube/player_parameters.html?playerVersion=HTML5


struct YouTubeConfigHTML {
    
    static func getYoutubeId(youtubeUrl: String) -> String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: youtubeUrl.count)
        
        guard let result = regex?.firstMatch(in: youtubeUrl, range: range) else {
            return nil
        }
        
        return (youtubeUrl as NSString).substring(with: result.range)
    }
    
    static func getConfig(sURL: String) -> String {
        
        let str = getYoutubeId(youtubeUrl: sURL) ?? ""
        let videoId = str.replacingOccurrences(of: "?__ref=vk.api", with: "")

        return """
        <!DOCTYPE html>
        <<html>
        <body>
        <!-- 1. The <iframe> (and video player) will replace this <div> tag. -->
        <div style='height:100%;background-color:black;display:flex;align-items:center;justify-content:center;'>
        <div id="player"></div>
        
        <script>
        
        
        var didStopVideoEvent = document.createEvent('Event');
        
        didStopVideoEvent.initEvent('stopVideoEvent', true, true);
        
        var tag = document.createElement('script');
        tag.src = "http://www.youtube.com/player_api";
        var firstScriptTag = document.getElementsByTagName('script')[0];
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
        
        
        var player;
        
        function onYouTubePlayerAPIReady() {
        player = new YT.Player('player', {
        playerVars: { 'autoplay': 1,
        'controls': 0,
        'playsinline': 1,
        'frameborder' : 0,
        'modestbranding': 1,
        'showinfo' : 0,
        'enablejsapi': 1},
        height: '405',
        width: '720',
        videoId: '\(videoId)',
        events: {
        'onReady': onPlayerReady,
        'onStateChange': onPlayerStateChange
        }
        });
        }
        
        function onPlayerReady(event) {
        event.target.mute();
        event.target.playVideo();
        }
        
        var done = false;
        function onPlayerStateChange(event) {
        
        if (event.data == YT.PlayerState.PLAYING && !done) {
        //setTimeout(stopVideo, 6000);
        
        done = true;
        }
        
        if (event.data == YT.PlayerState.ENDED) {
        document.dispatchEvent(didStopVideoEvent);
        window.location = "callback:anything"; //here's the key
        };
        }
        
        function stopVideo() {
        document.dispatchEvent(didStopVideoEvent);
        player.stopVideo();
        }
        
        function unmuteVideo() {
        player.setPlaybackQuality("small")
        player.unMute()
        }
        
        function muteVideo() {
        player.mute()
        }
        
        </script>
        </body>
        </html>
        """
    }
}
