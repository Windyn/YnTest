//
//  EmojiKeyBoardView.swift
//  EmojiKeyBoardDemo
//
//  Created by Chakery on 16/3/3.
//  Copyright © 2016年 Chakery. All rights reserved.
//

import UIKit

// 间隙
private let margin: CGFloat = 10
// 屏幕大小
private let mainRect = UIScreen.main.bounds
// 表情宽度
private let emojiWidth: CGFloat = 45
// 表情高度
private let emojiHeight = emojiWidth
// 列
private let column: CGFloat = floor((mainRect.width - margin)/(emojiWidth + margin))
// 行
private let row: CGFloat = 4
// 工具栏高度
private let toolViewHeight: CGFloat = 30
// 工具栏的按钮宽度
private let toolButtonWidth: CGFloat = 80
// 键盘高度
private let keyBoardHeight = ((row + 1) * margin) + (row * emojiHeight)
// 回调
typealias block = (_ emojiKeyBoardView: EmojiKeyBoardView, _ emoji: EmojiModel) -> Void

class EmojiKeyBoardView: UIView {
	fileprivate let identifier = String(describing: "EmojiKeyBoardView") // identifier
	fileprivate var collectionView: UICollectionView! // 键盘
	fileprivate var toolView: UIView! // 工具栏
	fileprivate var pageControl: UIPageControl! // 页面控制器
	fileprivate var datasource: [EmojiPackageModel]? // 数据源
	fileprivate var currentEmojis: [EmojiModel]? // 当前显示的表情页面
	fileprivate var emojiHandle: block? // 回调
	fileprivate var tempButton: UIButton? // 保存当前被点击的按钮

	init() {
		super.init(frame: CGRect(x: 0, y: mainRect.height - keyBoardHeight - toolViewHeight, width: mainRect.width, height: keyBoardHeight + toolViewHeight))
		didInit()
		setupView()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	fileprivate func didInit() {
		DispatchQueue.global().async { [unowned self] _ in
			self.datasource = EmojiPackageManager.loadPackages
			// 处理数据源, 插入删除按钮
			for i in 0 ..< self.datasource!.count {
				let emojis = self.addDeleteButtonToDatasource(self.datasource![i].id, datasource: self.datasource![i].emojis!)
				self.datasource![i].emojis = emojis
			}
			DispatchQueue.main.async { [unowned self] _ in
				self.setupToolView()
				self.currentEmojis = self.datasource?.first?.emojis!
				self.collectionView.reloadData()
			}
		}
	}

	fileprivate func setupView() {
		self.backgroundColor = UIColor.white

		let rect = CGRect(x: 0, y: 0, width: mainRect.width, height: keyBoardHeight)
		let layout = EmojiLayout()
		layout.maxColumn = column
		layout.maxRow = row
		layout.margin = margin

		collectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
		collectionView.backgroundColor = UIColor(white: 0, alpha: 0.1)
		collectionView.isPagingEnabled = true
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.showsVerticalScrollIndicator = false
		collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: identifier)
		addSubview(collectionView)

		toolView = UIView(frame: CGRect(x: 0, y: bounds.height - toolViewHeight, width: bounds.width, height: toolViewHeight))
		toolView.backgroundColor = UIColor.orange
		addSubview(toolView)
	}

	/// 工具栏按钮
	fileprivate func setupToolView() {
		for i in 0 ..< datasource!.count {
			let button = UIButton(frame: CGRect(x: CGFloat(i) * toolButtonWidth, y: 0, width: toolButtonWidth, height: toolViewHeight))
			button.setTitle(datasource![i].name, for: UIControlState())
			button.tag = 1000 + i
			button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
			button.addTarget(self, action: #selector(EmojiKeyBoardView.toolButtonDidSelected(_:)), for: .touchUpInside)
			toolView.addSubview(button)
		}
		let button = toolView.viewWithTag(1000) as! UIButton
		changeButtonStatus(button)
	}

	/// 工具栏按钮点击事件(切换表情包)
	@objc fileprivate func toolButtonDidSelected(_ button: UIButton) {
		changeButtonStatus(button)
		let index = button.tag % 1000
		currentEmojis = datasource![index].emojis!
		if let _ = currentEmojis {
			collectionView.contentSize = CGSize(width: CGFloat(totalPageAt(currentEmojis!.count)) * mainRect.width, height: keyBoardHeight)
			collectionView.contentOffset = CGPoint(x: 0, y: 0)
		}
		collectionView.reloadData()
	}

	/// 添加删除按钮
	///
	/// - parameter id:         表情包ID
	/// - parameter datasource: 数据源
	fileprivate func addDeleteButtonToDatasource(_ id: String?, datasource: [EmojiModel]) -> [EmojiModel] {
		let model = EmojiModel(id: id, dic: nil, deleteBtn: true)
		var emojis: [EmojiModel] = datasource
		let count = emojis.count / Int(column * row)
		var temp = Int(column * row) - 1
		for _ in 0 ..< count {
			emojis.insert(model, at: temp)
			temp += Int(column * row)
		}
		if datasource.count % Int(column * row) != 0 {
			emojis.append(model)
		}
		return emojis
	}

	/// 通过数据源计算得到, 当前的数据源能分成多少页
	///
	/// - parameter datasource: 表情数据源
	fileprivate func totalPageAt(_ count: Int) -> Int {
		var page = 0
		page = count / Int(column * row)
		page += count % Int(column * row) == 0 ? 0 : 1
		return page
	}

	/// 当前页显示多少个表情(最后一页显示的数量没法确定.)
	///
	/// - parameter page:       当前页(indexPath.section)
	/// - parameter datasource: 表情总数(currentEmojis.count)
	fileprivate func countOfCurrentPage(_ page: Int, count: Int) -> Int {
		let current = (page + 1) * Int(column * row)
		if current > count {
			return Int(column * row) - (current - count)
		}
		return Int(column * row)
	}

	/// 改变按钮的选中状态
	///
	/// - parameter button: 按钮
	fileprivate func changeButtonStatus(_ button: UIButton) {
		if let tempButton = tempButton {
			tempButton.backgroundColor = UIColor.clear
		}
		tempButton = button
		button.backgroundColor = UIColor.gray
	}
}

// MARK: - UICollectionViewDataSource
extension EmojiKeyBoardView: UICollectionViewDataSource, UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let index = (indexPath as NSIndexPath).section * Int(column * row) + (indexPath as NSIndexPath).row
		emojiHandle?(self, currentEmojis![index])
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if let total = currentEmojis?.count {
			return countOfCurrentPage(section, count: total)
		}
		return 0
	}

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		if let datasource = currentEmojis {
			return totalPageAt(datasource.count)
		}
		return 0
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let item = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! EmojiCollectionViewCell
		if let models = currentEmojis {
			let index = ((indexPath as NSIndexPath).section * Int(column * row)) + (indexPath as NSIndexPath).row
			item.emojiModel = models[index]
		}
		return item
	}
}

// MARK: - interface
extension EmojiKeyBoardView {
	func emojiDidSelected(_ handle: @escaping block) {
		emojiHandle = handle
	}
}
