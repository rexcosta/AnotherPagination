//
// The MIT License (MIT)
//
// Copyright (c) 2020 Effective Like ABoss, David Costa Gonçalves
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import AnotherSwiftCommonLib
import Combine

/// Closure typealias for the state machine data provider
/// - Parameters:
///   - page: the page being requested
///   - query: the quey to execute for the given page
/// - Returns: the data result for the page being requested
public typealias SearchDataProvider<Element, Query, Failure: Error> = (_ page: Int, _ query: Query?) -> AnyPublisher<SearchDataResult<Element>, Failure>


/// Representation of a page result
/// It contains the resulting elements and a flag to indicate if a next page is available
public struct SearchDataResult<Element> {
    
    public let hasNextPage: Bool
    public let results: [Element]
    
    public init(hasNextPage: Bool, results: [Element]) {
        self.hasNextPage = hasNextPage
        self.results = results
    }
    
    /// Makes a result with no elements and no next page
    /// - Returns: empty page
    public static func empty() -> SearchDataResult {
        return SearchDataResult(hasNextPage: false, results: [Element]())
    }
    
}
