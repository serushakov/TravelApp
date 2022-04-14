//
//  BlurHashImage.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 14.4.2022.
//

import SwiftUI
import UIKit

struct BlurHashView: UIViewRepresentable {
    typealias UIViewType = UIImageView

    var blurHash: String
    var size: CGSize

    func makeUIView(context: Context) -> UIImageView {
        guard let uiImage = UIImage(blurHash: blurHash, size: size) else { return UIImageView() }

        let uiImageView = UIImageView(image: uiImage)
        return uiImageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {}
}

struct BlurHashView_Previews: PreviewProvider {
    static var previews: some View {
        BlurHashView(
            blurHash: "LGFFaXYk^6#M@-5c,1J5@[or[Q6.", size: CGSize(width: 4, height: 3)
        )
        .frame(width: 300, height: 200)
        .previewLayout(.sizeThatFits)
    }
}
