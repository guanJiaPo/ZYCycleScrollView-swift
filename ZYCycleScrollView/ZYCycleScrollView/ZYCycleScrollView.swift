//
//  ZYCycleScrollView.swift
//  ZYCycleScrollView
//
//  Created by 石志愿 on 2018/5/30.
//  Copyright © 2018年 石志愿. All rights reserved.
//

import UIKit
import Kingfisher

let currentTintColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)
let pageTintColor = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1.0)

@objc protocol ZYCycleScrollViewDelegate {
    func numberOfPages()  -> (Int)
    func cycleScrollView(cycleScrollView: ZYCycleScrollView, imageDataForItemAtIndex index: Int) -> (Any)
    @objc optional func cycleScrollView(cycleScrollView: ZYCycleScrollView, didSelectedPageAtIndex  index: Int, image: UIImage?)
}

enum ZYScrollDirection {
    case none
    case left
    case right
}

class ZYCycleScrollView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.currentImageView)
        self.scrollView.addSubview(self.otherImageView)
        self.addSubview(self.pageControl)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            if autoScroll {
                self.timer.invalidate()
            }
        }
    }

    //MARK: - public mothed
    
    public func reloadData() {
        guard let pageCount = self.delegete?.numberOfPages() else {
            return
        }
        imageCount = pageCount
        self.pageControl.numberOfPages = imageCount
        self.pageControl.currentPage = currentIndex
        self.scrollView.isScrollEnabled = imageCount > 1
        if imageCount > 0 {
            if currentIndex >= imageCount {
                currentIndex = imageCount - 1;
            }
            loadImage(imageView: self.currentImageView, index: currentIndex)
            if autoScroll {
                self.timer.fireDate = Date(timeInterval: autoScrollTimeInterval, since: Date())
            }
        }
    }
    
    //MARK: - private mothed
    
    /// 加载图片
    private func loadImage(imageView:UIImageView, index:Int) {
        guard let imageData = self.delegete?.cycleScrollView(cycleScrollView: self, imageDataForItemAtIndex:index) else {
            return
        }
        if imageData is String {
            imageView.kf.setImage(with: URL(string: imageData as! String))
        } else if imageData is URL {
            imageView.kf.setImage(with: imageData as? URL)
        } else if imageData is UIImage {
            imageView.image = imageData as? UIImage
        }
    }
    
    /// 定时器 自动滚动
    @objc private func autoCycleScroll() {
        /// 左滑, 显示下一张
        if currentIndex == imageCount - 1 {
            otherIndex = 0
        } else {
            otherIndex = currentIndex + 1
        }
        self.otherImageView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: self.scrollView.frame.size.width, height: self.scrollView.frame.size.height)
        loadImage(imageView: self.otherImageView, index: otherIndex)
        UIView.animate(withDuration: 0.25, animations: {
            self.scrollView.contentOffset = CGPoint(x: self.frame.size.width * 2, y: 0)
        }) { (finish) in
            self.currentIndex = self.otherIndex
            self.pageControl.currentPage = self.currentIndex
            self.currentImageView.image = self.otherImageView.image
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.frame.size.width, y: 0)
        }
    }
    
    /// 图片点击事件
    @objc private func tapCurrentImageView() {
        if imageCount > currentIndex {
            self.delegete?.cycleScrollView?(cycleScrollView: self, didSelectedPageAtIndex: currentIndex, image: self.currentImageView.image)
        }
    }
    
    //MARK: - public property
    weak var delegete : ZYCycleScrollViewDelegate?
    var hidePageControl = false /// 是否隐藏页数
    var autoScroll = true       /// 是否自动滚动
    var autoScrollTimeInterval = 5.0 /// 自动滚动的间隔
    
    //MARK: - private property
    private var currentIndex = 0 /// 当前显示的图片的index
    private var otherIndex = 0   /// 将要显示的图片的index
    private var imageCount = 0   /// 图片数量
    private var currentPage = 1  /// 当前位于scrollView的第几页
    private var scrollDirection = ZYScrollDirection.none /// 手指的滑动方向

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds);
        scrollView.delegate = self;
        scrollView.contentSize = CGSize(width: self.frame.size.width * 3, height: self.frame.size.height)
        scrollView.contentOffset = CGPoint(x: self.frame.size.width, y: 0)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = false
        return scrollView;
    }()

    private lazy var currentImageView: UIImageView = {[unowned self] in
        let currentImageView = UIImageView(frame: CGRect(x: self.scrollView.frame.size.width, y: 0, width: self.scrollView.frame.size.width, height: self.scrollView.frame.size.height))
        currentImageView.clipsToBounds = true
        currentImageView.contentMode = UIViewContentMode.scaleAspectFill
        currentImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapCurrentImageView))
        currentImageView.addGestureRecognizer(tap)
        return currentImageView;
    }()
    
    private lazy var otherImageView: UIImageView = {[unowned self] in
        let otherImageView = UIImageView(frame: CGRect(x: self.scrollView.frame.size.width * 2, y: 0, width: self.scrollView.frame.size.width, height: self.scrollView.frame.size.height))
        otherImageView.clipsToBounds = true
        otherImageView.contentMode = UIViewContentMode.scaleAspectFill
        return otherImageView;
    }()
    
    private lazy var pageControl: UIPageControl = {[unowned self] in
        let pageControl = UIPageControl(frame: CGRect(x: 0, y: self.frame.size.height - 24, width: self.scrollView.frame.size.width, height: 24))
        pageControl.hidesForSinglePage = true
        pageControl.currentPageIndicatorTintColor = currentTintColor
        pageControl.pageIndicatorTintColor = pageTintColor
        return pageControl
    }()
    
    private lazy var timer: Timer = {[unowned self] in
        let timer = Timer.scheduledTimer(timeInterval: autoScrollTimeInterval, target: self, selector: #selector(autoCycleScroll), userInfo: nil, repeats: true)
        return timer
    }()
}

//MARK: - UIScrollViewDelegate

extension ZYCycleScrollView : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSetX = scrollView.contentOffset.x
        if offSetX > scrollView.frame.size.width {
            let slideDirection = ZYScrollDirection.left
            if slideDirection != scrollDirection {
                /// 左滑, 显示下一张
                if currentIndex == imageCount - 1 {
                    otherIndex = 0
                } else {
                    otherIndex = currentIndex + 1
                }
                scrollDirection = slideDirection
                self.otherImageView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                loadImage(imageView: self.otherImageView, index: otherIndex)
            }
        } else {
            let slideDirection = ZYScrollDirection.right
            if slideDirection != scrollDirection {
                /// 右滑, 显示上一张
                if currentIndex == 0 {
                    otherIndex = imageCount - 1
                } else {
                    otherIndex = currentIndex - 1
                }
                scrollDirection = slideDirection
                self.otherImageView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                loadImage(imageView: self.otherImageView, index: otherIndex)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        /// 清除滑动方向
        scrollDirection = ZYScrollDirection.none
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width + 0.5)
        if page != currentPage {
            currentIndex = otherIndex
            self.pageControl.currentPage = currentIndex
            self.currentImageView.image = self.otherImageView.image
            scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width, y: 0)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if autoScroll {
            self.timer.fireDate = Date.distantFuture
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if autoScroll {
           self.timer.fireDate = Date(timeInterval: autoScrollTimeInterval, since: Date())
        }
    }
}
