import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// AdaptiveLayout adds a useTabletLayout property to your view. Use this flag
/// to detect cases where there are 2-3 phone screens worth of space. So much
/// space that it feels wrong not to place 2-3 screens side by side, so the user
/// can see more of the app content.
///
/// This flag is useful mostly for apps that will run on ipad and mac catalyst as
/// well as iPhone. The app has only one screen on phone or ipad split screen, but
/// "too" much space on unsplit ipad or mac.
///
/// NavigationSplitView is a good first attempt - it does collapse in compact widths.
/// But is very limited. The first column is collapsible and cannot be larger than 1/3
/// width, and this is difficult (impossible?) to change. And you still have to
/// "manually" place a navigation stack view in the content area. Well, if we have
/// to do that anyway, it's not much more work to do it all ourselves.
///
/// So add this macro to any view that needs to customize its appearance for a
/// "tablet" amount of space. Add a half screen grid view beside your navigation
/// stack if you like, it's the same amount of work as the system split view, and
/// will give your app a unique look.
///
/// The macro also adds heightClass and dynamicTypeSize properties. Use heightClass
/// to detect phone landscape orientation and maybe switch to an HStack from a
/// VStack. Use dynamicTypeSize to detect the smaller and larger text sizes. Lower
/// priority content such as additional images can be shown in smaller sizes and
/// hidden in larger text sizes.
public struct AdaptiveLayoutMacro: MemberMacro {
    public static func expansion(
      of node: AttributeSyntax,
      providingMembersOf declaration: some DeclGroupSyntax,
      conformingTo protocols: [TypeSyntax],
      in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // TODO: check swift ui import? check view conformance?
        return [
            """
            /** The current horizontal size class. Most phones have compact horizontal
            size, as well as iPad apps when in split view. When not in split view, iPad
            apps have regular width. Some larger phones also have regular width in
            landscape orientation. Use this property to show different views for regular
            and compact sizes. */
            @Environment(\\.horizontalSizeClass) private var widthClass
            """,
            """
            /** The current vertical size class. Most phones have compact vertical
            size when in landscape orientation. Use this property to show different
            views for regular and compact sizes. One trick is to hide less important
            content in compact height; another is to switch an hstack to a vstack
            in compact height. */
            @Environment(\\.verticalSizeClass) private var heightClass
            """,
            """
            /** When true, useTabletLayout indicates the screen has room for 2-3 phone
            screens. A split or multi column view should be used to take advantage of
            the extra space. This is particularly useful for screens that will run on
            phone, ipad, ipad split view, and mac catalyst. */
            private var useTabletLayout: Bool {
                if self.widthClass == .compact { return false }
                return UIDevice.current.userInterfaceIdiom == .pad
            }
            """,
            """
            /** The current dynamic text size. There is no way to show the same amount
            of content at both the smallest and largest text sizes. You must scroll or
            reduce content at the largest size. Use this property to hide lower priority
            content at the higher type sizes. */
            @Environment(\\.dynamicTypeSize) private var typeSize
            """
        ]
    }
}

@main
struct AdaptiveLayoutPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AdaptiveLayoutMacro.self,
    ]
}
