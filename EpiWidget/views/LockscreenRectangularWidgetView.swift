//
//  LockscreenRectangularWidgetView.swift
//  EpitApp
//
//  Created by Quenting on 26/09/2025.
//

import WidgetKit
import SwiftUI

struct LockscreenRectangularWidgetView: View {
    var entry: ViewSizeTimelineProvider.Entry
    
    var compactMode: Bool = false
    // TODO: If not up to date show "!" or smth if not latest data available
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
                .cornerRadius(5)
            GeometryReader { geometry in
//                    Text("\(Int(geometry.size.width)) x \(Int(geometry.size.height)). Date: \(entry.date.description)")
//                        .font(.headline)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    Text("\(entry.date.description) - \(entry.providerInfo)")
                if (compactMode) {
                    LockscreenRectangularWidgetCompactView(geometry: geometry)
                } else {
                    LockscreenRectangularWidgetNormalView(geometry: geometry)
                }
            }
        }
    }
}


struct LockscreenRectangularWidgetCompactView: View {
    var geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 1) {
            HStack(spacing: 2) {
                RoundedRectangle(cornerSize: CGSize(width: 2, height: 2))
                    .frame(width: 4, height: geometry.size.height/2-3)
                    .padding(.leading, 2)
                VStack {
                    Text("12h")
                        .font(.caption)
                    Text("15h")
                        .font(.caption)
                }
                Spacer()
                
                Text("Mathematique")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                Spacer()
                Text("205")
                    .font(.caption)
                    .padding(.trailing, 2)
            }
            
            Rectangle()
                .frame(width: geometry.size.width, height: 1)

            
            HStack(spacing: 2) {
                RoundedRectangle(cornerSize: CGSize(width: 2, height: 2))
                    .frame(width: 4, height: geometry.size.height/2-3)
                    .padding(.leading, 2)
                VStack {
                    Text("16h")
                        .font(.caption)
                    Text("17h")
                        .font(.caption)
                }
                Spacer()
                Text("THLR-TP")
                    .font(.caption)
                Spacer()
                Text("306")
                    .font(.caption)
                    .padding(.trailing, 2)
            }
        }
        .padding(.top, 1)
    }
}

struct LockscreenRectangularWidgetNormalView: View {
    var geometry: GeometryProxy
    
    var body: some View {
        HStack(spacing: 2) {
            VStack {
                Text("16h")
                    .font(.caption)
                    .padding(.top, 2)
                Spacer()
                Text("17h")
                    .font(.caption)
                    .padding(.bottom, 2)
            }
            .padding(.leading, 2)
            RoundedRectangle(cornerSize: CGSize(width: 2, height: 2))
                .frame(width: 4, height: geometry.size.height - 4)
                .padding(.trailing, 2)
            
            VStack(spacing: 0) {
                Text("Mathématique fdsfdsfsd dsfs")
                    .frame(height: 40, alignment: .top)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    
                
                Spacer(minLength: 0)
                HStack(spacing: 4) {
                    Text("DURAND")
                    
                    RoundedRectangle(cornerSize: CGSize(width: 2, height: 2))
                        .frame(width: 2, height: 12)
                    Text("306")
                        .padding(.trailing, 2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            }
            .frame(height: geometry.size.height, alignment: .center)
        }
    }
}
