//
//  Loadable.swift
//  SwiftVN
//
//  Created by Kru on 28/09/24.
//

protocol Loadable {
    static var hasLoaded: Bool { get set }
    func loadHandler()
}

extension Loadable {
    func tryLoad() {
        // Ensure loadHandler is called once per class
        if !Self.hasLoaded {
            loadHandler()
            Self.hasLoaded = true
        }
    }
}
