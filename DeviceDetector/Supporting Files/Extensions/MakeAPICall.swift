//
//  MakeAPICall.swift
//  DeviceDetector
//
//  Created by Bobby on 11/21/24.
//

import Foundation

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

extension BaseVC {
    func makeAPICall<T: Decodable>(
        path: String,
        method: HTTPMethod,
        parameters: [String: Any]? = nil,
        responseType: T.Type,
        showLoader: Bool = true,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        Task {
            await performAPICall(
                path: path,
                method: method,
                parameters: parameters,
                responseType: responseType,
                showLoader: showLoader,
                completion: completion
            )
        }
    }
    
    private func performAPICall<T: Decodable>(
        path: String,
        method: HTTPMethod,
        parameters: [String: Any]? = nil,
        responseType: T.Type,
        showLoader: Bool = true,
        completion: @escaping (Result<T, Error>) -> Void
    ) async {
        if showLoader {
            self.activityIndicator.startAnimating()
        }
        
        guard let request = buildRequest(path: path, method: method, parameters: parameters) else {
            if showLoader {
                self.activityIndicator.stopAnimating()
            }
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "No HTTP response"])
            }
            
            if showLoader {
                self.activityIndicator.stopAnimating()
            }
            
            switch httpResponse.statusCode {
            case 200..<300:
                handleSuccessResponse(data: data, responseType: responseType, completion: completion)
            case 401:
                await handleUnauthorized(
                    path: path,
                    method: method,
                    parameters: parameters,
                    responseType: responseType,
                    showLoader: showLoader, // Pass the flag for consistency
                    completion: completion
                )
            case 204:
                throw NSError(domain: "", code: 204, userInfo: [NSLocalizedDescriptionKey: "No data"])
            case 500:
                throw NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Internal server error"])
            default:
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(httpResponse.statusCode)"])
            }
        } catch {
            if showLoader {
                self.activityIndicator.stopAnimating()
            }
            completion(.failure(error))
        }
    }
    private func buildRequest(path: String, method: HTTPMethod, parameters: [String: Any]?) -> URLRequest? {
        let baseURL = SessionData.serverUrl
        guard var urlComponents = URLComponents(string: baseURL + path) else {
            return nil
        }
        
        if method == .GET, let parameters = parameters {
            urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        
        guard let url = urlComponents.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Set Authorization header
        if !SessionData.accessToken.isEmpty {
            request.setValue("Bearer \(SessionData.accessToken)", forHTTPHeaderField: "Authorization")
        } else if !SessionData.refreshToken.isEmpty {
            request.setValue("Bearer \(SessionData.refreshToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Add JSON body for non-GET methods
        if method != .GET, let parameters = parameters {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        }
        
        return request
    }
    
    private func handleSuccessResponse<T: Decodable>(
        data: Data,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        do {
            
            let decodedResponse = try JSONDecoder().decode(responseType, from: data)
            self.activityIndicator.stopAnimating()
            completion(.success(decodedResponse))
        } catch {
            self.activityIndicator.stopAnimating()
            completion(.failure(error))
        }
    }
    
    private func handleUnauthorized<T: Decodable>(
        path: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        responseType: T.Type,
        showLoader: Bool,
        completion: @escaping (Result<T, Error>) -> Void
    ) async {
        await refreshToken { result in
            switch result {
            case .success:
                Task {
                    await self.performAPICall(path: path, method: method, parameters: parameters, responseType: responseType, showLoader: showLoader, completion: completion)
                }
            case .failure(let error):
                if showLoader {
                    self.activityIndicator.stopAnimating()
                }
                self.goToVC(vc: EnterPhoneVC())
                completion(.failure(error))
            }
        }
    }
    
    private func refreshToken(completion: @escaping (Result<Void, Error>) -> Void) async {
        self.activityIndicator.startAnimating()
        let refreshTokenPath = "/refresh-token"
        
        guard let request = buildRequest(path: refreshTokenPath, method: .POST, parameters: nil) else {
            self.activityIndicator.stopAnimating()
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NSError(domain: "", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "Failed to refresh token"])
            }
            
            // Assume the response updates AppData.aToken (replace this logic as needed)
            self.activityIndicator.stopAnimating()
            completion(.success(()))
        } catch {
            self.activityIndicator.stopAnimating()
            completion(.failure(error))
        }
    }
}
