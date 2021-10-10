//
//  CoinManager.swift
//  ByteCoin
//
//  Created by abanob on 9/25/21.
//  Copyright © 2021 abanob. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    
    func didUpdatePrice(_ lastPrice: String,_ currency: String)
    
    func didFailWithError(error: Error)
    
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["AUD","BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    
    func getCoinPrice(for currency: String) {
        let urlstring = baseURL + currency
        if let url = URL(string: urlstring) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let lastPrice = self.parseJSON(safeData) {
                        let lastPriseString = String(lastPrice)
                        self.delegate?.didUpdatePrice(lastPriseString,currency)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.last
            return lastPrice
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
