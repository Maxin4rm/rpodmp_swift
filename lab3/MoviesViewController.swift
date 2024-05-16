import UIKit
import FirebaseDatabase

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
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
        performSegue(withIdentifier: "showMovieInfoFromMovies", sender: selectedMovie)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMovieInfoFromMovies",
           let destinationVC = segue.destination as? MovieInfoViewController,
           let movie = sender as? Movie {
            destinationVC.movie = movie
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        ref = Database.database().reference()
        ref.child("Movies").observe(.value, with: { snapshot in
            self.movies = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let value = snapshot.value as? [String: Any] {
                    let id = snapshot.key as? String
                    let title = value["title"] as? String
                    let description = value["description"] as? String
                    let images = value["images"] as? [String] ?? []
                    let movie = Movie(id: id!, title: title!,
                        description: description!,
                        images: images);
                    self.movies.append(movie);
                }
            }
             DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
}
