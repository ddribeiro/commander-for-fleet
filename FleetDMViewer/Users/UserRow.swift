//
//  UserRow.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/30/23.
//

import SwiftUI

struct UserRow: View {
    var user: CachedUser

    var body: some View {
        HStack {
            if user.wrappedGravatarUrl.isEmpty {
                if let firstCharacter = user.wrappedName.first?.lowercased() {
                    Image(systemName: "\(firstCharacter).circle.fill")
                        .font(.system(.largeTitle))
#if os(iOS)
                        .frame(width: 40, height: 40)
#else
                        .frame(width: 20, height: 20)
#endif

                }
            } else {
                AsyncImage(url: URL(string: "\(user.wrappedGravatarUrl)?s=240")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(.white, lineWidth: 2)
                        }
                        .shadow(radius: 7)

                } placeholder: {
                    ProgressView()
                }
#if os(iOS)
                .frame(width: 40, height: 40)
#else
                .frame(width: 20, height: 20)
#endif

            }
            Text(user.wrappedName)
        }
    }
}
