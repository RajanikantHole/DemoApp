//
//  ConcurencySwiftUI.swift
//  DemoApp
//
//  Created by rajnikanthole on 26/08/25.
//

import SwiftUI


struct ConcurencySwiftUI: View {
    
    @StateObject var mvModel = APIViewModel()
    
    var body: some View {
        
        List(mvModel.users) { obj in
            Text("name \(obj.username ?? "")")
        }
        VStack {
            Text("sfavc")
            Text("sfavc")
        }
        .onAppear {
            mvModel.getAPIData()
        }
    }
}
