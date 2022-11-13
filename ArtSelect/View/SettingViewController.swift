//
//  SettingViewController.swift
//  ArtSelect
//
//  Created by Kelly Camacho on 5/4/22.
//

import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func settingsViewControllerFinished(
        _ settingsViewController: SettingsViewController
    )
}

class SettingsViewController:  UITableViewController {
    weak var delegate: SettingsViewControllerDelegate?

    @IBOutlet weak var sliderStroke: UISlider!
    @IBOutlet weak var sliderOpacity: UISlider!
    @IBOutlet weak var previewImageView: UIImageView!
  
    @IBOutlet weak var labelStroke: UILabel!
    @IBOutlet weak var labelOpacity: UILabel!
  
    @IBOutlet weak var sliderRed: UISlider!
    @IBOutlet weak var sliderGreen: UISlider!
    @IBOutlet weak var sliderBlue: UISlider!
  
    @IBOutlet weak var labelRed: UILabel!
    @IBOutlet weak var labelGreen: UILabel!
    @IBOutlet weak var labelBlue: UILabel!
    
    var stroke: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    
    let colorWell: UIColorWell = {
        let colorWell = UIColorWell()
        colorWell.supportsAlpha = true
        colorWell.selectedColor = .systemRed
        colorWell.title = "Color Well"
        return colorWell
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.addSubview(colorWell)
        colorWell.addTarget(self, action: #selector(colorChanged as () -> ()), for: .valueChanged)
    
        sliderStroke.value = Float(stroke)
        labelStroke.text = String(format: "%.1f", stroke)
        sliderOpacity.value = Float(opacity)
        labelOpacity.text = String(format: "%.1f", opacity)
        sliderRed.value = Float(red * 255.0)
        labelRed.text = Int(sliderRed.value).description
        sliderGreen.value = Float(green * 255.0)
        labelGreen.text = Int(sliderGreen.value).description
        sliderBlue.value = Float(blue * 255.0)
        labelBlue.text = Int(sliderBlue.value).description
            
        drawPreview()
    }
    
    // MARK: - ColorWell
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        colorWell.frame = CGRect(x: 0, y: 25, width: 50, height: 50)
    }
    
    @objc private func colorChanged() {
        sliderRed.value = Float((colorWell.selectedColor?.cgColor.components![0])! * 255.0)
        sliderGreen.value = Float((colorWell.selectedColor?.cgColor.components![1])! * 255.0)
        sliderBlue.value = Float((colorWell.selectedColor?.cgColor.components![2])! * 255.0)
        sliderOpacity.value = Float((colorWell.selectedColor?.cgColor.components![3])!)
        
        sliderOpacity.value = Float(opacity)
        labelOpacity.text = String(format: "%.1f", opacity)
        labelRed.text = Int(sliderRed.value).description
        labelGreen.text = Int(sliderGreen.value).description
        labelBlue.text = Int(sliderBlue.value).description
        
        red = (colorWell.selectedColor?.cgColor.components![0])!
        green = (colorWell.selectedColor?.cgColor.components![1])!
        blue = (colorWell.selectedColor?.cgColor.components![2])!
        opacity = (colorWell.selectedColor?.cgColor.components![3])!
        drawPreview()
    }
  
    // MARK: - Actions
    //Source : https://www.raywenderlich.com/5895-uikit-drawing-tutorial-how-to-make-a-simple-drawing-app 
  
    @IBAction func closePressed(_ sender: Any) {
        delegate?.settingsViewControllerFinished(self)
    }
  
    @IBAction func strokeChanged(_ sender: UISlider) {
        stroke = CGFloat(sender.value)
        labelStroke.text = String(format: "%.1f", stroke)
        drawPreview()
    }
  
    @IBAction func opacityChanged(_ sender: UISlider) {
        opacity = CGFloat(sender.value)
        labelOpacity.text = String(format: "%.1f", opacity)
        drawPreview()
    }
  
    @IBAction func colorChanged(_ sender: UISlider) {
        red = CGFloat(sliderRed.value / 255.0)
        labelRed.text = Int(sliderRed.value).description
        green = CGFloat(sliderGreen.value / 255.0)
        labelGreen.text = Int(sliderGreen.value).description
        blue = CGFloat(sliderBlue.value / 255.0)
        labelBlue.text = Int(sliderBlue.value).description
            
        drawPreview()
    }
    
    func drawPreview() {
        UIGraphicsBeginImageContext(previewImageView.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.setLineCap(.round)
        context.setLineWidth(stroke)
        context.setStrokeColor(UIColor(red: red,
                                     green: green,
                                     blue: blue,
                                     alpha: opacity).cgColor)
        context.move(to: CGPoint(x: 45, y: 45))
        context.addLine(to: CGPoint(x: 45, y: 45))
        context.strokePath()
        previewImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

}
