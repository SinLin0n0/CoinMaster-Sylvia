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
    var currency: String?
    var realTimeData: ((TickerMessage) -> ())?
    
    func setWebsocket(currency: String) {
        let request = URLRequest(url: URL(string: "wss://ws-feed-public.sandbox.exchange.coinbase.com")!)
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
        self.currency = currency
    }
    
    func stopSocket() {
        socket.disconnect()
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocket) {
        switch event {
        case .connected(let headers):
            // subscribe channel
            guard let currency = currency else { return }
            let subscription = SubscriptionMessage(
                type: "subscribe",
                productIds: ["\(currency)-USD"],
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
//            print("💙Received text: \(string)")
            if let data = string.data(using: .utf8) {
                do {
                    let decoder = JSONDecoder()
                    let tickerMessage = try decoder.decode(TickerMessage.self, from: data)
                    
                    self.realTimeData!(tickerMessage)
//                    print("💛Received price: \(tickerMessage)")
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
