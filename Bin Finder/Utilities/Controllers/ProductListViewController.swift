//  Bin Finder
//
//  Created by Antonio Baldi on 23/05/2020.
//  Copyright © 2020 Antonio Baldi. All rights reserved.
//

import MaterialComponents
import Vision

private let kProductCellReuseIdentifier = "ProductCell"

//* View controller showing a list of products.
class ProductListViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  /**
   * Header of the list, it stays on top of the screen when it expands to the whole screen and
   * contents will be scrolled underneath it.
   */
  var headerViewController = MDCFlexibleHeaderViewController()
  //* Header view for this panel view.
  var headerView = ProductListHeaderView()

  //* Cell that is used to calculate the height of each row.
  private var measureCell = ProductResultCell()
  //* Data model for this view. Content of the view is generated from its value.
  private var detection = [VNRecognizedObjectObservation]()

  /**
   * Initializes and returns a `ProductListViewController` object using the provided product list.
   *
   * @param products List of the products that serves as the model to this view.
   * @return An instance of the `ProductListViewController`.
   */
  init(detection: [VNRecognizedObjectObservation]) {
    let layout = UICollectionViewFlowLayout()
    super.init(collectionViewLayout: layout)
    self.detection = detection
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //* Calculates and updates minmum and maximum height for header view.
  func updateMinMaxHeightForHeaderView() {
    let flexibleHeaderView = headerViewController.headerView
    flexibleHeaderView.maximumHeight = headerView.maxHeaderHeight(forWidth: view.bounds.size.width)
    flexibleHeaderView.minimumHeight = headerView.minHeaderHeight(forWidth: view.bounds.size.width)
  }

  // MARK: - Public

  // MARK: - UIViewController
  
    
  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView.backgroundColor = UIColor.white

    // Register cell classes
    collectionView.register(ProductResultCell.self, forCellWithReuseIdentifier: kProductCellReuseIdentifier)

    addFlexibleHeader()
    
    
  }

  // MARK: - UICollectionViewDataSource
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
  
    return 1;
  }

  override func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellReuseIdentifier,
                                                  for: indexPath) as? ProductResultCell
    if(detection.count > 0)
    {
    _ = cell?.isCellPopulated(with: detection[indexPath.row])
        
    }
    else
    {
        cell?.nameLabel.text = "Error, object is not detected"
        cell?.nameLabel.textColor = .red
        cell?.roadButton.isHidden = true
    }
    cell?.setNeedsLayout()
    return cell!
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    if(detection.count > 0)
    {
    _ = measureCell.isCellPopulated(with: detection[indexPath.row])
    }
    else
    {
        measureCell.nameLabel.text = "Error, object is not detected"
    }
    let contentWidth = view.frame.size.width - self.collectionView.contentInset.left
      - self.collectionView.contentInset.right
    return CGSize(width: contentWidth,
                  height: measureCell.sizeThatFits(CGSize(width: contentWidth,
                                                           height: CGFloat.greatestFiniteMagnitude)).height)
  }

  // MARK: - UIScrollViewDelegate
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView == headerViewController.headerView.trackingScrollView {
      headerViewController.headerView.trackingScrollDidScroll()
    }
  }

  override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if scrollView == headerViewController.headerView.trackingScrollView {
      headerViewController.headerView.trackingScrollDidEndDecelerating()
    }
  }

  override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if scrollView == headerViewController.headerView.trackingScrollView {
      headerViewController.headerView.trackingScrollDidEndDraggingWillDecelerate(decelerate)
    }
  }

  override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    if scrollView == headerViewController.headerView.trackingScrollView {
      headerViewController.headerView.trackingScrollWillEndDragging(withVelocity: velocity,
                                                                    targetContentOffset: targetContentOffset)
    }
  }

  // MARK: - Private
  func addFlexibleHeader() {
    let headerText = String(format: "", detection.count)
    headerView.resultLabel?.text = headerText
    updateMinMaxHeightForHeaderView()

    headerViewController.willMove(toParent: self)
    addChild(headerViewController)

    headerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    let flexibleHeaderView = headerViewController.headerView
    flexibleHeaderView.canOverExtend = false
    flexibleHeaderView.trackingScrollView = collectionView

    flexibleHeaderView.addSubview(headerView)

    view.addSubview(flexibleHeaderView)


    headerView.frame = flexibleHeaderView.bounds
    flexibleHeaderView.frame = view.bounds

    headerViewController.didMove(toParent: self)
  }
}
