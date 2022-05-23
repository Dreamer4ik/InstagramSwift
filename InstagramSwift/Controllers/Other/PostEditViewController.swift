//
//  PostEditViewController.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 23.05.2022.
//

import UIKit
import CoreImage

class PostEditViewController: UIViewController {
    
    private var filters =  [UIImage]()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 1, left: 10, bottom: 1, right: 10)
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.register(PhotoCollectionViewCell.self,
                                forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        collectionView.backgroundColor = .secondarySystemBackground
        return collectionView
    }()
    
    private let image: UIImage
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        title = "Edit"
        imageView.image = image
        view.addSubview(imageView)
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(didTapNext))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.width,
            height: view.width
        )
        
        collectionView.frame = CGRect(
            x: 0,
            y: imageView.bottom + 20,
            width: view.width,
            height: 100
        )
    }
    
    @objc private func didTapNext() {
        let vc = CaptionViewController(image: image)
        vc.title = "Add Caption"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setUpFilters() {
        guard let filterImage = UIImage(systemName: "camera.filters") else {
            return
        }
        filters.append(filterImage)
    }
    
    private func filterImage(image: UIImage) {
        guard let cgImage = image.cgImage else {
            return
        }
        
        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(CIImage(cgImage: cgImage), forKey: "inputImage")
        filter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
        filter?.setValue(1.0, forKey: "inputIntensity")
        
        guard let outputImage = filter?.outputImage else {
            return
        }
        
        let context = CIContext()
        
        if let outputCgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let filteredImage = UIImage(cgImage: outputCgImage)
            
            imageView.image = filteredImage
        }
    }
}

// Collection View
extension PostEditViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionViewCell.identifier,
            for: indexPath
        ) as? PhotoCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: filters[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        filterImage(image: image)
    }
    
}
