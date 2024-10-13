import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(AdaptiveLayoutMacros)
import AdaptiveLayoutMacros

let testMacros: [String: Macro.Type] = [
    "AdaptiveLayout": AdaptiveLayoutMacro.self,
]
#endif

final class AdaptiveLayoutTests: XCTestCase {
    func testMacro() throws {
        #if canImport(AdaptiveLayoutMacros)
        assertMacroExpansion(
            """
            @AdaptiveLayout
            struct MyView {
            }
            """, 
            expandedSource:
            """
            struct MyView {

                /** The current horiztonal size class. Most phones have compact horiztonal
                size, as well as iPad apps when in split view. When not in split view, iPad
                apps have regulear width. Some larger phones also have regular width in
                landscape orientation. Use this property in in your view when you will show
                different views for regular and compact sizes. */
                @Environment(\\.horizontalSizeClass) private var widthClass

                /** When true, useTabletLayout indicates the screen has room for 2-3 phone
                screens. A split or multi column view should be used to take advantage of
                the extra space. This is particularly useful for screens that will run on
                phone, ipad, ipad split view, and mac catalyst. */
                private var useTabletLayout: Bool {
                    if self.widthClass == .compact {
                        return false
                    }
                    return UIDevice.current.userInterfaceIdiom == .pad
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
