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

    var body: some View {
        Button(action: {}) {
            ZStack {
                GeometryReader { proxy in
                    Image("download")
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width)

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
            }
            .clipped()
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(8)
        }
    }
}

struct TripItem_Previews: PreviewProvider {
    static var previews: some View {
        TripItem(city: "Paris", country: "France")
            .padding()
            .frame(width: 200, height: 200)
            .previewLayout(.sizeThatFits)
    }
}
