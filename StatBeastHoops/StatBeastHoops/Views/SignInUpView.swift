//
//  SignInUpView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/29/24.
//

import SwiftUI

struct SignInUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        ZStack {
            Image(uiImage: UIImage(named: "logo")!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: 400)
            
            Color.clear.background(.ultraThinMaterial)
            
            VStack {
                Image(uiImage: UIImage(named: "logo")!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200)
//                    .opacity(0.5)
                    .shadow(radius: 10)
                
                Text("StatBeast | Hoops")
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .shadow(radius: 10)
                
                Text("Sign in or Sign up to get started")
                    .font(.footnote)
                    .fontWeight(.light)
                    .shadow(radius: 10)
                
                Divider()
                
                Spacer()
                
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                
                Spacer()
            }
            .padding(.horizontal)
        }
        
    }
}

#Preview {
    SignInUpView()
}
