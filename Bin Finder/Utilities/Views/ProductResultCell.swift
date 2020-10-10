//  Bin Finder
//
//  Created by Antonio Baldi on 23/05/2020.
//  Copyright © 2020 Antonio Baldi. All rights reserved.
//

import MaterialComponents
import PINRemoteImage
import Vision

//* Layout values.
private let kHorizontalPadding: CGFloat = 16.0
private let kVerticalPadding: CGFloat = 16.0
private let kVerticalPaddingSmall: CGFloat = 1.0
private let kThumbnailSize: CGFloat = 0.0
public var annotazione = ""

//* Cell that shows `object` details from a search result.
class ProductResultCell: MDCBaseCell {
    //* Thumbnail of the object.
//    private(set) var thumbnailImage = UIImageView()
    //* Label showing the name of the object.
    private(set) var nameLabel = UILabel()
    private(set) var roadButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                            size: CGSize(width: 64, height: 64)))
    //* Label showing the category of the object.
//    private(set) var itemNumberLabel = UILabel()
    
    /**
     * Populates the content of the cell with a `object` model.
     *
     * @param object The object info to populate the cell with.
     * @return YES if object is not nil, otherwise, NO.
     */
    func isCellPopulated(with object: VNRecognizedObjectObservation?) -> Bool {
        guard let object = object else { return false }
        /*
         if let imageURL = object.imageURL, !imageURL.isEmpty {
         thumbnailImage.pin_setImage(from: URL(string: imageURL))
         }
         */
        var frase = ""
//        var oggetto = object.labels[0]
        if(object.labels.count>0)
        {
        for oggetto in object.labels
        {
//        nameLabel.text = object.labels.map({"\($0.identifier) confidence: \(($0.confidence*100).rounded())%"}).joined(separator: "\n")
//        nameLabel.text = object.labels.map({"\($0.identifier)"}).joined(separator: "\n")
            if((oggetto.confidence*100)>40)
            {
                frase.append( "\(oggetto.identifier) confidence: \(String(format: "%.2f", oggetto.confidence*100))% \n")
            }
        }
            nameLabel.text=frase
        print("frase", frase)
            annotazione = object.labels[0].identifier
        }
        else
        {
            nameLabel.text = "No detection"
        }
        
        return true
        
    }
    
    // MARK: - Public
    override init(frame: CGRect) {
        super.init(frame: frame)
//        addSubview(thumbnailImage)
        
        nameLabel.numberOfLines = 0
        nameLabel.font = MDCBasicFontScheme().body2
        nameLabel.textColor = MDCPalette.grey.tint900
        addSubview(nameLabel)
        
        roadButton.center = CGPoint(x: self.bounds.size.width,
                                  y: self.bounds.size.height)
        
        roadButton.setBackgroundImage(UIImage(named: "GoTrash"), for: UIControl.State())

                roadButton.addTarget(self, action: #selector(dismissFPath), for: UIControl.Event.touchUpInside)
                roadButton.tag = 1
                roadButton.isUserInteractionEnabled = true
            
            addSubview(roadButton)
//        itemNumberLabel.numberOfLines = 0
//        itemNumberLabel.font = MDCBasicFontScheme().body1
//        itemNumberLabel.textColor = MDCPalette.grey.tint700
//        addSubview(itemNumberLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UICollectionReusableView
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
//        itemNumberLabel.text = nil
    }
    
    // MARK: - UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        let _ = layoutSubviews(forWidth: frame.size.width, shouldSetFrame: true)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let width = frame.size.width
        let height = layoutSubviews(forWidth: width, shouldSetFrame: false)
        return CGSize(width: width, height: height)
    }
    
    // MARK: - Private
    
    /**
     * Calculates the height that best fits the specified width for subviews.
     *
     * @param width The available width for the view.
     * @param shouldSetFrame Whether to set frames for subviews.
     *    If it is set to NO, this function will simply measure the space without affecting subviews,
     *    otherwise, subviews will be laid out accordingly.
     * @return The best height of the view that fits the width.
     */
    func layoutSubviews(forWidth width: CGFloat, shouldSetFrame: Bool) -> CGFloat {
        var contentWidth = width - 10 * kHorizontalPadding
        
        var currentHeight = kVerticalPadding
        var startX = kHorizontalPadding
//
//        if shouldSetFrame {
//            thumbnailImage.frame = CGRect(x: startX, y: currentHeight, width: kThumbnailSize, height: kThumbnailSize)
//        }
        
        startX += kThumbnailSize + kHorizontalPadding
        
        contentWidth -= kThumbnailSize + kHorizontalPadding
        
        let nameLabelSize = nameLabel.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))
        if shouldSetFrame {
            nameLabel.frame = CGRect(x: startX, y: currentHeight, width: contentWidth, height: nameLabelSize.height)
        }
        currentHeight += nameLabelSize.height
        
        let buttonSize = roadButton.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))
        if shouldSetFrame {
          roadButton.frame = CGRect(x: width - kHorizontalPadding - buttonSize.width,
                                     y: 8, width: buttonSize.width,
                                     height: buttonSize.height)
        }
        return max(currentHeight, kThumbnailSize + 2 * kVerticalPadding)
    }
    
    @objc func dismissFPath(sender: Any)
    {
        self.contentView.window?.rootViewController?.dismiss(animated: true, completion: nil)
        GlobalVar.tipo = annotazione
        GlobalVar.call = "Recall"
    }
}
