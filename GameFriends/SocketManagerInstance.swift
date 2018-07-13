//
//  SocketManager.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 9. 13..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit
import SocketIO

class SocketManagerInstance: NSObject {
    static let shardInstance = SocketManagerInstance()
    
    let manager = SocketManager(socketURL: URL(string: URLLib.urlObject.socketUrl)!)
    lazy var socket = manager.defaultSocket
//    let namespaceSocket = manager.socket(forNamespace: "/swift")

    override init() {
        super.init()
        
    }

    func socketConnect() {
        socket.connect()
    }

    func socketDisConnect() {
        socket.removeAllHandlers()
        socket.disconnect()
    }

    func socketJoin(_ clanid: String, _ userid: String) {

        let json = ["clanname" : "\(clanid)", "username" : "\(userid)"]

        socket.emit("join", json)
    }

    func socketSend(_ clanid: String, _ userid: String, _ message: String) {
        let json = ["clanname" : "\(clanid)", "username" : "\(userid)", "msg" : "\(message)"]
        socket.emit("send", json)
    }

    func socketDisConnected(_ clanid: String, _ userid: String) {
        let json = ["clanname" : "\(clanid)", "username" : "\(userid)"]
        socket.emit("disconnect", json)
        socket.emit("dc", json)
    }

    func check(completionHandler : @escaping (_ messageInfo: [String : Any]) -> Void) {
        socket.on("check") { data, act in
            print("socket_check")
            print(data)
            var messageDictionary = [String: Any]()
            messageDictionary["user"] = data[0]

            completionHandler(messageDictionary)
        }
    }

    func dcCheck(completionHandler : @escaping (_ messageInfo: [String : Any]) -> Void) {
        socket.on("dc") { data, act in
            print("socket_check")
            print(data)
            var messageDictionary = [String: Any]()
            messageDictionary["user"] = data[0]

            completionHandler(messageDictionary)
        }
    }

//    func receiveMessage() {
//        print("receiveMessage")
//        socket.on("message") { data, ack in
//            print("Receive Message")
//            print(data)
//        }
//    }

    func getMessage(completionHandler : @escaping (_ messageInfo: [String : Any]) -> Void) {

        socket.on("message") { data, act in
            var messageDictionary = [String: Any]()
            messageDictionary["nick"] = data[0]
            messageDictionary["message"] = data[1]

            completionHandler(messageDictionary)
        }

    }

}

