//
//  Tickers.swift
//  NFCTagReader
//
//  Created by Ryan Tinder on 4/23/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftyJSON

@available(iOS 17.0, *)
@Observable class Tickers {
    static let shared = Tickers()
    
    static let BASE_URL: String = "https://strong-dinner-production.up.railway.app/tickers"
    
    var tickers = [String]()
    
    init() {}
    
    func refresh() async throws {
        guard let URL = URL(string: Tickers.BASE_URL) else {
            print("URL failed")
            return
        }

        let (data, response) = try await URLSession.shared.data(from: URL)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("fetch failed")
            return
        }

        let rawJson = try JSON(data: data)
        print(rawJson)
        let betJsonArray = rawJson["tickers"].arrayValue

        var results = [String]()

        for json in betJsonArray {

            results.append(json.stringValue)
        }
        
        self.tickers = results;
        print(self.tickers)
    }
}
