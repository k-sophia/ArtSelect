//
//  ImageViewController.swift
//  ArtSelect
//
//  Created by Kelly Camacho on 5/5/22.
//

import UIKit
import CoreData
import AudioToolbox

protocol ImagesViewControllerDelegate: AnyObject {
    func ImageIsSelected(
        _ imagesViewController: ImageViewController
    )
}

struct APIResponse: Codable {
    let total: Int!
    let total_pages: Int!
    let results: [Result]!
}

struct Result: Codable {
    let id: String!
    let urls: URLS!
}

struct URLS: Codable {
    let regular: String!
}

class ImageViewController: UIViewController {
    private var collectionView: UICollectionView?
    var results: [Result] = []
    let searchbar = UISearchBar()
    var soundID: SystemSoundID = 0
    var selectIMG: UIImage? = nil

    var managedObjectContext: NSManagedObjectContext!
    weak var delegate: ImagesViewControllerDelegate?
    
    // MARK: - Subviews
    // Source : https://www.youtube.com/watch?v=IQ4jh4EfVOM&t=1789s
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        loadSoundEffect("selectImage.wav")

        searchbar.delegate = self
        view.addSubview(searchbar)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(
            width: view.frame.size.width/2,
            height: view.frame.size.width/2)

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout)
        collectionView.register(
            imageCell.self,
            forCellWithReuseIdentifier: imageCell.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)

        collectionView.backgroundColor = UIColor(red: 220/255, green: 202/255, blue: 232/255, alpha: 1)
        self.collectionView = collectionView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let textAttributes = [NSAttributedString.Key.foregroundColor:
                                UIColor(red: 251/255, green: 233/255, blue: 215/255, alpha: 1)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes

        searchbar.frame = CGRect(
            x: 10,
            y: view.safeAreaInsets.top,
            width: view.frame.size.width - 20,
            height: 50)
        searchbar.placeholder = "Search for an image"
        collectionView?.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top+55,
            width: view.frame.size.width,
            height: view.frame.size.height-55-self.navigationController!.navigationBar.frame.size.height)
    }
    
    // MARK: - Navigation

    @IBAction func reset() {
        results = []
        collectionView?.reloadData()
        searchbar.text = nil
    }

    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Sound effects
    func loadSoundEffect(_ name: String) {
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            let fileURL = URL(fileURLWithPath: path, isDirectory: false)
            let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
            if error != kAudioServicesNoError {
                print("Error code \(error) loading sound: \(path)")
            }
        }
    }
    
    func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
    }
    
    func playSoundEffect() {
        AudioServicesPlaySystemSound(soundID)
    }

}

// MARK: - Search Bar Delegate
extension ImageViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchbar.text {
            results = []
            collectionView?.reloadData()
            fetchPhotos(query: text)
        }
    }

    func fetchPhotos(query: String) {
        let urlString = "https://api.unsplash.com/search/photos?page=1&per_page=30&query=\(query)&client_id=R1bykOIVd5HM2MFSi7G9R5HimVft_mHsVjSrwSuedZM"

        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let jsonResult = try JSONDecoder().decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.results = jsonResult.results
                    self?.collectionView?.reloadData()
                }
            }
            catch {
                print(error)
            }
        }.resume()
    }
}

// MARK: - Collection View Delegate
extension ImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return results.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let imageURLString = results[indexPath.row].urls.regular!

        guard let cell = collectionView.dequeueReusableCell (
            withReuseIdentifier: imageCell.identifier,
            for: indexPath
        ) as? imageCell
        else {
            return UICollectionViewCell()
        }
        cell.configure(with: imageURLString)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        self.playSoundEffect()
        
        collectionView.deselectItem(at: indexPath, animated: true)
        let imageURLString = results[indexPath.row].urls.regular!

        guard let url = URL(string: imageURLString) else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data , error == nil else {
                return
            }
            DispatchQueue.main.async {
                self.selectIMG = UIImage(data: data)
                self.delegate?.ImageIsSelected(self)
                self.navigationController?.popViewController(animated: true)
            }
        }.resume()

    }
}


