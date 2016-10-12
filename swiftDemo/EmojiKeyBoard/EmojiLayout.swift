//
//  EmojiLayout.swift
//  UICollectionViewDemo
//
//  Created by Chakery on 16/3/4.
//  Copyright © 2016年 Chakery. All rights reserved.
//

import UIKit

class EmojiLayout: UICollectionViewLayout {
	// 保存所有item属性
	fileprivate var attributes: [UICollectionViewLayoutAttributes] = []
	// screen
	fileprivate let mainRect = UIScreen.main.bounds
	// section
	fileprivate var sections: Int = 0
	// item
	fileprivate var items: Int = 0
	// column
	var maxColumn: CGFloat = 0
	// row
	var maxRow: CGFloat = 0
	// margin
	var margin: CGFloat = 0

	// MARK: - 允许重新布局
	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return true
	}

	// MARK: - 重新布局
	override func prepare() {
		super.prepare()

		attributes.removeAll()

		let itemsize = getItemSize(maxColumn, row: maxRow, margin: margin)
		sections = self.collectionView?.numberOfSections ?? 0
		for section in 0 ..< sections {
			items = self.collectionView?.numberOfItems(inSection: section) ?? 0
			for item in 0 ..< items {
				let indexPath = IndexPath(item: item, section: section)
				let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)

				let x = margin + (itemsize.width + margin) * (CGFloat(item).truncatingRemainder(dividingBy: maxColumn)) + (CGFloat(section) * mainRect.width)
				let y = margin + (itemsize.height + margin) * CGFloat(item / Int(maxColumn))
				attribute.frame = CGRect(x: x, y: y, width: itemsize.width, height: itemsize.height)

				attributes.append(attribute)
			}
		}
	}

	// MARK: - 返回当前可见的
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		var rectAttributes: [UICollectionViewLayoutAttributes] = []
		let _ = attributes.map {
			if rect.contains($0.frame) {
				rectAttributes.append($0)
			}
		}
		return rectAttributes
	}

	// MARK: - 返回大小
	override var collectionViewContentSize : CGSize {
		let itemsize = getItemSize(maxColumn, row: maxRow, margin: margin)
		return CGSize(width: CGFloat(sections) * mainRect.width, height: margin + (maxRow * (itemsize.height + margin)))
	}

	// MARK: - itemSize
	// 为了使得表情不变形, 因此 height = width
	fileprivate func getItemSize(_ column: CGFloat, row: CGFloat, margin: CGFloat) -> CGSize {
		let width = (mainRect.width - ((column + 1) * margin)) / column
		return CGSize(width: width, height: width)
	}
}
