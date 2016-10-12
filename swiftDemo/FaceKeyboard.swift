//
//  faceKeyboard.swift
//  swiftDemo
//
//  Created by 郭 on 16/9/29.
//  Copyright © 2016年 yn. All rights reserved.
//

import UIKit

class FaceKeyboard: UIView,UITextViewDelegate {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textView.delegate = self
    }
    
    typealias faceClickBlock = (_ sender:NSObject) -> Void
    
    var  faceClick:faceClickBlock = {_ in }
    var addAction:faceClickBlock = {_ in }
    var sendAction:faceClickBlock = {_ in}
    
    @IBOutlet weak var textView: UITextView!

    @IBAction func sendAction(_ sender: UIButton) {
        addAction(sender)
    }
    @IBOutlet weak var faceButton: UIButton!
    @IBAction func faceBtnClick(_ sender: UIButton) {
        faceClick(sender)
    }
    
    func faceBtnClicked(_ click:@escaping faceClickBlock) -> Void {
        faceClick = click
    }
    
    func addToolbar(_ add:@escaping faceClickBlock) -> Void {
        addAction = add
    }
    
    func sendMessage(_ send:@escaping faceClickBlock){
        sendAction = send
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "/n" {
            sendAction(textView)
        }
        return true
    }
}
