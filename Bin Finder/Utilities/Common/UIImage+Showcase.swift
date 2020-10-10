//  Bin Finder
//
//  Created by Antonio Baldi on 23/05/2020.
//  Copyright © 2020 Antonio Baldi. All rights reserved.
//

import UIKit

/**
 * An extension of `UIImage` that provides custom image data management.
 */

private let kJPEGCompressionQuality: CGFloat = 0.7

extension UIImage {
  /**
   * Returns a base 64 encoded string for `UIImage`.
   *
   * @return Returns the base 64 encoded string for `UIImage` or `nil` if its JPEG representation is
   *     `nil`.
   */
  func fir_base64EncodedString() -> String? {
    let jpegEncoding = self.jpegData(compressionQuality: kJPEGCompressionQuality)
    return jpegEncoding?.base64EncodedString(options: .lineLength64Characters)
  }
}

func base64EncodedString() {
}
