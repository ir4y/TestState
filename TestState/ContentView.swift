//
//  ContentView.swift
//  TestState
//
//  Created by Ilya Beda on 08.07.2022.
//

import SwiftUI

typealias State = [String: Value]

enum Value {
    case string(String)
    case number(Int32)
    case state(State)
}

func formatValue(v: Value) -> String {
    switch v {
    case .number(let n):
        return String(n)
    case .string(let s):
        return s
    case .state(let state):
        var result = "{"
        state.forEach { (key, value) in
            result = result + key + ":" + formatValue(v: value) + ","
        }
        return result + "}";
    }
}

class DictModel: ObservableObject {
    @Published var dict: State = [:]
    
    func bind(path:[String]) -> Binding<String>{
        return Binding<String>(get: {
            let val = getByPath(state: self.dict, path: path);
                switch val {
                    case .string(let s):
                    return s;
                default:
                    return "";
                }
        }, set: {
            setByPath(state: &self.dict, path:path, newValue: Value.string($0))
                
        })
    }
}

func getByPath(state: State, path:[String]) -> Value? {
    if(path.count == 0){
        return nil
    }
    if(path.count == 1){
        return state[path.first!]
    }
    let value = state[path.first!]
    switch value {
        case .state(let state):
            return getByPath(state: state, path: Array(path.dropFirst()))
        default:
            return nil
    }
}

 func setByPath(state: inout State, path:[String], newValue: Value) -> Value? {
    if(path.count == 0){
        return nil
    }
    if(path.count == 1){
        state[path.first!] = newValue
        return Value.state(state)
    }
    let value = state[path.first!]
    switch value {
        case .state(var valState):
            let res = setByPath(state: &valState,
                                path: Array(path.dropFirst()),
                                newValue: newValue)
            state[path.first!] = res
        default:
            var newState:State = [:]
            let res = setByPath(state: &newState,
                      path: Array(path.dropFirst()),
                      newValue: newValue)
            state[path.first!] = res
            return  Value.state(newState)
    }
     return nil
}


struct ContentView: View {
    @ObservedObject var vm = DictModel()

    var body: some View {
        VStack {
            TextField("First name",
                      text: vm.bind(path: ["firstName"]))
            TextField("Last name",
                      text: vm.bind(path: ["lastName"]))
            TextField("nicotine use",
                      text: vm.bind(path: ["nicotine", "use"]))
            Divider()
            Button("Reset") { self.vm.dict = ["nicotine":Value.state(["use":Value.string("No")])] }
            Text(formatValue(v: Value.state(self.vm.dict)))
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
