//
//  CoinbaseService.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/6/30.
//

import Foundation
import Starscream

class WebsocketService: WebSocketDelegate {
    static let shared = WebsocketService()
    var socket: WebSocket!

    func setWebsocket() {
        var request = URLRequest(url: URL(string: "wss://ws-feed.exchange.coinbase.com")!)
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
        
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocket) {
        switch event {
        case .connected(let headers):
            // subscribe channel
            let subscription = SubscriptionMessage(
                    type: "subscribe",
                    productIds: ["ETH-USD"],
                    channels: ["ticker_batch"]
                )
                let jsonEncoder = JSONEncoder()
                if let jsonData = try? jsonEncoder.encode(subscription),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    socket.write(string: jsonString)
                }
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("💙Received text: \(string)")
            if let data = string.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        let tickerMessage = try decoder.decode(TickerMessage.self, from: data)
                        print("💛Received price: \(tickerMessage)")
                    } catch {
                        print("Failed to decode ticker message: \(error)")
                    }
                }
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            break
        case .error(let error):
            handleError(error)
        }
    }
    
    func handleError(_ error: Error?) {
        if let error = error as? WSError {
            print("websocket encountered an error: \(error.message)\(error.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }
}

struct SubscriptionMessage: Codable {
    let type: String
    let productIds: [String]
    let channels: [String]
    
    enum CodingKeys: String, CodingKey {
        case type
        case productIds = "product_ids"
        case channels
    }
}

struct TickerMessage: Codable {
    
    let type, productId, price: String
    let sequence, tradeId: Int
    let open24h, volume24h, low24h, high24h, volume30d: String
    let bestBid, bestBidSize, bestAsk, bestAskSize: String
    let side, time, lastSize: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case sequence
        case productId = "product_id"
        case price
        case open24h = "open_24h"
        case volume24h = "volume_24h"
        case low24h = "low_24h"
        case high24h = "high_24h"
        case volume30d = "volume_30d"
        case bestBid = "best_bid"
        case bestBidSize = "best_bid_size"
        case bestAsk = "best_ask"
        case bestAskSize = "best_ask_size"
        case side
        case time
        case tradeId = "trade_id"
        case lastSize = "last_size"
    }
}
