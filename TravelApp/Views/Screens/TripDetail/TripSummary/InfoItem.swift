//
//  InfoItem.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 23.4.2022.
//

import SwiftUI

enum Weather {
    case sun
    case cloudy
    case rain
    case cloudSun
    case snow
}

enum Type {
    case arrival(_ date: Date)
    case departure(_ date: Date)
    case weather(_ weather: Weather, text: String)
}

struct InfoItem: View {
    @Environment(\.colorScheme) private var colorScheme

    let type: Type

    private func getText() -> String {
        switch type {
        case .arrival(_: let date), .departure(_: let date):
            return date.formatted(Date.FormatStyle().month().day(.defaultDigits))

        case .weather(_: _, text: let text):
            return text
        }
    }

    private func getIcon() -> some View {
        switch type {
        case .arrival:
            return AnyView(
                Image(systemName: "airplane.arrival")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.cyan, colorScheme == .light ? .black : .white)
            )
        case .departure:
            return AnyView(
                Image(systemName: "airplane.departure")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.cyan, colorScheme == .light ? .black : .white)
            )
        case .weather(_: let type, text: _):
            switch type {
            case .cloudSun:
                return AnyView(Image(systemName: "cloud.sun.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.cyan, .yellow))
            case .cloudy:
                return AnyView(Image(systemName: "cloud.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.cyan, .white))
            case .sun:
                return AnyView(Image(systemName: "sun.max.fill")
                    .symbolRenderingMode(.multicolor))
            case .rain:
                return AnyView(Image(systemName: "cloud.rain.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.cyan, .white))
            case .snow:
                return AnyView(Image(systemName: "cloud.snow.fill")
                    .foregroundStyle(.cyan, .white)
                    .symbolRenderingMode(.palette))
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            getIcon()
                .font(.system(size: 30))
            Spacer()
            Text(getText())
                .font(.title3.bold())
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background { ElevatedBackground() }
        .cornerRadius(8)
        .shadow(color: .gray.opacity(0.24), radius: 4)
    }
}

struct InfoItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            InfoItem(type: .arrival(Date.now))
                .frame(width: 120)
                .padding()
            InfoItem(type: .departure(Date.now))
                .frame(width: 120)
                .padding()
            InfoItem(type: .weather(.sun, text: "10-15℃"))
                .frame(width: 120)
                .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
