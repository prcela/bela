//
//  WsApi.swift
//  bela
//
//  Created by Kresimir Prcela on 06/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON

private let ipLocalhost = "localhost:3000"
private let ipHome = "192.168.5.15:3000"
private let ipWork = "10.0.21.221:3000"
private let ipServer = "139.59.142.160:80" // ovo je pravi port!

let ipCurrent = ipLocalhost


extension Notification.Name {
    static let wsConnect = Notification.Name("Notification.wsConnect")
    static let wsDidConnect = Notification.Name("Notification.wsDidConnect")
    static let wsDidDisconnect = Notification.Name("Notification.wsDidDisconnect")
    
    static let onPlayerStatReceived = Notification.Name("Notification.onPlayerStatReceived")
}

class WsAPI
{
    static let shared = WsAPI()
    fileprivate var retryCount = 0
    fileprivate var pingInterval: TimeInterval = 40
    fileprivate var acked: Set<Int> = []
    
    var socket: WebSocket
    
    init() {
        
        let strURL = "ws://\(ipCurrent)/chat"
        let request = URLRequest(url: URL(string: strURL)!)
        socket = WebSocket(request: request, protocols: ["no-body"])
        
        socket.delegate = self
        socket.pongDelegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now()+pingInterval) {
            self.ping()
        }
    }
    
    func connect()
    {
        socket.connect()
        NotificationCenter.default.post(name: .wsConnect, object: nil)
    }
    
    func ping()
    {
        if socket.isConnected
        {
            print("➡️ping")
            socket.write(ping: Data())
        }
        else
        {
            print("socket not connected")
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+pingInterval) {
            self.ping()
        }
    }
}

extension WsAPI: WebSocketPongDelegate {
    func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
        print("⬅️pong")
    }
}


extension WsAPI: WebSocketDelegate
{
    func websocketDidConnect(socket: WebSocketClient) {
        print("✅didConnect to socket")
        NotificationCenter.default.post(name: .wsDidConnect, object: nil)
        retryCount = 0
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("websocketDidReceiveData")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("⚠️websocketDidDisconnect")
        NotificationCenter.default.post(name: .wsDidDisconnect, object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + min(Double(retryCount+1), 5)) {
            print("retry connect")
            self.connect()
            self.retryCount += 1
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String)
    {
        print("⬅️\(text)")
        
        let lines = text.components(separatedBy: "\n")
        if lines.count > 1
        {
            print("⁉️ Aaaaaaa........ Greška!!!! 2 poruke primljene u jednoj")
        }
        
        for line in lines
        {
            let nc = NotificationCenter.default
            let json = JSON(parseJSON: line)
        }
    }
}
