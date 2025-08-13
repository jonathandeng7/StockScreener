//
//  StockStore.swift
//  StockScreener
//
//  Created by Jonathan on 8/12/25.
//

final class StockStore {
    static let shared = StockStore()
    var selectedTicker: String?
}
