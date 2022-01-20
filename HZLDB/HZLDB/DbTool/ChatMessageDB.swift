////
////  ChatMessageDB.swift
////  kaiheila_ios
////
////  Created by 郝忠良 on 2022/1/4.
////  Copyright © 2022 admin. All rights reserved.
////
//
//import UIKit
//import SwiftyJSON
//
//class  ChatMessageDB {
//
//
//    static var table : String = "ChatMessage"
//
//    init() {
//
//    }
//    static func initDB(){
//        AthUserDbManager.share().initSafeDB(logingUserGuildConfig.meID ?? "0")
//    }
//    static func getDBMessage(chatId:String,reblock:@escaping (ChatCacheModel)->()){
//
//        //获取消息列表
//        DispatchQueue.global().async {
//
//            AthUserDbManager.share().searchData(["chatId":chatId], resault: { messages in
//                var cacheMo  = ChatCacheModel()
//    //            cacheMo.msgData =
//                cacheMo.chatID = chatId
//                cacheMo.isReload = true
//
//                var msgData : [ChatMessageModel] = []
//                for msg in messages ?? [] {
//                    //
//                    if let m = msg as? [String:String],var contJsonStr = m["contentJosn"]?.glt_base64Decoding(){
//                        var contJsonDic = JSON.init(parseJSON: contJsonStr)
//                        var realJson = JSON()
//                        for (key,val) in contJsonDic {
//                            if key.contains("_Json") {
//                                realJson[key.replacingOccurrences(of: "_Json", with: "")] = JSON.init(parseJSON: val.stringValue)
//                            }else{
//                                realJson[key] = JSON(val)
//                            }
//                        }
//                        var chatMo = ChatMessageModel.init(json: realJson)
//                        chatMo.channel_id = chatId
//                        msgData.append(chatMo)
//                    }
//                }
//
//                msgData.sort { val1, val2 in
//                    return val1.create_at < val2.create_at
//                }
//                cacheMo.msgData = msgData
//                cacheMo.index = msgData.count
//
//                DispatchQueue.main.async {
//                    reblock(cacheMo)
//                }
//
//            }, table: self.table , orderFile: "creatTime", adsc: "desc",limit:50)
//        }
//
//    }
//    //chatType 0 new 1 old
//    static  func insertMessage(chatId:String,messages:[ChatMessageModel],chatType:String,reblock:(()->())? = nil){
//
//        DispatchQueue.global().async {
//            //插入消息 只存最后50条或200条
//            KHLog("dbchat___\(chatId)")
//            var msgDbs : [[String:String]] = []
//            for msg in messages {
//                var json = JSON(msg.toDBModel())
//                var contentJosn = json.rawString(options: .sortedKeys) ?? ""
//                var cont64 = contentJosn.glt_base64Encoding()
//                msgDbs.append(["chatId":chatId,"contentJosn":cont64,"chatType":"0","cid":json["rong_id"].stringValue,"creatTime":json["create_at"].stringValue])
//            }
//            if msgDbs.count == 1 , let first = msgDbs.first {
//                AthUserDbManager.share().insertData(withModel: first, table: self.table, where: ["cid":first["cid"],"creatTime":first["create_at"]])
//            }else{
//                AthUserDbManager.share().insertData(withModel: msgDbs, table: self.table, where: [:])
//            }
//
//            DispatchQueue.main.async {
//                reblock?()
//            }
//
//        }
//
//    }
//
//    static func delectMessage(chatId:String,cid : String? = nil){
//        //删除消息
//        if let c = cid {
//            AthUserDbManager.share().deleteData(withModel: ["chatId":chatId,"cid":c], table: self.table)
//        }else{
//            AthUserDbManager.share().deleteData(withModel: ["chatId":chatId], table: self.table)
//        }
//    }
//
//    static func delectAllMessage(){
//        //删除消息
//        AthUserDbManager.share().deleteData(withModel: [:], table: self.table)
//    }
//
//
//}
//
