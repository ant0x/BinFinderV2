//  Bin Finder
//
//  Created by Antonio Baldi on 23/05/2020.
//  Copyright © 2020 Antonio Baldi. All rights reserved.
//

import MaterialComponents

//* Header view for product search results list view.

//* Layout constants.
private let kHorizontalPadding: CGFloat = 16
private let kVerticalPadding: CGFloat = 8

class ProductListHeaderView: UIView {
  //* Labels that shows search results number.
  var resultLabel: UILabel?

  //* Minimum header height for the given width.
  func minHeaderHeight(forWidth width: CGFloat) -> CGFloat {
    let labelSize = resultLabel?.sizeThatFits(CGSize(width: width - 2 * kHorizontalPadding,
                                                     height: CGFloat.greatestFiniteMagnitude))
    return 2 * kVerticalPadding + (labelSize?.height ?? 0.0)
  }

  //* Maximum header height for the given width.
  func maxHeaderHeight(forWidth width: CGFloat) -> CGFloat {
    let labelSize = resultLabel?.sizeThatFits(CGSize(width: width - 2 * kHorizontalPadding,
                                                     height: CGFloat.greatestFiniteMagnitude))
    return 2 * kVerticalPadding + (labelSize?.height ?? 0.0)
  }

  // MARK: - Public
  override init(frame: CGRect) {
    super.init(frame: frame)
    resultLabel = UILabel()
    resultLabel?.font = MDCBasicFontScheme().subtitle1
    resultLabel?.backgroundColor = UIColor.systemGroupedBackground
    if let resultLabel = resultLabel {
      addSubview(resultLabel)
    }

    backgroundColor = UIColor.white
  }

  // MARK: - UIView
  override func layoutSubviews() {
    super.layoutSubviews()
    var currentHeight = frame.size.height
    let contentWidth = frame.size.width - 2 * kHorizontalPadding
    let labelSize = resultLabel?.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))
    currentHeight -= kVerticalPadding + (labelSize?.height ?? 0.0)
    resultLabel?.frame = CGRect(x: kHorizontalPadding, y: currentHeight, width: contentWidth,
                                height: labelSize?.height ?? 0.0)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
