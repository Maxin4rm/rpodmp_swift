import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Foundation

class MovieInfoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    	
    var movie: Movie?
    var images: [UIImage] = []
    var userKey: String = ""
    var isFavourite: Bool = false
    var ref: DatabaseReference!
    var favourites: [String] = []
    
    
    func displayError(errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getUserKey() {
        if let key = Auth.auth().currentUser?.uid{
            let favouritesRef = Database.database().reference().child("AuthorizedUsers/\(key)")
            favouritesRef.observe(.value, with: { snapshot in
                if let value = snapshot.value as? [String: Any] {
                    self.favourites = value["favorites"] as? [String] ?? []
                    self.isFavourite = self.favourites.contains(self.movie?.id ?? "")
                } else {
                    self.isFavourite = false
                }
                self.favouriteButton.setTitle(self.isFavourite ? "Remove from Favorites" : "Add to Favorites", for: .normal)
            })
        }
        
        
    }	

    func addToFavourites(movieId: String) {
        favourites.append(movieId)
        
        if let key = Auth.auth().currentUser?.uid{
            ref.child(key).child("favorites").setValue(favourites)
        }
        
    }
    
    func removeFromFavourites(movieId: String) {
        if let index = favourites.firstIndex(of: movieId) {
            favourites.remove(at: index)
        }
        
        if let key = Auth.auth().currentUser?.uid{
            ref.child(key).child("favorites").setValue(favourites)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = true;
        collectionView.delegate = self
        collectionView.dataSource = self
        
        ref = Database.database().reference().child("AuthorizedUsers")
        getUserKey()
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        descriptionLabel.text = movie.description

        for url in movie.images {
            downloadImage(from: URL(string: url)!) { image in
                self.images.append(image!)
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
        
    }

    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            completion(UIImage(data: data))
        }.resume()
    }
    
    @IBAction func favouriteButtonTapped(_ sender: Any) {
        if isFavourite {
            self.favouriteButton.setTitle("Add to favorites", for: .normal)
            self.removeFromFavourites(movieId: movie!.id)
        } else {
            self.favouriteButton.setTitle("Remove from favorites", for: .normal)
            self.addToFavourites(movieId: movie!.id)
        }
        isFavourite = !isFavourite
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? DataCollectionViewCell
        cell?.image.image = images[indexPath.row]
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
