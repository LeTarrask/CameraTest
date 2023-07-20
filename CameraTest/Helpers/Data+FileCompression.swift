//
//  Data+FileCompression.swift
//  BracketedCamera
//
//  Created by tarrask on 10/05/2023.
//

import Foundation
import SwiftUI

extension Data {
    func compress(withQuality quality: CGFloat) -> Data {
        return UIImage(data: self)?.jpegData(compressionQuality: quality) ?? self
    }
}
