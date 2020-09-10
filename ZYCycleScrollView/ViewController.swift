//
//  ViewController.swift
//  ZYCycleScrollView
//
//  Created by 石志愿 on 2018/5/30.
//  Copyright © 2018年 石志愿. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.cycleSrollView)
        self.cycleSrollView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
         print("---------------deinit----------")
    }
    private lazy var cycleSrollView: ZYCycleScrollView = {[unowned self] in
        let cycleSrollView = ZYCycleScrollView(frame: CGRect(x: 0, y: 88, width: self.view.bounds.size.width, height: 200))
        cycleSrollView.delegete = self
//        cycleSrollView.autoScroll = false
        return cycleSrollView;
    }()
    
    private lazy var zoomCycleSrollView: ZYZoomCycleScrollView = {[unowned self] in
        let cycleSrollView = ZYCycleScrollView(frame: CGRect(x: 0, y: 300, width: self.view.bounds.size.width, height: 200))
        cycleSrollView.delegete = self
//        cycleSrollView.autoScroll = false
        return cycleSrollView;
        }()

    private lazy var images: Array = {
        return ["http://pic13.nipic.com/20110309/6657629_182114602194_2.jpg","http://img.taopic.com/uploads/allimg/121123/235047-1211231PT276.jpg","http://pic41.nipic.com/20140530/13701693_102456361129_2.jpg","http://pic30.nipic.com/20130625/7447430_154310311000_2.jpg", "http://b.hiphotos.baidu.com/zhidao/pic/item/6f061d950a7b02087a5f2b8362d9f2d3572cc839.jpg", "http://gss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/zhidao/pic/item/08f790529822720e773e139f7bcb0a46f31fabe7.jpg", "http://g.hiphotos.baidu.com/zhidao/pic/item/f603918fa0ec08fab7fb62045fee3d6d54fbda9e.jpg", "http://img.zcool.cn/community/0133345a2b8bd6a801216e8d824b2e.jpg@1280w_1l_2o_100sh.jpg", "http://img3.imgtn.bdimg.com/it/u=1626538308,2096425119&fm=26&gp=0.jpg", "http://img2.imgtn.bdimg.com/it/u=1580628988,1002814330&fm=26&gp=0.jpg"]
    }()
}

extension ViewController:ZYCycleScrollViewDelegate {
    func numberOfPages() -> (Int) {
        return self.images.count
    }
    
    func cycleScrollView(cycleScrollView: ZYCycleScrollView, imageDataForItemAtIndex index: Int) -> (Any) {
        return self.images[index]
    }
    
    func cycleScrollView(cycleScrollView: ZYCycleScrollView, didSelectedPageAtIndex index: Int, image: UIImage?) {
        print(String(index))
    }
}

extension ViewController: ZYZoomCycleScrollViewDelegate {
    func numberOfItems() -> (Int) {
        return self.images.count
    }
    
    func cycleScrollView(cycleScrollView: ZYZoomCycleScrollView, imageDataForItemAtIndex index: Int) -> (Any) {
        return self.images[index]
    }
    
    func cycleScrollView(cycleScrollView: ZYZoomCycleScrollView, didSelectedPageAtIndex index: Int, image: UIImage?) {
        print(String(index))
    }
}
