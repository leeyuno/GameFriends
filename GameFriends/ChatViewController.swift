//
//  ChatViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 10. 14..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import SocketIO

class ChatViewController: JSQMessagesViewController, UINavigationControllerDelegate {

    var messages = [JSQMessage]()
    let defaults = UserDefaults.standard
    
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!

    fileprivate var displayName: String!

    var useImage: UIImage!
    var remoteId = ""

    var clanid = ""
    var userid = ""
    var username = ""

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint((NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 50)))

        //self.collectionView.backgroundColor = UIColor.lightGray

        // Do any additional setup after loading the view.
        senderId = username
        senderDisplayName = username

        collectionView.collectionViewLayout.springinessEnabled = false
        automaticallyScrollsToMostRecentMessage = true

        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero

        self.inputToolbar.contentView.leftBarButtonItem = nil

        setupBubble()

        //backButton()

        //self.inputToolbar.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(_:)), name: .UIApplicationWillEnterForeground, object: nil)

        self.collectionView.reloadData()
        self.collectionView.layoutIfNeeded()

    }

    @objc func applicationDidEnterBackground(_ notification: Notification) {

        SocketManagerInstance.shardInstance.socketDisConnected(self.clanid, self.userid)
        SocketManagerInstance.shardInstance.socketDisConnect()
    }

    @objc func applicationWillEnterForeground(_ notification: Notification) {

        SocketManagerInstance.shardInstance.socketConnect()
        SocketManagerInstance.shardInstance.socketJoin(self.clanid, self.userid)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        SocketManagerInstance.shardInstance.socketConnect()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            SocketManagerInstance.shardInstance.socketJoin(self.clanid, self.userid)
        }

        SocketManagerInstance.shardInstance.dcCheck(completionHandler: {(messageInfo) -> Void in
            let message = JSQMessage(senderId: messageInfo["user"] as! String, displayName: messageInfo["user"] as! String, text: "\(messageInfo["user"] as! String)님이 퇴장했습니다.")

            self.messages.append(message!)

            self.finishSendingMessage(animated: true)
        })

        SocketManagerInstance.shardInstance.check(completionHandler: {(messageInfo) -> Void in
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-mm-dd HH:MM:SS"
            let time = dateFormatter.string(from: date)
            let time2 = dateFormatter.date(from: time)

            let message = JSQMessage(senderId: messageInfo["user"] as! String, senderDisplayName: messageInfo["user"] as! String, date: time2, text: "\(messageInfo["user"] as! String)님이 접속했습니다.")
            self.messages.append(message!)

            self.finishSendingMessage(animated: true)
        })

        SocketManagerInstance.shardInstance.getMessage(completionHandler: {(messageInfo) -> Void in
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-mm-dd HH:MM:SS"
            let time = dateFormatter.string(from: date)
            let time2 = dateFormatter.date(from: time)

            if messageInfo["nick"] as! String == self.userid {

            } else {
                let message = JSQMessage(senderId: messageInfo["nick"] as! String, senderDisplayName: messageInfo["nick"] as! String, date: time2, text: messageInfo["message"] as! String)
                self.messages.append(message!)

                self.finishSendingMessage(animated: true)
            }
        })

        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SocketManagerInstance.shardInstance.socketDisConnected(self.clanid, self.userid)
        SocketManagerInstance.shardInstance.socketDisConnect()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.tabBarController?.tabBar.isHidden = false
    }

    func setupBubble() {

        if defaults.bool(forKey: Setting.removeBubbleTails.rawValue) {
            // Make taillessBubbles
            incomingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero).incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
            outgoingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero).outgoingMessagesBubbleImage(with: UIColor.lightGray)
        }
        else {
            // Bubbles with tails
            incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
            outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.lightGray)
        }

        /**
         *  Example on showing or removing Avatars based on user settings.
         */

        if defaults.bool(forKey: Setting.removeAvatar.rawValue) {
            collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        } else {
            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
        }
    }

    func getLocalImage() -> JSQMessagesAvatarImage{
        let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/download/\(self.userid).jpg")

        let data = NSData(contentsOf: imageUrl!)
        let talkImage = UIImage(data: data! as Data)

        let returnImage = JSQMessagesAvatarImageFactory.avatarImage(with: talkImage, diameter: 100)

        return returnImage!
    }

    func getRemoteImage() -> JSQMessagesAvatarImage {
        let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/download/\(self.remoteId).jpg")

        let data = NSData(contentsOf: imageUrl!)
        let talkImage = UIImage(data: data! as Data)

        let returnImage = JSQMessagesAvatarImageFactory.avatarImage(with: talkImage, diameter: 100)

        return returnImage!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        SocketManagerInstance.shardInstance.socketSend(self.clanid, self.userid, text!)

        let message = JSQMessage(senderId: self.username, senderDisplayName: self.username, date: date, text: text!)
        self.messages.append(message!)

        self.finishSendingMessage(animated: true)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        return messages[indexPath.item].senderId == self.senderId ? outgoingBubble : incomingBubble
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if (indexPath.item % 3 == 0) {
            let message = self.messages[indexPath.item]
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }

        return nil
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        if defaults.bool(forKey: Setting.removeSenderDisplayName.rawValue) {
            return nil
        }

        if message.senderDisplayName == self.senderId {
            return nil
        }

        return NSAttributedString(string: message.senderDisplayName)
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if defaults.bool(forKey: Setting.removeSenderDisplayName.rawValue) {
            return 0.0
        }

        /**
         *  iOS7-style sender name labels
         */
        let currentMessage = self.messages[indexPath.item]

        if currentMessage.senderId == self.senderId {
            return 0.0
        }

        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }

        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        if messages[indexPath.item].senderId == self.senderId {
            return getLocalImage()
        } else {
            remoteId = messages[indexPath.item].senderId
            return getRemoteImage()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

