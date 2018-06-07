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

    private lazy var images: Array = {
        return ["http://pic24.nipic.com/20121011/668573_132254638173_2.jpg","http://pic13.nipic.com/20110309/6657629_182114602194_2.jpg","http://img.taopic.com/uploads/allimg/121123/235047-1211231PT276.jpg","http://pic41.nipic.com/20140530/13701693_102456361129_2.jpg","http://pic30.nipic.com/20130625/7447430_154310311000_2.jpg"]
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
