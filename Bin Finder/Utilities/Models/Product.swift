//  Bin Finder
//
//  Created by Antonio Baldi on 23/05/2020.
//  Copyright © 2020 Antonio Baldi. All rights reserved.
//

import Foundation

//* Model for a product search results.
// Key for wrapped data in product search response.
private let kSearchResponseKeyData = "data"
private let kSearchResponseKeySearchResults = "productSearchResults"
private let kSearchResponseKeyProducts = "products"
// Key for product properties in product search response.
private let kProductNameKey = "productName"
private let kProductScoreKey = "score"
private let kProductItemNumberKey = "itemNo"
private let kProductPriceTextKey = "priceFullText"
private let kProductImageURLKey = "imageUrl"
private let kProductTypeNameKey = "productTypeName"

struct SearchResponse: Codable {
  var data: String
  var productSearchResults: String
  var products: [Product]
}

struct Product: Codable {
  var productName: String?
  var score: Int?
  var itemNo: String?
  var imageURL: String?
  var priceFullText: String?
  var productTypeName: String?

  /**
   * Generates a list of products from given search response.
   *
   * @param response The search response.
   * @return Generated list of products.
   */
  static func products(fromResponse response: Data?) -> [Product]? {
    guard let response = response else {
      return nil
    }

    do {
      let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: response)
      return searchResponse.products
    } catch {
      print("Error in parsing a response: \(error.localizedDescription)")
    }
    return nil
  }

  var description: String {
    return "Product name: \(productName ?? ""), type: \(productTypeName ?? ""), price:\(priceFullText ?? ""), item Number: \(itemNo ?? "")"
  }
}
