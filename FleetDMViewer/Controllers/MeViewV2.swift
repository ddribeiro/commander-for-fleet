//
//  MeViewV2.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/22/23.
//

import SwiftUI

struct MeViewV2: View {
    var user: User
    var body: some View {
        VStack {
            if !user.gravatarUrl.isEmpty {
                AsyncImage(url: URL(string: "\(user.gravatarUrl)?s=2048")) { image in
                    image
                        .resizable()
                        .blur(radius: 50)
                        .frame(width: .infinity)
                } placeholder: {
                    ProgressView()
                }
            }

            if !user.gravatarUrl.isEmpty {
                AsyncImage(url: URL(string: "\(user.gravatarUrl)?s=2048")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .background(.white)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(.white, lineWidth: 3)
                        }

                        .shadow(radius: 7)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 250, height: 250)
                .offset(y: -130)
                .padding(.bottom, -130)

                VStack(alignment: .leading) {
                    Text(user.name)
                        .font(.system(.title, design: .rounded))

                    HStack {
                        Text(user.email)
                        Spacer()

                        Text(user.globalRole.capitalized)

                    }
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)

                    Text("Created on: \(user.createdAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)

                    Spacer()

                    HStack {
                        Spacer()
                        Button("Log Out", role: .destructive) { }
                            .frame(maxWidth: .infinity)
                            .buttonStyle(.borderedProminent)
                        Spacer()
                    }

                }
                .padding()
                Spacer()

            }
        }
    }
}

struct MeViewV2_Previews: PreviewProvider {
    static var previews: some View {
        MeViewV2(user: .example)
    }
}
