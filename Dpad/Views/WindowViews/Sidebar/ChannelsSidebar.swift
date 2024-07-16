//
//  ChannelsSidebar.swift
//  Dpad
//
//  Created by Paul Kim on 10/14/22.
//

import SwiftUI

struct ChannelsSidebar: View {
    
    @State var searchText: String = ""
    @FocusState private var focusedField: String?
    
    var body: some View {
        ChannelList()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .allowsHitTesting(true)
//            .onTapGesture {
//                focusedField = nil
//            }
//            .onAppear {
//                focusedField = nil
//            }
    }
    
}

//struct FollowersList_Previews: PreviewProvider {
//    static var previews: some View {
//        ChannelsSidebar()
//            .frame(width: 200)
//            .environmentObject(AppState.mockState())
//    }
//}

