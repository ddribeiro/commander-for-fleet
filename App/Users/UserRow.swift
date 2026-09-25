//
//  UserRow.swift
//  Commander
//
//  Created by Dale Ribeiro on 11/30/23.
//

import SwiftUI

struct UserRow: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var user: User

    var avatarSymbolName: String {
        if let first = user.name.first, first.isLetter {
            return "\(first.lowercased()).circle.fill"
        }
        return "u.circle.fill"
    }

    var body: some View {
        HStack {
            if user.gravatarUrl.isEmpty {
                Image(systemName: avatarSymbolName)
                    .font(.system(.largeTitle))
                    .symbolRenderingMode(.hierarchical)

#if os(iOS)
                    .frame(width: 40, height: 40)
#else
                    .frame(width: 20, height: 20)
#endif
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
            HStack {
                VStack(alignment: .leading) {
                    Text(user.name)
                        .font(.headline)
                        .layoutPriority(1)

                    if sizeClass == .compact {
                        Text(user.email)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                if sizeClass == .compact {
                    Spacer()
                    if user.apiOnly == true {
                        Text("API")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                            .padding(.vertical, 2)
                            .background(.tertiary, in: RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }
}
