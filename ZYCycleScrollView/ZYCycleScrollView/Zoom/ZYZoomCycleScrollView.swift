//
//  ZYZoomScrollView.swift
//  OXB
//
//  Created by 石志愿 on 2019/12/28.
//  Copyright © 2019 石志愿. All rights reserved.
//

import UIKit

@objc protocol ZYZoomCycleScrollViewDelegate {
    func numberOfItems()  -> (Int)
    func cycleScrollView(zoomCycleScrollView: ZYZoomCycleScrollView, imageDataForItemAtIndex index: Int) -> (Any)
    @objc optional func cycleScrollView(zoomCycleScrollView: ZYZoomCycleScrollView, didSelectedPageAtIndex index: Int, imageData: Any)
}

class ZYZoomCycleScrollView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubViews()
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
    
    private func setSubViews() {
        self.addSubview(self.collectionView)
        self.addSubview(self.pageControl)
    }
    
    weak var delegate: ZYZoomCycleScrollViewDelegate?
    /// 是否隐藏页数
    var hidePageControl = false
    /// 是否自动滚动
    var autoScroll = true
    /// 自动滚动的间隔
    var autoScrollTimeInterval = 4.0
    
    /// 选中颜色
    var currentPageTintColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0) {
        didSet {
            self.pageControl.indicatorCurrentTintColor = currentPageTintColor
        }
    }
    /// 非选中颜色
    var pageTintColor = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1.0) {
        didSet {
            self.pageControl.indicatorTintColor = pageTintColor
        }
    }
    
    //MARK: - public mothed
    
    public func reloadData() {
        guard let pageCount = self.delegate?.numberOfItems() else {
            return
        }
        
        var imageDatas = [Any]()
        for i in 0 ..< pageCount {
            if let imageData = delegate?.cycleScrollView(zoomCycleScrollView: self, imageDataForItemAtIndex: i) {
                imageDatas.append(imageData)
            }
        }
        
        images.append(contentsOf: imageDatas)
        images.append(contentsOf: imageDatas)
        images.append(contentsOf: imageDatas)
        
        imageCount = pageCount
        self.currentPage = imageCount
        self.currentIndex = imageCount
        self.pageControl.numberOfPages = pageCount
        self.pageControl.currentPage = currentPage%pageCount
        self.collectionView.isScrollEnabled = pageCount > 1
        if pageCount > 0 {
            self.collectionView.reloadData()
            delay(0.2) {
                self.switchTo(index: pageCount, animated: false)
            }
            
            if autoScroll {
                self.timer.fireDate = Date(timeInterval: autoScrollTimeInterval, since: Date())
            }
        }
    }
    
    /// 数据源
    private var images = [Any]()
    /// 图片数量
    private var imageCount = 0
    /// 当前选中位置
    private var currentIndex = 0
    
    /// 开始拖动的点
    private var dragStartX: CGFloat = 0
    /// 结束拖动的点
    private var dragEndX: CGFloat = 0
    /// 结束拖动时的位置
    private var dragAtIndex = 0
    /// 当前页
    private var currentPage = 0
    
    /// 定时器 自动滚动
    @objc private func autoCycleScroll() {
        var index = currentIndex
        index += 1
        
        let rows = self.collectionView.numberOfItems(inSection: 0)
        if index < rows {
            self.switchTo(index: index, animated: true)
            self.scrollViewDidEndDecelerating(self.collectionView)
        }
    }
    
    //配置cell居中
    private func fixCellToCenter() {
        if currentIndex != dragAtIndex {
            scrollToCenterAnimated(index: currentIndex,animated: true)
            return
        }
        //最小滚动距离
        let dragMiniDistance: CGFloat = self.bounds.width/20.0
        var index = currentIndex
        if dragStartX - dragEndX >= dragMiniDistance {
            //向右
            index -= 1
        } else if dragEndX - dragStartX >= dragMiniDistance {
            //向左
            index += 1
        }
        let maxInedx = self.collectionView.numberOfItems(inSection: 0) - 1
        index = max(0, index)
        index = min(maxInedx, index)
        currentPage = index
        scrollToCenterAnimated(index: index,animated: true)
    }
    
    // 手动滚动到某个卡片位置
    private func switchTo(index: Int, animated: Bool) {
        currentPage = index
        self.pageControl.currentPage = currentPage%imageCount
        scrollToCenterAnimated(index: index,animated: animated)
    }
    
    // 滚动到中间
    private func scrollToCenterAnimated(index:Int, animated: Bool) {
        self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: animated)
    }
    
    private lazy var collectionView: UICollectionView = {
        let flowlayout = ZYZoomCycleScrollLayout()
        let cycleCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height), collectionViewLayout: flowlayout)
        cycleCollectionView.backgroundColor = UIColor.red
        cycleCollectionView.isPagingEnabled = true
        cycleCollectionView.bounces = false
        cycleCollectionView.dataSource = self
        cycleCollectionView.delegate = self
        cycleCollectionView.showsHorizontalScrollIndicator = false
        cycleCollectionView.showsVerticalScrollIndicator = false
        cycleCollectionView.register(ZYZoomScrollCell.self, forCellWithReuseIdentifier: ZYZoomScrollCellIdfi)
        return cycleCollectionView
    }()
    
    private lazy var pageControl: ZYPageControl = {[unowned self] in
        let pageControl = ZYPageControl(frame: CGRect(x: 0, y: self.frame.size.height - 24, width: self.frame.size.width, height: 24))
        pageControl.indicatorCurrentTintColor = currentPageTintColor
        pageControl.indicatorTintColor = pageTintColor
        return pageControl
    }()
    
    private lazy var timer: Timer = {[unowned self] in
        let timer = Timer.scheduledTimer(timeInterval: autoScrollTimeInterval, target: self, selector: #selector(autoCycleScroll), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        return timer
    }()
}

