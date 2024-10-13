// The Swift Programming Language
// https://docs.swift.org/swift-book

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
@attached(member, names: named(widthClass), named(useTabletLayout))
public macro AdaptiveLayout() = #externalMacro(module: "AdaptiveLayoutMacros", type: "AdaptiveLayoutMacro")
