//
//  APIService.swift
//  MovieApp
//
//  Created by Daegeon Choi on 2022/01/11.
//

import Foundation
import RxSwift

class APIService {
    
    static func configureUrlString(category: MovieListCategory, language: Language, page: Int) -> String {
        return "https://api.themoviedb.org/3/movie/\(category.key)?api_key=\(APIKey)&language=\(language.key)&page=\(page)"
    }
    
    static func configureUrlString(id: Int, language: Language) -> String {
        return "https://api.themoviedb.org/3/movie/\(id)?api_key=\(APIKey)&language=\(language)"
    }
    
    static func configureUrlString(imagePath: String?) -> String? {
        guard let imagePath else { return nil }
        return "https://image.tmdb.org/t/p/original/\(imagePath)"
    }
    
    static func configureUrlString(keyword: String, language: Language, page: Int) -> String {
        return "https://api.themoviedb.org/3/search/movie?query=\(keyword)&api_key=\(APIKey)&language=\(language.key)&page=\(page)"
    }
    
    
    static func fetchRequest(url: String, retries: Int, onComplete: @escaping (Result<Data, Error>) -> Void) {
        
        guard let Url = URL(string: url) else {
            print("Error: invalid url")
            return
        }
        
        let task = URLSession(configuration: .default).dataTask(with: Url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                onComplete(.failure(error))
                return
            }
            
            guard let safeData = data else {
                guard let httpResponse = response as? HTTPURLResponse else { return }
                print("Error: no data")
                onComplete(.failure(NSError(domain: "no data", code: httpResponse.statusCode, userInfo: nil)))
                return
            }
            onComplete(.success(safeData))
            
        }
        task.resume()
    }
}

//MARK: Rx
extension APIService {
    
    static func fetchWithRx(url: String, retries: Int) -> Observable<Data> {
        return Observable.create { emitter in
            
            fetchRequest(url: url, retries: retries) { result in
                switch result {
                case .success(let data):
                    emitter.onNext(data)
                    emitter.onCompleted()
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
}

extension String {
    var fullImagePath: String {
        return "https://image.tmdb.org/t/p/original/\(self)"
    }
}


//MARK: - Enumerations for API url configuration
enum MovieListCategory {
    case Popular, Upcomming, TopRated, NowPlaying
    
    var key: String {
        switch self{
        case .Popular: return "popular"
        case .Upcomming: return "upcomming"
        case .TopRated: return "top_rated"
        case .NowPlaying: return "now_playing"
        }
    }
    
    var title: String {
        switch self{
        case .Popular: return "Popular"
        case .Upcomming: return "Upcomming"
        case .TopRated: return "Top Rated"
        case .NowPlaying: return "Now Playing"
        }
    }
}

enum Language {
    case Korean, English
    
    var key: String {
        switch self{
        case .Korean: return "ko-KR"
        case .English: return "en-US"
        }
    }
}
