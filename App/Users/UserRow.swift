//
//  UserRow.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/30/23.
//

import SwiftUI

struct UserRow: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var user: CachedUser

    var body: some View {
        HStack {
            if user.gravatarUrl.isEmpty {
                if let firstCharacter = user.name.first?.lowercased() {
                    Image(systemName: "\(firstCharacter).circle.fill")
                        .font(.system(.largeTitle))
                        .symbolRenderingMode(.hierarchical)

#if os(iOS)
                        .frame(width: 40, height: 40)
#else
                        .frame(width: 20, height: 20)
#endif
                }
            } else {
                AsyncImage(url: URL(string: "\(user.gravatarUrl)?s=240")) { image in
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

            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.headline)
                    .layoutPriority(1)

                if sizeClass == .compact {
                    Text(user.email)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    if let globalRole = user.globalRole {
                        Text(globalRole.capitalized)
                            .font(.smallCaps(.body)())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .background(.tertiary)
                            .clipShape(.capsule)
                    }
                }
            }
        }
    }
}
