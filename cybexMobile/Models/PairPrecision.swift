//
//  PairPrecision.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

// MARK: - PairPrecision
struct PairPrecision: Codable {
    let info: Info
    var book: Book
    let choose: Choose
    let form: Form
}

// MARK: PairPrecision convenience initializers and mutators

extension PairPrecision {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PairPrecision.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        info: Info? = nil,
        book: Book? = nil,
        choose: Choose? = nil,
        form: Form? = nil
        ) -> PairPrecision {
        return PairPrecision(
            info: info ?? self.info,
            book: book ?? self.book,
            choose: choose ?? self.choose,
            form: form ?? self.form
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Book
struct Book: Codable {
    var lastPrice: String
    var amount: String
    var total: String

}

// MARK: Book convenience initializers and mutators

extension Book {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Book.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        lastPrice: String? = nil,
        amount: String? = nil,
        total: String? = nil
        ) -> Book {
        return Book(
            lastPrice: lastPrice ?? self.lastPrice,
            amount: amount ?? self.amount,
            total: total ?? self.total
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Choose
struct Choose: Codable {
    let lastPrice: String
    let volume: String
}

// MARK: Choose convenience initializers and mutators

extension Choose {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Choose.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        lastPrice: String? = nil,
        volume: String? = nil
        ) -> Choose {
        return Choose(
            lastPrice: lastPrice ?? self.lastPrice,
            volume: volume ?? self.volume
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Form
struct Form: Codable {
    let minTradeAmount: String
    let amountStep: String
    let priceStep: String
    let minOrderValue: String
    let totalStep: String

}

// MARK: Form convenience initializers and mutators

extension Form {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Form.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        minTradeAmount: String? = nil,
        amountStep: String? = nil,
        priceStep: String? = nil,
        minOrderValue: String? = nil,
        totalStep: String? = nil
        ) -> Form {
        return Form(
            minTradeAmount: minTradeAmount ?? self.minTradeAmount,
            amountStep: amountStep ?? self.amountStep,
            priceStep: priceStep ?? self.priceStep,
            minOrderValue: minOrderValue ?? self.minOrderValue,
            totalStep: totalStep ?? self.totalStep
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Info
struct Info: Codable {
    let lastPrice: String
    let change: String
    let volume: String
}

// MARK: Info convenience initializers and mutators

extension Info {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Info.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        lastPrice: String? = nil,
        change: String? = nil,
        volume: String? = nil
        ) -> Info {
        return Info(
            lastPrice: lastPrice ?? self.lastPrice,
            change: change ?? self.change,
            volume: volume ?? self.volume
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
