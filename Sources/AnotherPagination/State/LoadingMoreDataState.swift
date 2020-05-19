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
import Foundation
import Combine
import os

/// `LoadingMoreDataState` represents the state when a error occurs loading more data
/// # It can go to:
/// - `ErrorLoadingMoreDataState`
/// - `DataLoadedState`
/// - `RefreshingState`
class LoadingMoreDataState<Element, Query, Failure: Error>: BaseState<Element, Query, Failure> {
    
    private let query: Query?
    private var currentRequest: AnyCancellable?
    private let currentPageIndex: Int
    private let currentElementsCount: Int
    
    override var debugDescription: String {
        return "LoadingMoreDataState"
    }
    
    init(
        query: Query?,
        currentPageIndex: Int,
        currentElementsCount: Int,
        from state: BaseState<Element, Query, Failure>
    ) {
        self.query = query
        self.currentPageIndex = currentPageIndex
        self.currentElementsCount = currentElementsCount
        super.init(from: state)
    }
    
    func doPreload() {
        let nextPage = currentPageIndex + 1
        os_log(.debug, log: log, "[%s][%s] Going to preload next page %d",
               stateMachineName,
               debugDescription,
               nextPage)
        
        currentRequest = execute(query: query, for: nextPage) { [weak self] result in
            self?.process(result: result, nextPageIndex: nextPage)
        }
    }
    
    private func process(result: Result<SearchDataResult<Element>, Failure>, nextPageIndex: Int) {
        switch result {
        case .success(let dataResult):
            os_log(.debug, log: log, "[%s][%s] Received total of elements %d and nextpage %d",
                   stateMachineName,
                   debugDescription,
                   dataResult.results.count,
                   dataResult.hasNextPage)
            
            let newState = DataLoadedState<Element, Query, Failure>(
                query: query,
                hasNextPage: dataResult.hasNextPage,
                currentPageIndex: nextPageIndex,
                currentElementsCount: currentElementsCount + dataResult.results.count,
                from: self
            )
            change(to: newState, with: .data(dataResult.results))
            
        case .failure(let error):
            os_log(.error, log: log, "[%s][%s] Received error %s",
                   stateMachineName,
                   debugDescription,
                   error.localizedDescription)
            
            let newState = ErrorLoadingMoreDataState<Element, Query, Failure>(
                query: query,
                currentPageIndex: currentPageIndex,
                currentElementsCount: currentElementsCount,
                error: error,
                from: self
            )
            change(to: newState, with: .errorLoadingMoreData(error))
        }
    }
    
}

