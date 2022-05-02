//
//  StepDivider.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 30.4.2022.
//

import SwiftUI

enum Estimate {
    case loading
    case loaded(TimeInterval)
    case none
}

struct StepDivider: View {
    var walkEstimate: Estimate
    var busEstimate: Estimate

    private let formatter: DateComponentsFormatter

    init(walkEstimate: Estimate, busEstimate: Estimate) {
        self.walkEstimate = walkEstimate
        self.busEstimate = busEstimate

        formatter = DateComponentsFormatter()
        formatter.unitsStyle = .brief // Shows short time unit
        formatter.allowedUnits = [.hour, .minute]
    }

    var walkEstimateView: some View {
        var text: String?

        switch walkEstimate {
        case .loading:
            text = "---"
        case .loaded(let duration):
            text = formatter.string(from: duration)
        case .none:
            text = nil
        }

        if let text = text {
            return AnyView(Tag(color: .green) {
                Label(text, systemImage: "figure.walk")

            })
        } else {
            return AnyView(EmptyView())
        }
    }

    var busEstimateView: some View {
        var text: String?

        switch busEstimate {
        case .loading:
            text = "---"
        case .loaded(let duration):
            text = formatter.string(from: duration)
        case .none:
            text = nil
        }

        if let text = text {
            return AnyView(Tag(color: .cyan) {
                Label(text, systemImage: "bus.fill")
            })
        } else {
            return AnyView(EmptyView())
        }
    }

    var body: some View {
        HStack {
            Line()
                .stroke(.secondary, style: StrokeStyle(lineWidth: 2, dash: [5]))
                .frame(width: 1, height: 52)
                .padding(.horizontal, 18)

            walkEstimateView
            busEstimateView
        }
    }
}

struct StepDivider_Previews: PreviewProvider {
    static var previews: some View {
        StepDivider(walkEstimate: .loaded(25 * 60), busEstimate: .loaded(10 * 60))
            .previewLayout(.sizeThatFits)
    }
}
