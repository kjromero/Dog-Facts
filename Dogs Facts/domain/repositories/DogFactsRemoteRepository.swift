import Foundation

final internal class DogFactsRemoteRepository: DogFactsRepository {
  private let httpClient: HTTPClient
  private let api: DogFactsAPI
  private let executionQueue: DispatchQueue
  
  internal init(
    httpClient: HTTPClient,
    api: DogFactsAPI,
    executionQueue: DispatchQueue = .main
  ) {
    self.httpClient = httpClient
    self.api = api
    self.executionQueue = executionQueue
  }
  
  // MARK: - DogFactsRepository
  func getRandomFact(handler: @escaping (DogFactResult) -> Void) {
    httpClient.get(api.factsURL) { [unowned self] result in
      self.execute {
        switch result {
        case .success(let data):
          if let dto = Self.parse(type: DogFactDTO.self, data: data) {
            handler(.success(dto.toData))
          } else {
            handler(.failure(.notParsable(data)))
          }
        case .failure(let error):
          handler(.failure(.fetchError(error)))
        }
      }
    }
  }
  
  // MARK: - Helpers
  private func execute(action: @escaping () -> Void) {
    executionQueue.async(execute: action)
  }
  
  private static func parse<T: Decodable>(type: T.Type, data: Data) -> T? {
    return try? JSONDecoder().decode(T.self, from: data)
  }
}

fileprivate extension DogFactDTO {
    var toData: DogFactData {
        return DogFactData(
            factMessage: facts.reduce(into: "", { $0.append(contentsOf: $1) })
        )
    }
}
