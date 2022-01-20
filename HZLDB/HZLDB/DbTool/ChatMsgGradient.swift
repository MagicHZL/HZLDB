////
////  ChatMsgGradient.swift
////  kaiheila_ios
////
////  Created by 郝忠良 on 2022/1/14.
////  Copyright © 2022 admin. All rights reserved.
////
//
//import UIKit
//
//let cmsgq = ChatMsgGradientQueue.init()
//
//class ChatMsgGradientQueue {
//    
//    private var timer:DispatchSourceTimer?
//    var curGrad : ChatMsgGradient?
//    var gradients : [ String :ChatMsgGradient] = [:]
//    var loaded : [String : Bool] = [:]
//    
//    init() {
//    }
//
//    func addG(guild:GuildsModel){
//        
//        let guildId = guild.id
//        
//        if let g = self.gradients[guildId]{
//            self.curGrad = g
//        }else{
//            
//            var mg = ChatMsgGradient()
//            mg.guildID = guildId
//            mg.isChannel = true
//            
//            
//            for item in guild.visible_channels {
//                if item.type == 1 {
//                    mg.chatIDs.append(item.id)
//                }
//                for t in item.channels {
//                    if t.type == 1 {
//                        mg.chatIDs.append(t.id)
//                    }
//                }
//            }
//            
//            self.gradients[guildId] = mg
//            self.curGrad = mg
//            
//        }
//    }
//
//    
//    func gisload(chatId:String) -> Bool {
//        
//         
//        if let f = self.loaded[chatId]{
//            return true
//        }
//        return false
//    }
//    
//    func gload(chatId:String){
////        self.loaded[chatId] = true
//    }
//    
//    public func startTimer() {
//        let queue = DispatchQueue(label: "gradientTimer", qos:.default)
//        self.timer = DispatchSource.makeTimerSource(queue:queue)
//        self.timer?.schedule(wallDeadline:.now(), repeating: .milliseconds(Int(100)), leeway: .milliseconds(10))
//        self.timer?.setEventHandler { [weak self] in
//            DispatchQueue.main.async { [weak self] in
//                self?.curGrad?.beginLoad()
//            }
//        }
//        self.timer?.resume()
//    }
//    
//}
//
//
//
//class ChatMsgGradient {
//    
//    var guildID : String = ""
//    var chatIDs : [String] = []
//    var isChannel : Bool = true
//    
//    init() {
//    }
//    
//    func beginLoad(){
//        
//        if chatIDs.count > 0 {
//            if let first = chatIDs.first {
//                self.getChatmsgsWithId(chatId: first)
//                chatIDs.removeFirst()
//            }
//        }
//    }
//    
//    
//    //返回参数
//    func getChatmsgsWithId(chatId:String){
//
//        var url = API_USER_CHATS+"/messages/"+chatId
//        
//        if isChannel {
//            url = API_URL_MESSAGE+"/" + chatId
//        }
//        
//        var parameters = ["msgid": "0" ,"page_size":"50"]
//        
//        if cmsgq.gisload(chatId: chatId) {return}
//        
//        NetWork.shared.get(url, parameters: parameters).subscribe(onNext: { [weak self] (json) in
//            guard let `self` = self else {return}
//            
//            if cmsgq.gisload(chatId: chatId) {return}
//            KHLog("gggggggg_\(chatId)_获取成功")
//            let array = ChatMessageModel.loadChatMessageListModel(json: json?.arrayValue ?? [] )
//            
//            var readTime = 0
//            var beferDateStr = ""
//            var relMsgs : [ChatMessageModel] = []
//            for item in array{
//                var itemValue = item
//                if(item.type != MsgType.inviteJoinVoice.rawValue){
//                    itemValue.content = itemValue.content.htmlDecoded()
//                }
//                
//                let dateStr = Date(timeIntervalSince1970: TimeInterval((item.create_at ?? 0) / 1000)).date()
//                
//                if(dateStr != beferDateStr){
//                    beferDateStr = dateStr
//                    //上一条是新消息提醒时 合并
//                    if(relMsgs.count > 0 && relMsgs.last!.type == MsgType.newMsg.rawValue){
//                        //处理消息，赋值value，新消息没有value字段
//                        var lastMsg = relMsgs.last!
//                        lastMsg.value = dateStr
//                        relMsgs[relMsgs.count - 1] = lastMsg
//                    }else{
//                        //不合并，新消息+时间cell各自展示
//                        let chatMsgModel = ChatMessageModel()
//                        chatMsgModel.type = MsgType.dateTime.rawValue
//                        chatMsgModel.value = dateStr
//                        chatMsgModel.create_at = item.create_at
//                        relMsgs.append(chatMsgModel)
//                    }
//                }
//                if(itemValue.type == MsgType.text.rawValue){
//                    var quote = itemValue.quote
//                    //判断qoute字段是否存在，如果值为空，表示已经删除
//                    if(itemValue.quote.id == "该消息已删除"){
//                        quote.content = "该消息已删除"
//                    }
//                }
//                
//                relMsgs.append(itemValue)
//            }
//            
//            ChatMessageDB.delectMessage(chatId: chatId)
//            ChatMessageDB.insertMessage(chatId: chatId, messages:relMsgs, chatType: "0") {
//                cmsgq.gload(chatId: chatId)
//            }
//            
//
//        },onError: {[weak self] err in
//            
//        })
//    }
//    
//    
//}
//
