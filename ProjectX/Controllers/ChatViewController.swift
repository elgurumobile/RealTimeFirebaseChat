//
//  ChatViewController.swift
//  ProjectX
//
//  Created by BrangerBriz Felipe on 22/05/18.
//  Copyright © 2018 BrangerBriz. All rights reserved.
//

import UIKit
import MessageKit
import MapKit
import Firebase
import FirebaseDatabase

class ChatViewController: MessagesViewController {
    
    var room : Room?
    var user : User?
    var prefixUser: String?
    var messageList: [MockMessage] = []
    var roomRefHandle: DatabaseHandle?
    
    lazy var ref: DatabaseReference = Database.database().reference().child("mychat")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        observeChats()
        
    }
    
    private func observeChats() {
        
        roomRefHandle = self.ref.child("messages").child((room?.id)!).queryOrdered(byChild: "date").observe(DataEventType.value, with: { (snapshot) in
            self.messageList = []
            let messages = snapshot.value as? [String : AnyObject] ?? [:]
            for (_, value) in messages{
                let messagedetail = value as? [String : AnyObject] ?? [:]
                let textmessage = messagedetail["message"] as? String ?? ""
                let datemessage = messagedetail["date"] as? String ?? ""
                let user = messagedetail["user"] as? [String : AnyObject] ?? [:]
                
                let userid = user["iduser"] as? String ?? ""
                let nameuser = user["name"] as? String ?? ""
                
                let attributedText = NSAttributedString(string: textmessage, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.blue])
                
                let message = MockMessage(attributedText: attributedText, sender:  Sender(id:userid, displayName:String(nameuser.prefix(1))), messageId: UUID().uuidString, date: Date(),timestamp:TimeInterval(datemessage)!)
                self.messageList.append(message)
                
            }
            self.messageList.sort(by: {$0.timestamp < $1.timestamp})
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom()
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let user = user, let room = room{
            self.ref.child("users").child(user.uid).child("rooms").updateChildValues(["\(room.id)":false])
            self.ref.child("rooms").child(room.id).child("users").updateChildValues(["\(user.uid)": false])
        }
    }
}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    func currentSender() -> Sender {
        return Sender(id: (user?.uid)!, displayName: String(prefixUser!.prefix(1)))
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let message = messageList[indexPath.section]
        
        let avatar = Avatar(initials: "\(message.sender.displayName)")
        avatarView.set(avatar: avatar)
    }
    
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 100
    }
    
    
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        // Each NSTextAttachment that contains an image will count as one empty character in the text: String
        
        for component in inputBar.inputTextView.components {
            
            if let text = component as? String {
                
                
                let timestamp = NSDate().timeIntervalSince1970
                if let room = room, let user = user, let prefixUser = prefixUser{
               
                    let messageItem = [
                        "message": "\(text)",
                        "date" : "\(timestamp)",
                        "user" : [
                                "iduser" : user.uid,
                                "name" : prefixUser
                        ]
                    ] as [String : Any]
                self.ref.child("messages").child(room.id).childByAutoId().setValue(messageItem)
                    
                    
                    let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.blue])
                    
                    let message = MockMessage(attributedText: attributedText, sender:  Sender(id: (user.uid), displayName: String(prefixUser.prefix(1))), messageId: UUID().uuidString, date: Date(), timestamp:timestamp)
                    messageList.append(message)
                    messagesCollectionView.insertSections([messageList.count - 1])
                }
               
            }
            
        }
        
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
    
}
