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
import Foundation
import os

/// The `SearchStateMachine` uses `BaseState` implementations
/// The `BaseState` can trigger async state changes to the `SearchStateMachine`, and the machine can actually decide if this state changes can be accepted
///
/// # Possible transitions:
/// * `InitialState` -> `RefreshingState`
///
/// * `RefreshingState` -> `RefreshingState`
/// * `RefreshingState` -> `RefreshErrorState`
/// * `RefreshingState` -> `NoDataState`
/// * `RefreshingState` -> `DataLoadedState`
///
/// * `RefreshErrorState` -> `RefreshingState`
///
/// * `NoDataState` -> `RefreshingState`
///
/// * `DataLoadedState` -> `RefreshingState`
/// * `DataLoadedState` -> `LoadingMoreDataState`
///
/// * `LoadingMoreDataState` -> `ErrorLoadingMoreDataState`
/// * `LoadingMoreDataState` -> `DataLoadedState`
/// * `LoadingMoreDataState` -> `RefreshingState`
///
/// * `ErrorLoadingMoreDataState` -> `LoadingMoreDataState`
/// * `ErrorLoadingMoreDataState` -> `RefreshingState`
///
class BaseState<Element, Query, Failure: Error>: CustomDebugStringConvertible {
    
    let log: OSLog
    let stateMachineName: String
    
    private let stateMachineQueue: DispatchQueue
    private let dataProvider: SearchDataProvider<Element, Query, Failure>
    private let stateChanger: PassthroughSubject<StateMachineChange<Element, Query, Failure>, Never>
    
    var debugDescription: String {
        return "BaseState"
    }
    
    init(
        log: OSLog,
        stateMachineName: String,
        stateChanger: PassthroughSubject<StateMachineChange<Element, Query, Failure>, Never>,
        stateMachineQueue: DispatchQueue,
        dataProvider: @escaping SearchDataProvider<Element, Query, Failure>
    ) {
        self.log = log
        self.stateMachineName = stateMachineName
        self.stateChanger = stateChanger
        self.stateMachineQueue = stateMachineQueue
        self.dataProvider = dataProvider
    }
    
    init(from state: BaseState) {
        log = state.log
        stateMachineName = state.stateMachineName
        stateChanger = state.stateChanger
        stateMachineQueue = state.stateMachineQueue
        dataProvider = state.dataProvider
    }
    
    // MARK: - Interface
    func refresh(query: Query?) {
        let newState = RefreshingState<Element, Query, Failure>(
            query: query,
            from: self
        )
        
        change(to: newState, with: .refreshing) {
            newState.doRefresh()
        }
    }
    
    func preload(index: Int) { }
    
    func retry() { }
    
}

// MARK: - Helpers
extension BaseState {
    
    func change(to state: BaseState, with newState: SearchStateMachineState<Element, Failure>, completion: (() -> Void)? = nil) {
       let changeInfo = StateMachineChange(
            from: self,
            to: state,
            newState: newState
        )
        
        stateChanger.send(changeInfo)
        if let completion = completion {
            stateMachineQueue.async(execute: completion)
        }
    }
    
    func execute(
        query: Query?,
        for page: Int,
        completion: @escaping (_ result: Result<SearchDataResult<Element>, Failure>) -> Void
    ) -> AnyCancellable {
        return dataProvider(page, query)
            .receive(on: stateMachineQueue)
            .sinkToResult { completion($0) }
    }
    
}
