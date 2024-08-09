//
//  VideoListView.swift
//  TikTok Feeds
//
//  Created by Ashish on 30/04/24.
//

import SwiftUI
import AVKit

struct VideoListView: View {
    
    @StateObject var state: VideoListState = VideoListState()
    @State private var currentAppearIndex = 0
    var body: some View {
        GeometryReader(content: { geometry in
            let frame = geometry.frame(in: .local)
            
            ScrollView(.vertical, showsIndicators: false) {
                ScrollViewReader { proxy in
                    gridView(frame: frame)
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .scrollTargetBehavior(.paging)
            .onAppear {
                state.loadInitialAssets()
            }
        })
        .ignoresSafeArea()
    }
    
    private func gridView(frame: CGRect) -> some View {
        LazyVGrid(columns: [GridItem(.fixed(frame.height))], alignment: .leading, spacing: .zero) {
            ForEach(Array(state.items.enumerated()), id: \.1.id) { index, item in
                LazyVStack(alignment: .leading) {
                    if let playerItem = item.playerItem {
                        PlayerView(player: state.getPlayer(at: index))
                            .frame(width: frame.width, height: frame.height)
                            .scaledToFill()
                            .onAppear {
                                state.getPlayer(at: index)
                                    .replaceCurrentItem(with: playerItem)
                                state.getPlayer(at: index).play()
                                state.loadItems(at: index + 1)
                            }
                            .onDisappear {
                                state.getPlayer(at: index).pause()
                                state.getPlayer(at: index).seek(to: .zero)
                                state.getPlayer(at: index)
                                    .replaceCurrentItem(with: nil)
                            }
                    } else {
                        VStack {
                            ProgressView()
                                .foregroundStyle(.white)
                        }
                        .frame(width: frame.width, height: frame.height)
                        .onAppear {
                            state.getPlayer(at: index).pause()
                            state.loadItems(at: index + 1)
                        }
                    }
                }
            }
        }
    }
}

extension AVPlayerViewController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.showsPlaybackControls = false
    }
}

#Preview {
    VideoListView()
}
