//
//  API.swift
//  StockScreener
//
//  Created by Jonathan on 8/12/25.
//

//  API.swift
//  StockScreener
//
//  Finnhub-based API helper (search + candles)

import Foundation

// MARK: - Public models

struct Symbol: Hashable {
    let symbol: String
    let name: String
}

struct Candle {
    let date: Date
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
}

// MARK: - Timeframe → Finnhub resolution

enum Timeframe {
    case d1      // 1 Day intraday (5m)
    case w1      // ~1 Week (15m)
    case m1      // 1 Month (1h)
    case m3      // 3 Months (D)
    case y1      // 1 Year (D)

    var resolution: String {
        switch self {
        case .d1: return "5"      // 5-minute bars
        case .w1: return "15"     // 15-minute bars
        case .m1: return "60"     // 1-hour bars
        case .m3: return "D"      // daily
        case .y1: return "D"
        }
    }

    func dateRange(ending end: Date = Date()) -> (from: Date, to: Date) {
        let cal = Calendar.current
        switch self {
        case .d1:
            
            return (cal.date(byAdding: .day, value: -3, to: end)!, end)
        case .w1:
            
            return (cal.date(byAdding: .day, value: -12, to: end)!, end)
        case .m1:
            
            return (cal.date(byAdding: .day, value: -45, to: end)!, end)
        case .m3:
            return (cal.date(byAdding: .month, value: -3, to: end)!, end)
        case .y1:
            return (cal.date(byAdding: .year, value: -1, to: end)!, end)
        }
    }
}

// MARK: - API

enum API {
    
    static let finnhubKey = "d2drchhr01qjrul4neegd2drchhr01qjrul4nef0"

    

    
    static func searchSymbols(_ query: String, completion: @escaping ([Symbol]) -> Void) {
        guard !finnhubKey.isEmpty else {
            print("⚠️ Finnhub API key missing")
            DispatchQueue.main.async { completion([]) }
            return
        }
        let q = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "https://finnhub.io/api/v1/search?q=\(q)&token=\(finnhubKey)")!

        URLSession.shared.dataTask(with: url) { data, resp, err in
            func finish(_ items: [Symbol]) { DispatchQueue.main.async { completion(items) } }

            if let err = err { print("Search error:", err); return finish([]) }
            if let http = resp as? HTTPURLResponse, http.statusCode == 429 {
                print("Search rate-limited (HTTP 429)")
                return finish([])
            }
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let arr = json["result"] as? [[String: Any]]
            else { return finish([]) }

            let filtered = arr.compactMap { m -> Symbol? in
                guard
                    let s = m["symbol"] as? String, !s.isEmpty,
                    let type = m["type"] as? String,
                    type == "Common Stock",
                    !s.contains(".")
                else { return nil }
                let name = (m["description"] as? String)?
                    .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                return Symbol(symbol: s, name: name)
            }

            return finish(filtered)
        }.resume()
    }


    

    
    static func candles(symbol: String,
                        timeframe: Timeframe,
                        completion: @escaping ([Candle]) -> Void)
    {
        let (fromDate, toDate) = timeframe.dateRange()
        let from = Int(fromDate.timeIntervalSince1970)
        let to   = Int(toDate.timeIntervalSince1970)
        let res  = timeframe.resolution

        let url = URL(string:
            "https://finnhub.io/api/v1/stock/candle?symbol=\(symbol)&resolution=\(res)&from=\(from)&to=\(to)&token=\(finnhubKey)"
        )!

        URLSession.shared.dataTask(with: url) { data, resp, err in
            func finish(_ items: [Candle]) { DispatchQueue.main.async { completion(items) } }

            if let err = err { print("Candles error:", err); return finish([]) }
            if let http = resp as? HTTPURLResponse, http.statusCode == 429 {
                print("Candles rate-limited (HTTP 429)")
                return finish([])
            }
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else { return finish([]) }

            
            guard let status = json["s"] as? String, status == "ok" else { return finish([]) }

            
            guard
                let ts = json["t"] as? [Int],
                let o  = json["o"] as? [Double],
                let h  = json["h"] as? [Double],
                let l  = json["l"] as? [Double],
                let c  = json["c"] as? [Double],
                let v  = json["v"] as? [Double],
                ts.count == o.count, o.count == h.count, h.count == l.count, l.count == c.count, c.count == v.count
            else { return finish([]) }

            let items: [Candle] = zip(ts.indices, ts).map { idx, epoch in
                Candle(date: Date(timeIntervalSince1970: TimeInterval(epoch)),
                       open: o[idx], high: h[idx], low: l[idx], close: c[idx], volume: v[idx])
            }
            return finish(items)
        }.resume()
    }
}
