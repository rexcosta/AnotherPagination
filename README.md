# AnotherPagination

AnotherPagination is just a simple helper to facilitate the use of paginated collections. Under the hood it's build using the state machine pattern.

## SearchStateMachine

`SearchStateMachine` receives actions and emits states, it's also thread safe.

```swift
let machine = SearchStateMachine<User, UserQuery, AppError> { (page, query)
    // Your network/database call
    return userService.read(page: page, with: query)
}

machine.state.sink { [weak machine, collectionView, dataSource]
    switch $0 {
    case .uninitialized:
        machine?.send(action: .refresh)

    case .refreshing:
        collectionView?.backgroundView = RefreshingView()

    case .errorRefreshing(let error):
        collectionView?.backgroundView = ErrorRefreshingView(error)

    case .loadingMoreData:
        collectionView?.showLoadingMoreData()

    case .errorLoadingMoreData(let error):
        collectionView?.showErrorLoadingMoreData(error)

    case .noData:
       collectionView?.backgroundView = EmptyDataView()

    case .data(let data):
        // Using UICollectionViewDiffableDataSource, 
        // but could use the data normal datasources
        if let var snapshot = dataSource?.snapshot() {
           snapshot.appendItems(data, toSection: .dataSection)
           dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}.store(in: &cancellables)
```

## BaseState

The `SearchStateMachine` uses `BaseState` implementations. 

The `BaseState` can trigger async state changes to the `SearchStateMachine`,

### Possible transitions:
* `InitialState` -> `RefreshingState`
* `RefreshingState` -> `RefreshingState`
* `RefreshingState` -> `RefreshErrorState`
* `RefreshingState` -> `NoDataState`
* `RefreshingState` -> `DataLoadedState`
* `RefreshErrorState` -> `RefreshingState`
* `NoDataState` -> `RefreshingState`
* `DataLoadedState` -> `RefreshingState`
* `DataLoadedState` -> `LoadingMoreDataState`
* `LoadingMoreDataState` -> `ErrorLoadingMoreDataState`
* `LoadingMoreDataState` -> `DataLoadedState`
* `LoadingMoreDataState` -> `RefreshingState`
* `ErrorLoadingMoreDataState` -> `LoadingMoreDataState`
* `ErrorLoadingMoreDataState` -> `RefreshingState`

# SearchDataProvider

Closure typealias for the state machine data provider, use this to do your network/database requests. The provider returns a `SearchDataResult`.
* `SearchDataResult` represents a page result. It contains the resulting elements and a flag to indicate if a next page is available.

# SearchStateMachineAction
Represents an action to be executed inside the state machine

## Actions

* refresh(query: Query? = nil)
  * Attempts to refresh the state machine with the given query
* preload(index: Int)
  * Attempts to preload the next page by using the current
index to determine if the next page should be loaded.
  * Example
    * For a page size of 20 items, and the user is seing the 16 item preload will activate the next page
    * For a page size of 20 items, and the user is seing the 10 item preload will not activate the next page   
  * Reference [UICollectionViewDataSourcePrefetching](https://developer.apple.com/documentation/uikit/uicollectionviewdatasourceprefetching/prefetching_collection_view_data)
* retry
  * Attempts to retry the previous state

# SearchStateMachineState
The SearchStateMachine outputs the current state for the state machine.
You can use this to adapt the UI according the state.

## States

* uninitialized
  * The state machine didn't received any action and didn't process anything
* refreshing
  * The state machine received the refresh action, and it's requesting the first page
* errorRefreshing(_ error: Failure)
  * The state machine refresh process ended with error
* loadingMoreData
  * The state machine is loading another page
* errorLoadingMoreData(_ error: Failure)
  * The state machine loading another page ended with an error
* noData
  * The state machine don't have any data
* data(_ data: [Element])
  * The state machine received another page


## Possible state transitions:
* `uninitialized`-> `refreshing`
* `refreshing`-> `errorRefreshing`
* `refreshing`-> `noData`
* `refreshing`-> `data`
* `data` -> `loadingMoreData`
* `loadingMoreData` -> `errorLoadingMoreData`
* `loadingMoreData` -> `data`
