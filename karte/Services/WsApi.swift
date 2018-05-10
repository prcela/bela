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


class WsAPI
{
    static let shared = WsAPI()
    
    static let onConnect = Notification.Name("Notification.wsConnect")
    static let onDidConnect = Notification.Name("Notification.wsDidConnect")
    static let onDidDisconnect = Notification.Name("Notification.wsDidDisconnect")
    
    static let onPlayerStatReceived = Notification.Name("WsAPI.onPlayerStatReceived")
    static let onRoomInfo = Notification.Name("WsAPI.onRoomInfo")
    static let onPlayerJoinedToTable = Notification.Name("WsAPI.onPlayerJoinedToTable")
    
    fileprivate var retryCount = 0
    fileprivate var pingInterval: TimeInterval = 40
    fileprivate var acked: Set<Int> = []
    
    var socket: WebSocket
    
    init() {
        
        let strURL = "ws://\(ipCurrent)/bela"
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
        NotificationCenter.default.post(name: WsAPI.onConnect, object: nil)
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
    
    func playerStat()
    {
        let json = JSON(["playerId":PlayerStat.shared.id, "last_n":10])
        send(.PlayerStat, json: json)
    }
    
    var unsentMessages = [String]()
    
    func send(_ action: MessageFunc, json: JSON? = nil)
    {
        var json = json ?? JSON([:])
        json["msg_func"].string = action.rawValue
        
        if let text = json.rawString(String.Encoding.utf8, options: [])
        {
            if socket.isConnected {
                print("➡️\(text)")
                socket.write(string:text)
            } else if PlayerStat.shared.tableId != nil {
                print("⬆️ Adding message to unsent!")
                unsentMessages.append(text)
            }
        }
    }
    
    func sendUnsentMessages() {
        guard unsentMessages.count < 20 else {return}
        print("🕐 sending unsent messages")
        for msg in unsentMessages {
            socket.write(string: msg)
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
        NotificationCenter.default.post(name: WsAPI.onDidConnect, object: nil)
        retryCount = 0
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("websocketDidReceiveData")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("⚠️websocketDidDisconnect")
        NotificationCenter.default.post(name: WsAPI.onDidDisconnect, object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + min(Double(retryCount+1), 5)) {
            print("retry connect")
            self.connect()
            self.retryCount += 1
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String)
    {
        let lines = text.components(separatedBy: "\n")
        
        for line in lines
        {
            print("⬅️\(line)")
            let nc = NotificationCenter.default
            let json = JSON(parseJSON: line)
            
            if let msgNum = json["msg_num"].int {
                DispatchQueue.main.async {
                    self.send(.Acked, json: JSON(["msg_num":msgNum]))
                }
                if acked.contains(msgNum) {
                    continue
                }
                acked.insert(msgNum)
            }
            
            if let msgFunc = MessageFunc(rawValue: json["msg_func"].stringValue)
            {
                switch msgFunc {
                    
                case .RoomInfo:
                    nc.post(name: WsAPI.onRoomInfo, object: json)
                    
                case .PlayerStat:
                    
                    PlayerStat.shared = PlayerStat(json: json["player"], jsonStatItems: json["stat_items"])
                    nc.post(name: WsAPI.onPlayerStatReceived, object: json)
                    
                case .JoinTable:
                    nc.post(name: WsAPI.onPlayerJoinedToTable, object: json)
                    
                default:
                    break
                }
            }
        }
    }
}
