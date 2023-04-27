//
//  CircularProgressView.swift
//  HabitTracker
//
//  Created by Håkan Johansson on 2023-04-27.
//

import SwiftUI
import Foundation

struct CircularProgressView: View {
    let progress: Double
        
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.black.opacity(0.5),
                    lineWidth: 10
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.black,
                    lineWidth: 10
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
        }
    }
}
