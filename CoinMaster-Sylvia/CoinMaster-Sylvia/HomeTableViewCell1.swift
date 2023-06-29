//
//  HomeTableViewCell2.swift
//  LineChart
//
//  Created by Sin on 2023/6/28.
//

import UIKit

class HomeTableViewCell1: UITableViewCell {

    @IBOutlet weak var balanceBgView: UIView!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var images = [UIImage]()
    var timer:Timer?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        balanceBgView.layer.cornerRadius = 5
        balanceBgView.layer.shadowColor = UIColor.black.cgColor
        balanceBgView.layer.shadowOffset = CGSize(width: 0, height: 0)
        balanceBgView.layer.shadowOpacity = 0.15
        balanceBgView.layer.shadowRadius = 4
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        
//        pageControl.numberOfPages = images.count
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(autoScrollBanner), userInfo: nil, repeats: true)
    }

    @objc func autoScrollBanner() {

        index += 1

        if index == images.count - 1 {
            pageControl.currentPage = 0
        }else {
                pageControl.currentPage = index
            }
        if index < images.count {
            imageCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
        } else if index == images.count {
            index = 0
            imageCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
            autoScrollBanner()
        }
    }

}

extension HomeTableViewCell1: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as? HomeCollectionViewCell else {
            fatalError("Unable to dequeue ArrivalInfoTableViewCell")
        }
        cell.bannerImage.image = images[indexPath.row]
        return cell
    }
    
    
}
