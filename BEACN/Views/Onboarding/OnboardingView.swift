//
//  OnboardingView.swift
//  BEACN
//
//  Created by Jessica Lynn on 27/08/25.
//

import SwiftUI
import Foundation

struct OnboardingView: View {
    @StateObject var viewModel: OnboardingVM

    var body: some View {
        ZStack {
            Color(hex: "005DAD")
                .ignoresSafeArea()
            
            VStack{
                Image("beacn")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding()
                
                Text("beacn")
                    .font(.custom("LexendDeca-Regular", size: 20))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
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
                        RoundedRectangle(cornerRadius: 180)
                            .fill(Color.white)
                    }
                    VStack{
                        Text("Login")
                            .font(.title3)
                            .fontWeight(.medium)
                            .padding(.bottom, 50)
                        Text("Email")
                        Text("Password")
                        Button("Login"){
                            
                        }
                     
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

#Preview {
    OnboardingView(viewModel: OnboardingVM(coordinator: AppCoordinator()))
}
