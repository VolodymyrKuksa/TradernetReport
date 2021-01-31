//
//  APIKeyStorage.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 31/01/21.
//

import Foundation


class APIKeyStorage: ObservableObject {
    @Published public var selectedIdentifiers = Set<ObjectIdentifier>()
    @Published public var keys: [APIKey]
    
    public var selectedKeys: [APIKey] {
        keys.filter { selectedIdentifiers.contains($0.id) }
    }
    
    public var selectedKey: APIKey? {
        let selected = selectedKeys
        return selected.count == 1 ? selected[0] : nil
    }
    
    init(keys: [APIKey]) {
        self.keys = keys
    }
}
