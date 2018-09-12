import Nimble
import XCTest

final class ToSucceedTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (ToSucceedTest) -> () throws -> Void)] {
        return [
            ("testToSucceed", testToSucceed),
        ]
    }

    func testToSucceed() {
        expect({
            .succeeded
        }).to(succeed())

        expect({
            .failed(reason: "")
        }).toNot(succeed())

        failsWithErrorMessageForNil("expected a closure, got <nil>") {
            expect(nil as (() -> ToSucceedResult)?).to(succeed())
        }

        failsWithErrorMessage("expected to succeed, got <failed> because <something went wrong>") {
            expect({
                .failed(reason: "something went wrong")
            }).to(succeed())
        }

        failsWithErrorMessage("expected to not succeed, got <succeeded>") {
            expect({
                .succeeded
            }).toNot(succeed())
        }
    }
}
