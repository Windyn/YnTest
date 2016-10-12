//
//  ViewController.swift
//  swiftDemo
//
//  Created by 郭 on 16/9/29.
//  Copyright © 2016年 yn. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    fileprivate var oldRect: CGRect!
    fileprivate var isShow: Bool = false
    let cellIdentifier = "cellIdentifier"
    var dataAry = [NSAttributedString]()
       var emojiView:EmojiKeyBoardView = EmojiKeyBoardView()
    
    let faceView:FaceKeyboard = {
       let faceView = Bundle.main.loadNibNamed("FaceKeyboard", owner: nil, options: nil)?.first as! FaceKeyboard
        faceView.frame = CGRect.init(x: 0, y:UIScreen.main.bounds.height - 40 , width: UIScreen.main.bounds.width, height: 40)
        return faceView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.sendSubview(toBack: tableView)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        faceView .faceBtnClicked({ [unowned self] (sender) in
            self.emojiKeyBoardAnimate()
        })
        faceView.sendMessage { [unowned self] (sender) in
            self.dataAry.append(self.faceView.textView.attributedText)
            self.tableView.reloadData()
            self.tableView.scrollToRow(at: NSIndexPath.init(row: self.dataAry.count-1, section: 0) as IndexPath, at: .bottom, animated: true)
        }
                view.addSubview(faceView)
        
        emojiView.emojiDidSelected { [unowned self] (emojiKeyBoardView, emojiModel) in
            self.faceView.textView.insertEmoji(emojiModel)
        }
        var rect = emojiView.frame
        oldRect = emojiView.frame
        rect.origin.y = UIScreen.main.bounds.height
        emojiView.frame = rect
        view.addSubview(emojiView)
        
        tableView.frame = CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: faceView.frame.origin.y)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBOutlet weak var tableView: UITableView!
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataAry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell.textLabel?.attributedText = dataAry[indexPath.row]
        return cell
    }
    
    
    
    fileprivate func emojiKeyBoardAnimate() {
        UIView.animate(withDuration: 0.3, animations: { [unowned self]() -> Void in
            var rect = self.emojiView.frame
            var faceRect = self.faceView.frame
            if self.isShow {
                self.view.endEditing(true)
                rect.origin.y = UIScreen.main.bounds.height
                faceRect.origin.y += self.oldRect.size.height
            } else {
                self.view.endEditing(false)
                rect = self.oldRect
                faceRect.origin.y -= self.oldRect.size.height
            }
            self.isShow = !self.isShow
            self.emojiView.frame = rect
            self.faceView.frame = faceRect
            self.tableView.frame.size.height = faceRect.origin.y
            if  self.dataAry.count > 0 {
            self.tableView.scrollToRow(at: NSIndexPath.init(row: self.dataAry.count-1, section: 0) as IndexPath, at: .bottom, animated: true)
            }
            })
    }
    
    
    
}

