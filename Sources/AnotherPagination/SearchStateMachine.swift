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

/// Receives Actions and Emits states. See `SearchStateMachineAction`,
/// `BaseState` and `SearchStateMachineState` for more info.
///
/// `SearchStateMachine` is thread safe
///
/// #Example
/// ~~~
/// let machine = SearchStateMachine<User, UserQuery, AppError> { (page, query)
///    // Your network/database call
///    return userService.read(page: page, with: query)
/// }
///
/// machine.state.sink { [weak machine, collectionView, dataSource]
///    switch $0 {
///    case .uninitialized:
///        machine?.send(action: .refresh)
///
///    case .refreshing:
///        collectionView?.backgroundView = RefreshingView()
///
///    case .errorRefreshing(let error):
///        collectionView?.backgroundView = ErrorRefreshingView(error)
///
///    case .loadingMoreData:
///        collectionView?.showLoadingMoreData()
///
///    case .errorLoadingMoreData(let error):
///        collectionView?.showErrorLoadingMoreData(error)
///
///    case .noData:
///        collectionView?.backgroundView = EmptyDataView()
///
///    case .data(let data):
///        // Using UICollectionViewDiffableDataSource, but could use the data normal datasources
///        if let var snapshot = dataSource?.snapshot() {
///           snapshot.appendItems(data, toSection: .dataSection)
///           dataSource.apply(snapshot, animatingDifferences: true)
///        }
///    }
///
/// }.store(in: &cancellables)
///~~~
public class SearchStateMachine<Element, Query, Failure: Error> {
    
    private let log: OSLog
    private let stateMachineName: String
    
    private let stateMachineQueue: DispatchQueue
    private var currentState: BaseState<Element, Query, Failure>
    private var stateCancellable: AnyCancellable?
    
    @Published
    private var _state: SearchStateMachineState<Element, Failure> = .uninitialized
    
    /// The state of the machine can be observed to change the UI according the current state
    public var state: Published<SearchStateMachineState<Element, Failure>>.Publisher {
        return $_state
    }
    
    /// Builds a ready to use state machine to preload your data in a pagination style
    /// - Parameters:
    ///   - log: the OSLog to be used, `default` to OSLog.default
    ///   - stateMachineName: the ValueCache name to appear in the logs, `default`to  the classe name string
    ///   - stateMachineQueueName: the `DispatchQueue` name
    ///   - dataProvider: the closure to produce the data
    public init(
        log: OSLog = .default,
        stateMachineName: String = String(describing: SearchStateMachine.self),
        stateMachineQueueName: String,
        dataProvider: @escaping SearchDataProvider<Element, Query, Failure>
    ) {
        self.log = log
        self.stateMachineName = stateMachineName
        self.stateMachineQueue = DispatchQueue(label: stateMachineQueueName)
        
        let stateChanger = PassthroughSubject<StateMachineChange<Element, Query, Failure>, Never>()
        
        currentState = InitialState<Element, Query, Failure>(
            log: log,
            stateMachineName: stateMachineName,
            stateChanger: stateChanger,
            stateMachineQueue: stateMachineQueue,
            dataProvider: dataProvider
        )
        
        stateCancellable = stateChanger
            .receive(on: stateMachineQueue)
            .sink { [weak self] data in self?.updateState(data: data) }
    }
    
}

// MARK: - Action Handling
extension SearchStateMachine {
    
    /// Sends a action to the state machine to be executed if the pre-conditions are meet
    /// - Parameter action: the action to be sent
    public func send(action: SearchStateMachineAction<Query>) {
        stateMachineQueue.async { [weak self] in self?.doSend(action: action) }
    }
    
    private func doSend(action: SearchStateMachineAction<Query>) {
        switch action {
        case .refresh(let query):
            os_log(.debug, log: log, "[%s] Going to try to refresh", stateMachineName)
            currentState.refresh(query: query)
            
        case .preload(let index):
            os_log(.debug, log: log, "[%s] Going to try to preload %d", stateMachineName, index)
            currentState.preload(index: index)
            
        case .retry:
            os_log(.debug, log: log, "[%s] Going to try to retry", stateMachineName)
            currentState.retry()
        }
    }
    
}

// MARK: State Handling
extension SearchStateMachine {
    
    private func updateState(data: StateMachineChange<Element, Query, Failure>) {
        if currentState === data.from {
            currentState = data.to
            
            os_log(.debug, log: log, "[%s] Changing from %s to %s",
                   stateMachineName,
                   data.from.debugDescription,
                   data.to.debugDescription)
        }
        
        _state = data.newState
    }
    
}
