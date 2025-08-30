//
//  OnboardingView.swift
//  BEACN
//
//  Created by Jessica Lynn on 27/08/25.
//

import SwiftUI
import Foundation

struct OnboardingView: View {
    @EnvironmentObject private var vm: AuthViewModel

    var body: some View {
        ZStack {
            Color(hex: "005DAD")
                .ignoresSafeArea()
            
            VStack{
                Image("logo_beacn")
                    .resizable()
                    .frame(width: 140, height: 140)
                    .padding(.top, 15)
                
                Text("beacn")
                    .font(.custom("LexendDeca-Regular", size: 20))
                    .foregroundColor(.white)
                    .padding(.bottom, 55)
                ZStack{
                    HStack{
                        Rectangle()
                            .foregroundStyle(Color(hex: "005DAD"))
                        Rectangle()
                            .foregroundStyle(Color.white)
                    }
                    ZStack {
                        Rectangle()
                            .fill(Color.white)
                            .padding(.top, 250)
                        RoundedRectangle(cornerRadius: 150)
                            .fill(Color.white)
                    }
                    VStack(spacing: 15){
                        Text("Login")
                            .font(.title2)
                            .fontWeight(.medium)
                            .padding(.bottom, 30)
                        VStack(alignment: .leading){
                            Text("Email")
                                .font(.footnote)
                                .fontWeight(.medium)
                            TextField("Your email", text: $vm.email)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .onSubmit {
                                    
                                }
                                .padding(.all, 8)
                                .padding(.horizontal, 15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(style: StrokeStyle(lineWidth: 1))
                                        .foregroundStyle(.gray)
                                )
                        }
                        .padding(.horizontal, 35)
                        VStack(alignment: .leading) {
                            Text("Password")
                                .font(.footnote)
                                .fontWeight(.medium)
                            SecureField("", text: $vm.password)
                                .padding(.all, 8)
                                .padding(.horizontal, 15)
                                .overlay(RoundedRectangle(cornerRadius: 15).stroke(style: StrokeStyle(lineWidth: 1))
                                    .foregroundStyle(.gray))
                        }
                        .padding(.horizontal, 35)
                        
                        if let errorMessage = vm.errorMessage {
                            Text("We couldn’t sign you in. Please ensure your username and password are correct.")
                                .font(.caption)
                                .padding(.horizontal, 40)
                                .foregroundColor(Color(hex: "005DAD"))
                        }
                        
                        VStack {
                            Button("Login") {
                                print("tapped")
                                Task { await vm.signIn() }
                            }
                            .padding(.vertical, 13)
                            .padding(.horizontal, 145)
                            .background(Color(hex: "005DAD"))
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                            .shadow(radius: 5)
                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                            Spacer()
                            Text("Don't have an account? Sign up")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        .frame(height: 200)
                     
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
