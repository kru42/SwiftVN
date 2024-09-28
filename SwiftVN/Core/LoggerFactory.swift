//
//  LoggerFactory.swift
//  SwiftVN
//
//  Created by Kru on 28/09/24.
//

import Logging

struct LoggerFactory {
    static let shared: Logger = {
        var logger = Logger(label: "SwiftVN")
        logger.logLevel = .debug
        return logger
    }()
}