extension ZYZoomCycleScrollView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = imageCount
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZYZoomScrollCellIdfi, for: indexPath) as! ZYZoomScrollCell

        cell.reloadData(imageData: images[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentIndex = indexPath.row
        scrollToCenterAnimated(index: currentIndex,animated: true)
        self.delegate?.cycleScrollView?(zoomCycleScrollView: self, didSelectedPageAtIndex: indexPath.row, imageData: images[indexPath.row])
    }
    
    //MARK: UIScrollViewDelegate
    
    //手指拖动开始
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.dragStartX = scrollView.contentOffset.x
        self.dragAtIndex = currentIndex
        if autoScroll {
            self.timer.fireDate = Date.distantFuture
        }
    }
    
    //手指拖动停止
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.dragEndX = scrollView.contentOffset.x
        DispatchQueue.main.async {
            self.fixCellToCenter()
        }
        
        if autoScroll {
            self.timer.fireDate = Date(timeInterval: autoScrollTimeInterval, since: Date())
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    
        if currentPage == currentIndex {
            return
        }
        var move = false
        if currentPage < imageCount {
            currentPage += imageCount
            move = true
        }
        if currentPage > imageCount*2 {
            currentPage -= imageCount
            move = true
        }

        currentIndex = currentPage
        self.pageControl.currentPage = currentIndex%imageCount
        if move {
            delay(0.2) {
                self.scrollToCenterAnimated(index: self.currentIndex,animated: false)
            }
        }
    }
}

let ZYZoomScrollCellIdfi = "ZYZoomScrollCell"

class ZYZoomScrollCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSubViews() {
        self.contentView.addSubview(self.imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private lazy var imageView: UIImageView = {
        let tempView = UIImageView()
        tempView.contentMode = UIView.ContentMode.scaleAspectFill
        tempView.clipsToBounds = true
        return tempView
    }()
    
    func reloadData(imageData: Any) {
        if imageData is String {
            imageView.kf.setImage(with: URL(string: imageData as! String))
        } else if imageData is URL {
            imageView.kf.setImage(with: imageData as? URL)
        } else if imageData is UIImage {
            imageView.image = imageData as? UIImage
        }
    }
}
