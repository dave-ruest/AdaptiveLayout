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

                /** The current horizontal size class. Most phones have compact horizontal
                size, as well as iPad apps when in split view. When not in split view, iPad
                apps have regular width. Some larger phones also have regular width in
                landscape orientation. Use this property to show different views for regular
                and compact sizes. */
                @Environment(\\.horizontalSizeClass) private var widthClass
            
                /** The current vertical size class. Most phones have compact vertical
                size when in landscape orientation. Use this property to show different
                views for regular and compact sizes. One trick is to hide less important
                content in compact height; another is to switch an hstack to a vstack
                in compact height. */
                @Environment(\\.verticalSizeClass) private var heightClass

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
            
                /** The current dynamic text size. There is no way to show the same amount
                of content at both the smallest and largest text sizes. You must scroll or
                reduce content at the largest size. Use this property to hide lower priority
                content at the higher type sizes. */
                @Environment(\\.dynamicTypeSize) private var typeSize
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
