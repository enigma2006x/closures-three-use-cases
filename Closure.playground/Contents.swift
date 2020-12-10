import PlaygroundSupport
import UIKit
import os.log

enum NewtorkError: Error {
    case noData
}

struct AsyncOperation {
    
    // Service response: ["Hello", "World!!", "Service"]
    func networkRequest(completion: @escaping (Result<[String], Error>) -> Void) {
        
        guard let url = URL(string: "https://api.mocki.io/v1/7759e394") else {
            fatalError("Could not be created the url")
        }
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: URLRequest(url: url)) { (data, response, error) in
            
            guard let data = data else {
                return completion(.failure(NewtorkError.noData))
            }
            
            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode([String].self, from: data)
                DispatchQueue.main.async {
                    /// Back on the main queue.
                    completion(.success(result))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func asyncSortArray(_ array: [Int], completion: @escaping (([Int]) -> Void)) {
        let concurrentQueue = DispatchQueue(label: "tonydev.concurrent.queue", attributes: .concurrent)

        concurrentQueue.async {
            let result = array.sorted()
            DispatchQueue.main.async {
                /// Back on the main queue.
                completion(result)
            }
        }
    }
    
    func appendString(_ string: String, completion: @escaping ((String) -> Void)) {
        
        var result = [String]()
        let group = DispatchGroup()
          
        group.enter()
        DispatchQueue.main.async {
            result.append("Async")
            group.leave()
        }
        
        group.enter()
        DispatchQueue.main.async {
            result.append("Hello")
            group.leave()
        }
        
        group.enter()
        DispatchQueue.main.async {
            result.append(string)
            group.leave()
        }

        /// Back on the main queue.
        group.notify(queue: DispatchQueue.main) {
            completion(result.joined(separator: " "))
        }
    }
    
}

struct Operation {

    func syncTask(completion:() -> Void) {
        
        // Some work done here
        completion() // Callback execution
    }
    
    func sortArray(_ array: [Int], completion:([Int]) -> Void) {
        
        // Sorted here
        let result = array.sorted()
        completion(result) // Callback execution
    }
    
    func appendString(_ string: String, completion:(String) -> Void) {
        var result = [String]()
        result.append("Sync")
        result.append("Hello")
        result.append(string)
        completion(result.joined(separator: " ")) // Callback execution
    }
}

struct OperationHandler {
    
    private let operation = AsyncOperation()
    
    var completionString: ((String) -> Void)?
    
    var completionResult: ((Result<[String], Error>) -> Void)?
    
    var completionSort: (([Int]) -> Void)?
    
    func networkRequest() {
    
        operation.networkRequest { (result) in
            completionResult?(result)
        }
    }
    
    func sortArray(_ array: [Int]) {
        
        operation.asyncSortArray(array) { (result) in
            completionSort?(result)
        }
    }

    func appendString(_ string: String) {
    
        operation.appendString("World!!") { (result) in
            completionString?(result)
        }
    }
}

final class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAsyncClosures()
        setSyncClosures()
        setClosuresUsingProperties()
    }
    
    func setAsyncClosures() {
        let asyncOperation = AsyncOperation()
        
        asyncOperation.appendString("World!!") { (result) in
            print(result)
        }
        
        asyncOperation.asyncSortArray([90, 5, 1, 87, 54]) { (result) in
            print(result)
        }
        
        asyncOperation.networkRequest { (response) in
            switch response {
            case .success(let result):
                print(result)
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    func setSyncClosures() {
        let operation = Operation()
        operation.syncTask(completion: {
            print("Sync callback done")
        })
        
        // Using trailing closure
        operation.sortArray([90, 5, 1, 87, 54]) { (intArray) in
            print(intArray)
        }
        
        // Using trailing closure
        operation.appendString("World!!") { (result) in
            print(result)
        }
    }
    
    func setClosuresUsingProperties() {
        var handler = OperationHandler()
        handler.completionResult = { result in
            print(result)
        }
        
        handler.networkRequest()
        
        handler.completionSort = { result in
            print(result)
        }
        
        handler.sortArray([90, 5, 1, 87, 54])
        
        handler.completionString = { result in
            print(result)
        }
        
        handler.appendString("World!!")
        
    }
}

PlaygroundPage.current.liveView = ViewController()
