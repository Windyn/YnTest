//
//  EmojiCollectionViewCell.swift
//  EmojiKeyBoardDemo
//
//  Created by Chakery on 16/3/3.
//  Copyright © 2016年 Chakery. All rights reserved.
//

import UIKit

class EmojiCollectionViewCell: UICollectionViewCell {
	fileprivate var emojiButton: UIButton!
	var emojiModel: EmojiModel? {
		didSet {
			bindEmojiCollectionViewCell()
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	fileprivate func setupView() {
		emojiButton = UIButton(frame: bounds)
		emojiButton.isUserInteractionEnabled = false
		emojiButton.titleLabel?.font = UIFont.systemFont(ofSize: bounds.width * 0.9)
		addSubview(emojiButton)
	}

	fileprivate func bindEmojiCollectionViewCell() {
		guard let _ = emojiModel else { return }
		// png 表情
		if let pngImage = emojiModel!.pngImage {
			emojiButton.setImage(pngImage, for: UIControlState())
		} else {
			emojiButton.setImage(nil, for: UIControlState())
		}
		// text 表情
		if let emoji = emojiModel!.emoji {
			emojiButton.setTitle(emoji, for: UIControlState())
		} else {
			emojiButton.setTitle(nil, for: UIControlState())
		}
		// 删除按钮
		if emojiModel!.deleteBtn {
			emojiButton.setImage(emojiModel!.pngImage, for: UIControlState())
		}
	}

	override func prepareForReuse() {
		emojiButton.setTitle(nil, for: UIControlState())
		emojiButton.setImage(nil, for: UIControlState())
	}
}
