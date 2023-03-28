// 1)
import Foundation

// 2)
public protocol HTTPClient {
  // 3)
  typealias ResponseResult = Result<Data, Error>
  // 4)
  func get(_ url: URL?, responseHandler: @escaping (ResponseResult) -> Void)
}
