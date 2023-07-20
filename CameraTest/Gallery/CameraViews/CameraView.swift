//
//  CameraView.swift
//  BracketedCamera
//
//  Created by tarrask on 03/05/2023.
//

import SwiftUI

struct CameraView: View {
    @State var didTapCapture: Bool = false
    @State var isLoading: Bool = false
    @Binding var isPresented: Bool
    @Binding var images: [UIImage]
    @Binding var imagesData: [Data]
    @State var folderName: String

    // This property defines the amount of bracketed images, and pass them to the Representable
    @State var bracketAmount: BracketAmount = .standard

    var body: some View {
        ZStack(alignment: .bottom) {
            // We run a black background here on simulators,
            // instead of the CustomCameraRepresentable that cannot
            // be simulated in order to build the correct layouts
#if targetEnvironment(simulator)
            Color.gray.edgesIgnoringSafeArea(.all)
#else
            CustomCameraRepresentable(didTapCapture: $didTapCapture,
                                      bracketAmount: $bracketAmount,
                                      images: $images,
                                      imagesData: $imagesData)
#endif

            VStack {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            isPresented.toggle()
                        }, label: {
                            Text("X")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(20)
                                .fontWeight(.black)
                                .edgesIgnoringSafeArea(.all)
                        })
                    }
                    HStack {
                        Image(systemName: "bolt.slash")
                            .foregroundColor(.white)

                        Spacer()

                        photoAmount()
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .background(.green.opacity(0.6))
                            .clipShape(Capsule())

                        Text("RAW")
                            .foregroundColor(.green)
                            .padding(.horizontal, 16)
                            .background(.black)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal)

                }
                .frame(maxHeight: 120)
                .background(.black.opacity(0.5))

                Spacer()

//                Crosshairs()

                Text(folderName)
                    .textCase(.uppercase)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .padding(16)
                    .background(.green.opacity(0.5))
                    .clipShape(Capsule())

                VStack {
                    CaptureButtonView(isTapped: $didTapCapture)
                        .onTapGesture {
                            isLoading.toggle()
                        }

                    Picker("Bracket Amount", selection: $bracketAmount) {
                        ForEach(BracketAmount.allCases, id: \.self) { bracketAmount in
                            Text(String(describing: bracketAmount)).tag(bracketAmount)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding([.top, .horizontal], 20)
                    .foregroundColor(.black)
                }.background(.black.opacity(0.5))

            }
//            .overlay {
//                LoadingView(show: $isLoading)
//            }
            .onAppear {
                // Forcing the rotation to portrait
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue,
                                          forKey: "orientation")
                AppDelegate.orientationLock = .portrait // And making sure it stays that way
            }.onDisappear {
                AppDelegate.orientationLock = .all // Unlocking the rotation when leaving the view
            }
        }
    }

    @ViewBuilder
    func photoAmount() -> some View {
        switch bracketAmount {
        case .pro:
            Text("5")
        case .premium:
            Text("7")
        default:
            Text("3")
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(isPresented: .constant(true),
                   images: .constant([]),
                   imagesData: .constant([]),
                   folderName: "Bedroom")
    }
}
