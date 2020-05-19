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

/// `RefreshErrorState` represents the state when a error occurs while refreshing the data for the first time
/// # It can go to:
/// - `RefreshingState`
class RefreshingErrorState<Element, Query, Failure: Error>: BaseState<Element, Query, Failure> {
    
    private let error: Failure
    
    override var debugDescription: String {
        return "RefreshingErrorState"
    }
    
    init(error: Failure, from state: BaseState<Element, Query, Failure>) {
        self.error = error
        super.init(from: state)
    }
    
}

