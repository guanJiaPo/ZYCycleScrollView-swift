//
//  XBPageControl.swift
//  OXB
//
//  Created by 石志愿 on 2019/12/30.
//  Copyright © 2019 石志愿. All rights reserved.
//

import UIKit

class ZYPageControl: UIView {
    
    /// 未选中的原点颜色
    var indicatorTintColor: UIColor?
    /// 当前页的选中图片
    var indicatorCurrentTintIcon: String?
    /// 当前页的选中颜色(优先使用indicatorCurrentTintIcon)
    var indicatorCurrentTintColor: UIColor?
    
    /// 当前页 0 ~ numberOfPages-1
    var currentPage: Int = 0  {
        didSet {
            var itemX: CGFloat = 0
            if currentPage < numberOfPages {
                for i in 0 ..< numberOfPages {
                    if let view = self.contentView.viewWithTag(1000 + i) {
                        let width: CGFloat = i == currentPage ? currentItemWidth : itemWidth
                        refreshForCurrentPageChange(index: i, view: view, itemX: itemX, itemW: width)
                        itemX += (width + padding)
                    }
                }
            } else {
                ZYPrint("ZYPageControl 当前页超出总页数")
            }
        }
    }
    
    /// 页数
    var numberOfPages: Int = 0 {
        didSet {
            //页数大于10
            if numberOfPages < 2 {
                self.contentView.isHidden = true
                return
            }
            
            let totalWidth: CGFloat = currentItemWidth + (itemWidth + padding) * CGFloat(numberOfPages - 1)
            self.contentView.isHidden = false
            contentView.snp.updateConstraints { (make) in
                make.width.equalTo(totalWidth)
            }
            
            if numberOfPages > self.contentView.subviews.count {
                //尽量避免重复移除/重建item
                for view in self.contentView.subviews {
                    view.removeFromSuperview()
                }
                var itemX: CGFloat = 0
                for i in 0 ..< numberOfPages {
                    let imageView = UIImageView()
                    imageView.tag = 1000 + i
                    let width: CGFloat = i == currentPage ? currentItemWidth : itemWidth
                    contentView.addSubview(imageView)
                    imageView.snp.makeConstraints { (make) in
                        make.height.equalTo(itemHeight)
                        make.width.equalTo(width)
                        make.left.equalTo(itemX)
                        make.centerY.equalToSuperview()
                    }
                    refreshForCurrentPageChange(index: i, view: imageView, itemX: itemX, itemW: width)
                    itemX += (width + padding)
                }
            } else {
                var itemX: CGFloat = 0
                for (i, view) in self.contentView.subviews.enumerated() {
                    if i >= numberOfPages {
                        view.isHidden = true
                    } else {
                        let width: CGFloat = i == currentPage ? currentItemWidth : itemWidth
                        refreshForCurrentPageChange(index: i, view: view, itemX: itemX, itemW: width)
                        itemX += (width + padding)
                    }
                }
            }
        }
    }
    
    /// 普通item的长度
    private var itemWidth: CGFloat = 8
    /// 当前item的长度
    private var currentItemWidth: CGFloat = 24
    /// item的高度
    private var itemHeight: CGFloat = 2
    /// item的间距
    private var padding: CGFloat = 4
    
    convenience init(frame: CGRect, itemWidth: CGFloat = 8, currentItemWidth: CGFloat = 8, itemHeight: CGFloat = 2, padding: CGFloat = 4) {
        self.init(frame: frame)
        self.itemWidth = itemWidth
        self.currentItemWidth = currentItemWidth
        self.itemHeight = itemHeight
        self.padding = padding
        setSubViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if self.contentView.subviews.count > 0 {
            let views = self.contentView.subviews.compactMap { $0 }
            for subView in views {
                subView.removeFromSuperview()
            }
        }
        setSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSubViews() {
        self.addSubview(self.contentView)
        contentView.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.width.equalTo(0)
            make.top.equalTo(0)
            make.centerX.equalToSuperview()
        }
        
        var itemX: CGFloat = 0
        /// 先创建10个原点
        for i in 0 ..< 10 {
            let imageView = UIImageView()
            imageView.tag = 1000 + i
            imageView.isHidden = true
            contentView.addSubview(imageView)
            let width: CGFloat = i == currentPage ? currentItemWidth : itemWidth
            imageView.snp.makeConstraints { (make) in
                make.height.equalTo(itemHeight)
                make.width.equalTo(width)
                make.left.equalTo(itemX)
                make.centerY.equalToSuperview()
            }
            imageView.setCornerRadius(cornerRadius: itemHeight/2, size: CGSize(width: width, height: itemHeight))
            itemX += (width + padding)
        }
    }
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private func refreshForCurrentPageChange(index: Int, view: UIView, itemX: CGFloat, itemW: CGFloat) {
        view.isHidden = false
        view.snp.updateConstraints { (make) in
            make.width.equalTo(itemW)
            make.left.equalTo(itemX)
        }
        view.setCornerRadius(cornerRadius: itemHeight/2, size: CGSize(width: itemW, height: itemHeight))
        let imageView = view as! UIImageView
        if index == currentPage {
            if let icon = self.indicatorCurrentTintIcon {
                imageView.image = UIImage(named: icon)
            } else {
                imageView.image = nil
                imageView.backgroundColor = indicatorCurrentTintColor
            }
        } else {
            imageView.image = nil
            imageView.backgroundColor = indicatorTintColor
        }
    }
}
