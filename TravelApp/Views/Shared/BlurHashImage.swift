//
//  BlurHashImage.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 14.4.2022.
//

import SwiftUI

struct BlurHashImage: View {
    var url: URL
    var blurHash: String?
    var size: CGSize

    var body: some View {
        AsyncImage(
            url: url,
            transaction: .init(animation: .easeOut)
        ) { phase in
            switch phase {
            case .empty:
                if let blurHash = self.blurHash {
                    BlurHashView(blurHash: blurHash, size: size)
                } else {
                    VStack(alignment: .center) {
                        ProgressView()
                    }
                }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()

            case .failure:
                Image(systemName: "wifi.slash")
            @unknown default:
                Image(systemName: "wifi.slash")
            }
        }
    }
}

struct BlurHashImage_Previews: PreviewProvider {
    static var previews: some View {
        BlurHashImage(
            url: URL(string: "https://blurha.sh/assets/images/img2.jpg")!,
            blurHash: "LGFFaXYk^6#M@-5c,1J5@[or[Q6.",
            size: CGSize(width: 4, height: 3)
        )
        .frame(width: 300, height: 200)
        .previewLayout(.sizeThatFits)
    }
}
