//
//  VideoListModel.swift
//  TikTok Feeds
//
//  Created by Ashish on 30/04/24.
//

import Foundation
import AVKit

struct VideoPosts: Hashable, Equatable {
    let id = UUID()
    let url: URL
    var playerItem: AVPlayerItem?
    var isLoading: Bool = false
}

@MainActor
final class VideoListState: NSObject, ObservableObject {
    
    @Published var items: [VideoPosts] = []
    var player1: AVPlayer = AVPlayer()
    var player2: AVPlayer = AVPlayer()
    
    override init() {
        items = [
            VideoPosts(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!),
            VideoPosts(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!),
            VideoPosts(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!),
            VideoPosts(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4")!),
            VideoPosts(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!),
            VideoPosts(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4")!)
        ]
    }
    
    func loadInitialAssets() {
        loadItems(at: 0)
        loadItems(at: 1)
    }
    
    func loadItems(at index: Int) {
        guard index < items.count else { return }
        guard items[index].playerItem == nil, !items[index].isLoading else { return }
        items[index].isLoading = true
        print("LOAD - \(index)")
        Task {
            await loadAssets(at: index)
        }
    }
    
    func loadAssets(at index: Int) async {
        let asset = AVURLAsset(url: items[index].url)
        do  {
            let _ = try await asset.load(.tracks, .isPlayable)
            let status = asset.status(of: .isPlayable)
            if case .loaded(_) = status {
                DispatchQueue.main.async {
                    self.items[index].isLoading = false
                    self.items[index].playerItem = AVPlayerItem(asset: asset)
                }
            } else if case .failed(let error) = status {
                items[index].isLoading = false
                print("ERROR: \(error.localizedDescription)")
            }
        }catch let error {
            items[index].isLoading = false
            print("ERROR: \(error.localizedDescription)")
        }
    }
    
    func getPlayer(at index: Int) -> AVPlayer{
        if (index % 2 == 0) {
            return player1
        } else {
            return player2
        }
    }
}
