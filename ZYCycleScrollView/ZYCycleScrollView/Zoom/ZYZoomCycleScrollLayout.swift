//
//  XBZoomCycleScrollLayout.swift
//  OXB
//
//  Created by 石志愿 on 2019/12/28.
//  Copyright © 2019 石志愿. All rights reserved.
//

import UIKit

class ZYZoomCycleScrollLayout: UICollectionViewFlowLayout {
    
    // 卡片滚动
    var cellDidScrollToIndex: ((_ indexPath: IndexPath) -> ())?
    
    //居中卡片宽度与据屏幕宽度比例
    private let CardWidthScale: CGFloat = 0.7
    private let CardHeightScale: CGFloat = 0.8
    
    //卡片宽度
    private var itemWidth: CGFloat {
        return (self.collectionView?.bounds.size.width ?? 0) * CardWidthScale
    }
    
    //卡片高度
    private var itemHeight: CGFloat {
        return (self.collectionView?.bounds.size.height ?? 0) * CardHeightScale
    }
    

    //设置左右缩进
    private var insetX: CGFloat {
        return ((self.collectionView?.bounds.size.width ?? 0) - self.itemWidth)/2
    }
    
    //卡片宽度
    private var insetY: CGFloat {
        return ((self.collectionView?.bounds.size.height ?? 0) - self.itemHeight)/2
    }
    
    //. 布局之前的准备工作 初始化  这个方法每次layout发生改变就调用一次
    override func prepare() {
        super.prepare()
        self.scrollDirection = UICollectionView.ScrollDirection.horizontal
        self.sectionInset = UIEdgeInsets(top: self.insetY, left: self.insetX, bottom: self.insetY, right: self.insetX)
        self.itemSize = CGSize(width: self.itemWidth, height: self.itemHeight)
        self.minimumLineSpacing = 5
    }
    
    /// frame发生改变就允许重新布局
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        //根据当前滚动进行对每个cell进行缩放
        
        //首先获取 当前rect范围内的 attributes对象
        let attributesArr = super.layoutAttributesForElements(in: rect)
        
        guard let collectView = self.collectionView else {
            return attributesArr
        }
        
        //colleciotnView中心点的值
        let centerX = collectView.contentOffset.x + collectView.bounds.size.width/2
        //最大移动距离，计算范围是移动出屏幕前的距离
        let maxApart: CGFloat = (collectView.bounds.size.width + self.itemWidth)/2.0
        //循环遍历每个attributes对象 对每个对象进行缩放
        for attributes in attributesArr! {
            //获取cell中心和屏幕中心的距离
            let apart: CGFloat = abs(attributes.center.x - centerX)
            //移动进度 -1~0~1
            let progress: Double = Double(apart/maxApart)
            //在屏幕外的cell不处理
            if (abs(progress) > 1) {continue;}
            //根据余弦函数，弧度在 -π/4 到 π/4,即 scale在 √2/2~1~√2/2 间变化
            let scale: CGFloat = CGFloat(abs(cos(progress * Double.pi/4)))
            //缩放大小
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
            //更新中间位
            if (apart <= self.itemWidth/2) {
                self.cellDidScrollToIndex?(attributes.indexPath)
            }
        }
        
        return attributesArr
    }
}
