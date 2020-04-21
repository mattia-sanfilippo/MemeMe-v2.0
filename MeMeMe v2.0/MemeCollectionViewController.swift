//
//  MemeCollectionViewController.swift
//  MemeMe v2.0
//
//  Created by Mattia Sanfilippo on 11/04/2020.
//  Copyright © 2020 Mattia Sanfilippo. All rights reserved.
//

import UIKit

private let reuseIdentifier = "CollectionViewCell"

class MemeCollectionViewController: UICollectionViewController {
    
    @IBOutlet var flowLayout: UICollectionViewFlowLayout!
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView?.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView?.reloadData()
    }
    
    func showEmptyView(_ show: Bool) {
        if show {
            let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView!.frame.width, height: collectionView!.frame.height))
            label.numberOfLines = 2
            label.textAlignment = .center
            label.text = "There are no memes here!"
            collectionView!.backgroundView = label
        } else {
            collectionView!.backgroundView = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowMemeDetail",
            let cell = sender as? MemeCollectionViewCell,
            let detailView = segue.destination as? MemeDetailViewController,
            let memeToShow = collectionView?.indexPath(for: cell)?.row else {
                assertionFailure("One of the conditions wasn't met")
                return
        }
    }
        
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        appDelegate.memes.count == 0 ? showEmptyView(true) : showEmptyView(false)
        return appDelegate.memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemeCollectionViewCell
        let meme: Meme = appDelegate.memes[indexPath.row]
        cell.cellImageView!.image = meme.memedImage
        return cell
    }
}
