//
//  PlayerView.swift
//  TikTok Feeds
//
//  Created by Ashish on 30/04/24.
//

import SwiftUI
import AVKit

struct PlayerView: View {
    var player: AVPlayer?
    
    var body: some View {
        if let player = player {
            VideoPlayer(player: player)
                .scaledToFill()
                .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)) { _ in
                    // When the video reaches the end, seek the player to the beginning to replay
                    player.seek(to: .zero)
                    player.play()
                }
                
        } else {
            // Placeholder or loading indicator while the video is loading
            ProgressView()
        }
    }
}
