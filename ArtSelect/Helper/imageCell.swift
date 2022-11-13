//
//  imageCollectionViewCell.swift
//  ArtSelect
//
//  Created by Kelly Camacho on 5/9/22.
//  Source : https://www.youtube.com/watch?v=IQ4jh4EfVOM&t=1789s

import UIKit

class imageCell: UICollectionViewCell {
    static let identifier = "imageCell"

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func configure(with urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data , error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self?.imageView.image = image
            }
        }.resume()
    }
}
