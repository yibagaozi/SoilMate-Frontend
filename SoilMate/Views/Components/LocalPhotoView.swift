//
//  LocalPhotoView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/11.
//

import SwiftUI

struct LocalPhotoView: View {

    let photoUrl: String?
    /// Asset image name shown when no local/remote photo is available.
    let fallbackImageName: String

    @State private var loadedImage: UIImage?

    var body: some View {
        Group {
            if let img = loadedImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else if let urlStr = photoUrl,
                      urlStr.hasPrefix("http"),
                      let url = URL(string: urlStr) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    fallback
                }
            } else {
                fallback
            }
        }
        .task(id: photoUrl) {
            // Load (or clear) the local image when photoUrl changes.
            guard let s = photoUrl, PhotoStorage.isLocal(s) else {
                loadedImage = nil
                return
            }
            loadedImage = PhotoStorage.load(s)
        }
    }

    private var fallback: some View {
        Image(fallbackImageName)
            .resizable()
            .scaledToFill()
    }
}
