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

import Foundation

/// The SearchStateMachine outputs the current state for the state machine.
/// You can use this to adapt the UI according the state.
///
/// Possible transitions:
/// * `uninitialized`-> `refreshing`
///
/// * `refreshing`-> `errorRefreshing`
/// * `refreshing`-> `noData`
/// * `refreshing`-> `data`
///
/// * `data` -> `loadingMoreData`
///
/// * `loadingMoreData` -> `errorLoadingMoreData`
/// * `loadingMoreData` -> `data`
///
public enum SearchStateMachineState<Element, Query, Failure> {
    
    /// The state machine didn't received any action and did process anything
    case uninitialized
    
    /// The state machine received the refresh action
    case refreshing
    
    /// The state machine refresh process ended with error
    case errorRefreshing(_ error: Failure)
    
    /// The state machine is loading another page
    case loadingMoreData
    
    /// The state machine loading another page ended with an error
    case errorLoadingMoreData(_ error: Failure)
    
    /// The state machine don't have any data
    case noData(query: Query?)
    
    /// The state machine received another page
    case data(_ data: [Element])
    
}
