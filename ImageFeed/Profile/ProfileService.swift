import Foundation

final class ProfileService {
    
    // MARK: - Constants
    static let shared = ProfileService()
    
    // MARK: - Properties
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    private(set) var profile: Profile?
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Structs
    struct ProfileResult: Codable {
        let username: String
        let firstName: String?
        let lastName: String?
        let bio: String?
        
        enum CodingKeys: String, CodingKey {
            case username
            case firstName = "first_name"
            case lastName = "last_name"
            case bio
        }
    }
    
    struct Profile {
        let username: String
        let name: String
        let loginName: String
        let bio: String?
        
        init(result: ProfileResult) {
            self.username = result.username
            self.name = "\(result.firstName ?? "") \(result.lastName ?? "")".trimmingCharacters(in: .whitespaces)
            self.loginName = "@\(result.username)"
            self.bio = result.bio
        }
    }
    
    // MARK: - Public Methods
    
    func fetchProfile(_ token: String, completion: @escaping(Result<Profile,Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastToken != token else { return }
        task?.cancel()
        lastToken = token
        
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let profileResult):
                    let profile = Profile(result: profileResult)
                    self.profile = profile
                    completion(.success(profile))
                case .failure(let error):
                    print("[ProfileService]: Error - \(error.localizedDescription) для токена \(token.prefix(5))...")
                    self.lastToken = nil
                    completion(.failure(error))
                }
                
                self.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
    func clearProfileData() {
        profile = nil
        task?.cancel()
        lastToken = nil
    }
    
    // MARK: - Private Methods
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
