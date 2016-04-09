//
//  ViewController.swift
//  ZTPageViewController
//
//  Created by wzt on 16/4/9.
//  Copyright © 2016年 Baidu. All rights reserved.
//

import UIKit
private let ZTPageMenuViewCellIdentifier = "ZTPageMenuViewCellIdentifier"
private let ZTPageCollectionViewCellIdentifier = "ZTPageCollectionViewCellIdentifier"
private let ZTTableViewCellIdentifier = "ZTTableViewCellIdentifier"


class ZTPageViewController: UIViewController {

    @IBOutlet weak var menuView: UICollectionView!
    @IBOutlet weak var pageView: UICollectionView!
    
    var currenIndex: Int = 0
    var dataSourceArray: [String?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        dataSourceArray = ["太原理工大学","热点","视频","体育","事实","NBA","美女","美女","体育","体育","优衣库","沈阳地铁"]
        
    }
    
}

extension ZTPageViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSourceArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.item <= dataSourceArray.count {
            if collectionView == menuView {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ZTPageMenuViewCellIdentifier, forIndexPath: indexPath) as! ZTPageMenuViewCell
                cell.backgroundColor = UIColor.whiteColor()
                cell.titleLable?.text = dataSourceArray[indexPath.row]
            
                if indexPath.item == currenIndex {
                    UIView.animateWithDuration(0.25, animations: {
                        cell.progress = 1.0
                    })
                    
                } else {
                    UIView.animateWithDuration(0.25, animations: {
                        cell.progress = 0.0
                    })
                }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ZTPageCollectionViewCellIdentifier, forIndexPath: indexPath) as! ZTPageCollectionViewCell
                let r: CGFloat = (CGFloat)(arc4random_uniform(256))/255
                let g: CGFloat = (CGFloat)(arc4random_uniform(256))/255
                let b: CGFloat = (CGFloat)(arc4random_uniform(256))/255
                cell.backgroundColor = UIColor.init(red: r, green: g, blue: b, alpha: 1)
                return cell
            }
        } else {
            return UICollectionViewCell()
        }
    }
}

extension ZTPageViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == menuView {
            let indexPaths = [indexPath,NSIndexPath.init(forItem: currenIndex, inSection: 0)]
           
             menuView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .CenteredHorizontally)
             pageView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .CenteredHorizontally)
            currenIndex = indexPath.item
            menuView.reloadItemsAtIndexPaths(indexPaths)
            
        }
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        
        if indexPath.item <= dataSourceArray.count  {
            
            if collectionView == menuView {
                let title = dataSourceArray[indexPath.row]! as NSString
                let size = title.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: NSStringDrawingOptions.TruncatesLastVisibleLine, attributes: [NSFontAttributeName : UIFont .systemFontOfSize(14)], context: nil).size
                return CGSizeMake(size.width + 30 ,collectionView.frame.size.height)
            } else {
                return collectionView.frame.size
            }
        }
        return (collectionViewLayout as! UICollectionViewFlowLayout!).itemSize
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == pageView && scrollView.contentOffset.x >= 0{
           let indexPath = NSIndexPath.init(forItem: (Int)(round(scrollView.contentOffset.x/self.view.bounds.size.width)), inSection: 0)
            menuView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .CenteredHorizontally)
            currenIndex = indexPath.item
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == pageView {
            if scrollView.contentOffset.x <= 0 || scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.frame.size.width{
                return
            }
            var nextIndex = (Int)(scrollView.contentOffset.x/self.view.bounds.size.width)
            
            if nextIndex == currenIndex {
                nextIndex = currenIndex + 1
            }
            let nextIndexPath = NSIndexPath.init(forItem: nextIndex, inSection: 0)
            let currentIndexPath = NSIndexPath.init(forItem: currenIndex, inSection: 0)
            
//            print("currtenIndex\(currenIndex)" + "     " + "nextIndex\(nextIndex)")
            let currrntCell = menuView .cellForItemAtIndexPath(currentIndexPath) as? ZTPageMenuViewCell
            let nextCell = menuView.cellForItemAtIndexPath(nextIndexPath) as? ZTPageMenuViewCell
            
            let  progress = min(abs((scrollView.contentOffset.x - (CGFloat)(nextIndex > currenIndex ? (nextIndex - 1):(nextIndex + 1)) * scrollView.frame.size.width) / scrollView.frame.size.width), 1.0)
            currrntCell?.progress = 1 - progress
            nextCell?.progress = progress
            
            if abs(nextIndex - currenIndex) > 1 {
                currenIndex =  nextIndex + 1
                menuView.reloadData()
            }
        }
    }
}


class ZTPageMenuViewCell: UICollectionViewCell {

    let colorNRGB: [CGFloat] = [85/225,85/225,85/225,1]//未选中
    let colorDRGB: [CGFloat] = [225/255,20/225,4/225,1]//选中
     var newColor: [CGFloat] = [0,0,0,0]
    @IBOutlet weak var titleLable: UILabel!
    
    internal var progress: CGFloat = 0.0 {
        didSet {
            
            for (index, number) in colorNRGB.enumerate() {
                newColor[index] = number - (number - colorDRGB[index]) * progress
            }
            titleLable.textColor = UIColor.init(red: newColor[0], green: newColor[1], blue: newColor[2], alpha: newColor[3])
            titleLable.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1 + 0.15 * progress, 1 + 0.15 * progress)
        }
    }
}

class ZTPageCollectionViewCell: UICollectionViewCell {
    
}

class ZTPageTableCell: UITableViewCell {
    
}