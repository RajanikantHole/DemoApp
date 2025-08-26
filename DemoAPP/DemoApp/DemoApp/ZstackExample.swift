//
//  ZstackExample.swift
//  DemoApp
//
//  Created by rajnikanthole on 24/08/25.
//

import SwiftUI

struct ZstackExample: View {
    @State private var index = 2
    let colors: [Color] = [.red, .green, .blue]

    var body: some View {
        VStack {
            ZStack {
                
//                ForEach(colors.indices, id: \.self) { i in
//                    colors[i]
//                        .frame(width: 150, height: 150)
//                        .cornerRadius(20)
//                       // .opacity(index == i ? 1 : 0)   // show only current index
//                        .zIndex(index == i ? 1 : 0)  // bring it to front
//                }
                
                colors[0]
                    .frame(width: 150, height: 150)
                    .cornerRadius(20)
                   // .opacity(index == i ? 1 : 0)   // show only current index
                    .zIndex(1)  // bring it to front
                
                
                colors[1]
                    .frame(width: 150, height: 150)
                    .cornerRadius(20)
                   // .opacity(index == i ? 1 : 0)   // show only current index
                    .zIndex(0)  // bring it to front
            }

            Button("Next") {
                index = (index + 1) % colors.count
            }
            .padding()
        }
    }
}
