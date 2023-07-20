//
//  CaptureButtonView.swift
//  BracketedCamera
//
//  Created by tarrask on 03/05/2023.
//

import SwiftUI

struct CaptureButtonView: View {
    @Binding var isTapped: Bool

    var body: some View {
        Circle()
            .fill(isTapped ? Color.red : Color.white)
            .frame(width: 80, height: 80)
            .overlay(
                Circle()
                    .stroke(Color.gray, lineWidth: 5)
                    .blur(radius: 10)
                    .frame(width: 80, height: 80)
            )
            .overlay(
                Circle()
                    .fill(Color.black)
                    .frame(width: 70, height: 70)
            )
            .overlay(
                Circle()
                    .fill(Color.white)
                    .frame(width: 60, height: 60)
            )

            .padding(20)
            .onTapGesture {
                isTapped.toggle()
            }
    }
}

struct CaptureButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureButtonView(isTapped: .constant(false))
    }
}
