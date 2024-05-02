//
//  FollowButtonView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 4/29/24.
//

import SwiftUI

struct FollowButton: View {
    @EnvironmentObject var favoritesManager : FavoritesManager
    
    let p : Player?
    let t : Team?
    
    var isFav : Bool {
        if p != nil {
            return favoritesManager.contains(p!)
        } else {
            return favoritesManager.contains(t!)
        }
    }
    
    var pc : UIColor {
        if p != nil {
            return p!.team.priColor
        } else {
            return t!.priColor
        }
    }
    
    var body: some View {
        Button(isFav ? "Following" : "Follow") {
            withAnimation {
                if isFav {
                    if p != nil {
                        favoritesManager.remove(p!)
                    } else {
                        favoritesManager.remove(t!)
                    }
                } else {
                    if p != nil {
                        favoritesManager.add(p!)
                    } else {
                        favoritesManager.add(t!)
                    }
                }
            }
        }
        .font(.system(size: 14))
        .fontWeight(.semibold)
        .foregroundStyle(.white)
        .buttonStyle(.borderedProminent)
        .tint(isFav ? Color(pc) : .secondary)
    }
}

#Preview {
    FollowButton(p: Player.demoPlayer, t: nil).environmentObject(FavoritesManager())
}
