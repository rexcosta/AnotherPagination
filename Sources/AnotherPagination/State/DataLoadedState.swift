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

/// `DataLoadedState` represents the state that there is data ready to use
/// # It can go to:
/// - `RefreshingState`
/// - `LoadingMoreDataState`
class DataLoadedState<Element, Query, Failure: Error>: BaseState<Element, Query, Failure> {
    
    private let query: Query?
    private let hasNextPage: Bool
    private let currentPageIndex: Int
    private let currentElementsCount: Int
    
    override var debugDescription: String {
        return "DataLoadedState"
    }
    
    init(
        query: Query?,
        hasNextPage: Bool,
        currentPageIndex: Int,
        currentElementsCount: Int,
        from state: BaseState<Element, Query, Failure>
    ) {
        self.query = query
        self.hasNextPage = hasNextPage
        self.currentPageIndex = currentPageIndex
        self.currentElementsCount = currentElementsCount
        super.init(from: state)
    }
    
    override func preload(index: Int) {
        guard hasNextPage else {
            return
        }
        guard index > (currentElementsCount - 5) else {
            return
        }
        
        let newState = LoadingMoreDataState<Element, Query, Failure>(
            query: query,
            currentPageIndex: currentPageIndex,
            currentElementsCount: currentElementsCount,
            from: self
        )
        change(to: newState, with: .loadingMoreData) {
            newState.doPreload()
        }
    }
    
}
