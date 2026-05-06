import Foundation
final class ProfileImageService {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private init() {}
    
    private let urlSession = URLSession.shared
    private let storage = OAuth2TokenStorage.shared
    private var task: URLSessionTask?
    private var lastUsername: String?
    
    private(set) var avatarURL: String?
    
    struct UserResult: Codable {
        let profileImage: ProfileImage
        
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }
    struct ProfileImage: Codable {
        let small: String
    }
    
    func fetchProfileImageURL(username: String, _ completion : @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        
        if lastUsername == username {return}
        
        task?.cancel()
        lastUsername = username
        
        guard let token = storage.token else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        
        guard let request = makeRequest(username:username, token: token) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let userResult):
                let profileImageURL = userResult.profileImage.small
                self.avatarURL = profileImageURL
                completion(.success(profileImageURL))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": profileImageURL]
                )
                
            case .failure(let error):
                print("[ProfileImageService]: Error - \(error.localizedDescription) для пользователя \(username)")
                self.lastUsername = nil
                completion(.failure(error))
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
        
    }
    
    private func makeRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
