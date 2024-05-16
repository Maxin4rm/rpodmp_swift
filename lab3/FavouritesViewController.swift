import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class FavouritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: DatabaseReference!
    var movies: [Movie] = []
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        let movie = movies[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(movie.title)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMovie = movies[indexPath.row]
        performSegue(withIdentifier: "showMovieInfoFromFavourites", sender: selectedMovie)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMovieInfoFromFavourites",
           let destinationVC = segue.destination as? MovieInfoViewController,
           let movie = sender as? Movie {
            destinationVC.movie = movie
        }
    }
    
    func observeFavourites() {
        if let key = Auth.auth().currentUser?.uid{
            let favouritesRef = Database.database().reference().child("AuthorizedUsers/\(key)/favorites")
            favouritesRef.observe(.value, with: { snapshot in
                var favouriteIds: [String] = []
                for child in snapshot.children {
                    if let childSnapshot = child as? DataSnapshot,
                       let favouriteId = childSnapshot.value as? String {
                        favouriteIds.append(favouriteId)
                    }
                }
                self.loadMovies(with: favouriteIds)
            })
        }
    }
    
    func loadMovies(with ids: [String]) {
        let moviesRef = Database.database().reference().child("Movies")
        movies = []
        for id in ids {
            moviesRef.child(id).observeSingleEvent(of: .value, with: { snapshot in
                if let value = snapshot.value as? [String: Any] {
                    let id = snapshot.key as? String
                    let title = value["title"] as? String
                    let description = value["description"] as? String
                    let images = value["images"] as? [String] ?? []
                    let movie = Movie(id: id!, title: title!, description: description!, images: images);
                    self.movies.append(movie);
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        observeFavourites()
    }
}
