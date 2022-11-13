//
//  CanvasCell.swift
//  ArtSelect
//
//  Created by Kelly Camacho on 5/7/22.
//  Source : Textbook

import UIKit

class CanvasCell: UITableViewCell {
    @IBOutlet weak var canvasImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var notesLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Rounded corners for images
        canvasImageView.layer.cornerRadius = canvasImageView.bounds.size.width / 2
        canvasImageView.clipsToBounds = true
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Helper Method
    func configure(for canvas: Canvas) {
        if canvas.canvasDescription.isEmpty {
            notesLabel.text = "No Notes"
        } else {
            notesLabel.text = canvas.canvasDescription
        }
        
        if canvas.canvasTitle.isEmpty {
            titleLabel.text = "Untitled"
        } else {
            titleLabel.text = canvas.canvasTitle
        }
        
        canvasImageView.image = thumbnail(for: canvas)
    }
    
    func thumbnail(for canvas: Canvas) -> UIImage {
        if canvas.hasCanvas, let image = canvas.canvasImage {
            return image.resized(
                withBounds: CGSize(width: 152, height: 152))
        }
        return UIImage(named: "emptyCanvas")!
    }
    
}

extension UIImage {
    func resized(withBounds bounds: CGSize) -> UIImage {
        let ratio = min(
            bounds.width / size.width,
            bounds.height / size.height)
        let newSize = CGSize(
            width: size.width * ratio,
            height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
