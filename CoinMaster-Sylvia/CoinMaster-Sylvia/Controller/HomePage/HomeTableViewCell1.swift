//
//  HomeTableViewCell2.swift
//  LineChart
//
//  Created by Sin on 2023/6/28.
//

import UIKit
import iCarousel

class HomeTableViewCell1: UITableViewCell {

    @IBOutlet weak var balanceBgView: UIView!
    @IBOutlet weak var carousel: iCarousel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var hideBalanceView: UIView!
    @IBOutlet weak var hideBalanceButton: UIButton!
    
    let imageNames = ["banner1", "banner2", "banner3", "banner4"]
    var timer:Timer?
    var index = 0
    var hideBalanceViewIsHidden = true
    
    var webArray: [String]? = ["https://ethereum.org/zh-tw/", "https://coinmarketcap.com/zh-tw/currencies/solana/", "https://www.wantgoo.com/global/btc", "https://ethereum.org/zh-tw/", "https://ethereum.org/zh-tw/"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        balanceBgView.layer.cornerRadius = 3
        balanceBgView.layer.shadowColor = UIColor.black.cgColor
        balanceBgView.layer.shadowOffset = CGSize(width: 0, height: 2)
        balanceBgView.layer.shadowOpacity = 0.25
        balanceBgView.layer.shadowRadius = 4
        carousel.delegate = self
        carousel.dataSource = self
        carousel.type = .linear
        carousel.isPagingEnabled = true
        pageControl.numberOfPages = carousel.numberOfItems
        pageControl.currentPage = 0
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(autoScrollBanner), userInfo: nil, repeats: true)
        hideBalanceButton.setImage(UIImage(named: "eye-open"), for: .normal)
        hideBalanceView.isHidden = true
    }
    @objc func autoScrollBanner() {
        carousel.scrollToItem(at: carousel.currentItemIndex + 1, animated: true)
    }

    @IBAction func hideBalance(_ sender: Any) {
        if hideBalanceViewIsHidden {
            hideBalanceButton.setImage(UIImage(named: "eye-close"), for: .normal)
            hideBalanceView.isHidden = false
            hideBalanceViewIsHidden = false
        }else {
            hideBalanceButton.setImage(UIImage(named: "eye-open"), for: .normal)
            hideBalanceView.isHidden = true
            hideBalanceViewIsHidden = true
        }
    }
    
    
}

extension HomeTableViewCell1: iCarouselDelegate, iCarouselDataSource {
    func numberOfItems(in carousel: iCarousel) -> Int {
        imageNames.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let itemImageView = UIImageView(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: UIScreen.main.bounds.width,
                                                      height: carousel.bounds.height))
        itemImageView.image = UIImage(named: "\(imageNames[index])")
        return itemImageView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        // 更改輪播的預設值，把頭尾包在一起，如果是0的話就是不會輪播
        if option == .wrap {
            return 1
        }
        return value
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        pageControl.currentPage = carousel.currentItemIndex
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        
        if let urlString = webArray?[index] {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
}
