//
//  BlurView.swift
//  EpitApp
//
//  Created by Quenting on 20/02/2025.
//


import SwiftUI
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemUltraThinMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
