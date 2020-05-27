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

import Combine
import Foundation
import os

/// `RefreshingState` represents the state when the state machine is refreshing it's data aka 'the first request'
/// # It can go to:
/// - `RefreshingState`
/// - `RefreshErrorState`
/// - `NoDataState`
/// - `DataLoadedState`
class RefreshingState<Element, Query, Failure: Error>: BaseState<Element, Query, Failure> {
    
    private let query: Query?
    private var currentRequest: AnyCancellable?
    
    override var debugDescription: String {
        return "RefreshingState"
    }
    
    init(query: Query?, from state: BaseState<Element, Query, Failure>) {
        self.query = query
        super.init(from: state)
    }
    
    func doRefresh() {
        os_log(.debug, log: log, "[%s][%s] Going to refresh", stateMachineName, debugDescription)
        
        currentRequest = execute(query: query, for: 1) { [weak self] result in
            self?.process(result: result)
        }
    }
    
    private func process(result: Result<SearchDataResult<Element>, Failure>) {
        switch result {
        case .success(let dataResult):
            os_log(.debug, log: log, "[%s][%s] Received total of elements %d and nextpage %d",
                   stateMachineName,
                   debugDescription,
                   dataResult.results.count,
                   dataResult.hasNextPage)
            
            guard !dataResult.results.isEmpty else {
                let newState = NoDataState<Element, Query, Failure>(from: self)
                change(to: newState, with: .noData(query: query))
                return
            }
            
            let newState = DataLoadedState<Element, Query, Failure>(
                query: query,
                hasNextPage: dataResult.hasNextPage,
                currentPageIndex: 1,
                currentElementsCount: dataResult.results.count,
                from: self
            )
            change(to: newState, with: .data(dataResult.results))
            
        case .failure(let error):
            os_log(.error, log: log, "[%s][%s] Received error %s",
                   stateMachineName,
                   debugDescription,
                   error.localizedDescription)
            
            let newState = RefreshingErrorState<Element, Query, Failure>(
                error: error,
                from: self
            )
            change(to: newState, with: .errorRefreshing(error))
        }
    }
    
}


