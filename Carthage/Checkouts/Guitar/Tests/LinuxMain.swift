import XCTest
@testable import GuitarTests

XCTMain([
    testCase(GuitarBooleanTests.allTests),
    testCase(GuitarCaseTests.allTests),
    testCase(GuitarCharacterTests.allTests),
    testCase(GuitarPaddingTests.allTests),
    testCase(GuitarTests.allTests),
])
