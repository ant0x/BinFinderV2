//  Bin Finder
//
//  Created by Antonio Baldi on 23/05/2020.
//  Copyright © 2020 Antonio Baldi. All rights reserved.
//

import Foundation

//* Object detection statuses.
enum ODTStatus: Int {
  //* Object detection hasn't started yet.
  case notStarted
  //* Object detection started detecting on new objects.
  case detecting
  //* Object detection is confirming on the same object.
  case confirming
  //* Object detection is searching the detected object.
  case searching
  //* Object detection has got search results on detected object.
  case searched
}
