//
//  TripItem.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 28.3.2022.
//

import SwiftUI

struct TripItem: View {
    let city: String
    let country: String
    let image: String?
    let blurHash: String?

    var body: some View {
        GeometryReader { proxy in
            if image != nil && blurHash != nil {
                BlurHashImage(url: URL(string: image!)!, blurHash: blurHash!, size: CGSize(width: 4, height: 3))
                    .scaledToFill()
                    .frame(width: proxy.size.width)
            } else {
                Image("download")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width)
            }

            VStack {
                Spacer()
                VStack {
                    Spacer()
                        .frame(height: 20)
                    HStack {
                        VStack(alignment: .leading) {
                            Text(city)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            Spacer()
                                .frame(height: 4)
                            Text(country)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                    }

                }.padding()
                    .background {
                        LinearGradient(colors: [Color.black.opacity(0.6), Color.clear], startPoint: .bottom, endPoint: .top)
                    }
            }
        }
        .clipped()
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(8)
    }
}

struct TripItem_Previews: PreviewProvider {
    static var previews: some View {
        TripItem(city: "Paris", country: "France", image: nil, blurHash: nil)
            .padding()
            .frame(width: 200, height: 200)
            .previewLayout(.sizeThatFits)
    }
}
