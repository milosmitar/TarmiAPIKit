//
//  File.swift
//  
//
//  Created by ITSUser on 5.4.23..
//

import Foundation

public class HTTPClient{
   public static let sharedInstance = HTTPClient()
    
   public func executeRequest<T: Decodable>(url: String ,body: Data,tokenNeeded: Bool,parameters: [String: String]? = [:],model: T.Type,completion: @escaping(Result<T?, NetworkError>) -> Void){
        
      guard  var components = URLComponents(string: url) else {
          return completion(.failure(.badURL))
      }

    
    
    if let params = parameters {
          components.queryItems = params.map { (key, value) in
              URLQueryItem(name: key, value: value)
          }
          components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")

    }
    var request = URLRequest(url: components.url!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    
    if !body.isEmpty {
        request.httpBody = body
        let dataString = String(NSString(data: body, encoding: NSUTF8StringEncoding) ?? "")
        print(dataString)
    }
        URLSession.shared.dataTask(with: request) { data, response, error in
//            let dataString = String(NSString(data: data ?? Data(), encoding: NSUTF8StringEncoding) ?? "")
//                            print(dataString)
            guard let data = data, error == nil else {
                return completion(.failure(.noData))
            }
            do{
                let genericModel: T = try JSONDecoder().decode(T.self, from: data)
                completion(.success(genericModel))
            }  catch let DecodingError.keyNotFound(key, context) {
                completion(.failure(.decodingError))
                print("Key '\(key)' not found:", context.debugDescription.description)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                completion(.failure(.decodingError))
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                completion(.failure(.decodingError))
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
                
            }
            
            catch let DecodingError.dataCorrupted(context) {
                completion(.failure(.decodingError))
                print(context)
            }
            catch {
                print("error: ", error.localizedDescription)
            }
            
            //            guard  let genericModel: T = try? JSONDecoder().decode(T.self, from: data) else{
            //                }
            //                return completion(.failure(.decodingError))
        }.resume()
        
        
    }
}

