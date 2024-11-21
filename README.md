# AdaptiveLayout

The AdaptiveLayout package provides a single eponymous macro. Apply the macro to any SwiftUI view that must show different subviews for different size classes or dynamic type sizes. 

## Examples: heightClass and widthClass

```
    var body: some View {
        let AStack = self.heightClass == .compact
            ? AnyLayout(HStackLayout())
            : AnyLayout(VStackLayout())
        AStack { ... }
    }
```

```
    var body: some View {
        Group { ... }                            
        .frame(maxWidth: self.heightClass == .compact
            ? 200 : .infinity)
    }
```

The **heightClass** and **widthClass** properties are useful for phone landscape orientation. When your screen has roughly equal top and bottom areas in portrait, an easy solution is to put those side by side in landscape. It can be useful to "invent" such a division. Lists, for example, can look stretched in landscape. Moving buttons and other elements to the right can maintain list proportions.  

## Examples: useTabletLayout
```
    var body: some View {
        Text(self.title)
            .lineLimit(self.useTabletLayout ? 3 : 2)
    }
```

```
    private var welcomeText: String {
        if self.useTabletLayout {
            return self.largeText
        }
        return self.normalText
    }
```

The **useTabletLayout** property helps decide when to show additional content. On a tablet, you don't really need to worry about landscape orientation. SwiftUI layouts are so flexible and easy - and tablet portrait dimensions so similar to landscape - that the same layout will probably work. But! The tablet dimensions are much larger than the phone. A list that looks fine on phone portrait will look stretched and have a great deal of wasted space on tablet.

So to use that space and save the user some taps, you can squeeze in another screen of content. Maybe use side-by-side navigation for tablets. Or show larger but lower priority content such as images in the larger format. 

## Examples: dynamicTypeSize
```
    private var columnWidth: CGFloat {
        if self.typeSize >= .accessibility3 {
            return self.useTabletLayout ? 160.0 : 120.0
        return self.useTabletLayout ? 100.0 : 60.0
    }
```

```
    private var searchTitle: String {
        self.typeSize > .accessibility1 ? "Find" : "Search"
    }
```

The **dynamicTypeSize** helps with the enormous difference in available space due to type size. The largest accessiblity sizes leave room for little more than a few characters on phone portrait. But the smallest accessbility sizes will squeeze a paragraph into a tiny corner of a tablet. I see *no way* to show the exact same content in all ranges. As with phone landscape and tablets, content must be adjusted, with lower priority content hidden in larger text sizes.

## Installation

Add the package to your project and target with apple's instructions on [adding package dependencies](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app). The url of the package is https://github.com/dave-ruest/AdaptiveLayout . Then just add @AdaptiveLayout to any view that needs custom large screen behavior, and use the added **useTabletLayout** property to add that support.  

## Discussion

### Why use a derived flag to detect larger screens?

The short answer is that I just tried my Bookmind app on mac catalyst and it looked... wrong. 

There was just so much space! The book grid didn't look too bad, but the author list was awful. The rows stretched across that wide screen with 60% unused space. Both list and grid would easily squeeze down to make space for another screen. This would show the user much more of their content, and save them multiple taps. 

I did try NavigationSplitView, but there were a few appearance issues. The first column was only 1/4 with and collapsible, and there weren't obvious workarounds for either. The bit where you use a navigation stack as the content view is brilliant. But if I have to do that work myself anyway, can't I just do that with a stack view? Same amount of work, and I get the appearance I **really** wanted.

Stay tuned, this could go several ways. The macro could be just enough to switch between a few layout specific views. But if a split view replacement is easily extracted from the change, I'll definitely add it to the adaptive layout package. Or maybe it all goes so far sideways that I spend another week getting the split view to work. 

### Why a macro?

I *do not force* the latest toys into my code. I strongly believe you should use the right tool for the job. You may be excited about your new hammer, but that doesn't mean you should use it to pull weeds or prune branches. If the job at hand isn't the right fit, I've seen over and over that the result is usually messy. But!

The problem here is that we have a property derived from the horizontal size class environment variable. It's just a few lines of code really. But just enough that it feels wrong to copy it into the 3-6 places we need it. What if we need to tweak the accessor for tvOS? 

Inheritance is right out, views are structs. Composition, my go-to move, wouldn't have access to the view's environment variables. We could pass the variable in to another object, but just adding the size class environment variable is half of the boilerplate. I think a property wrapper could add the implementation of the useTabletLayout property, but would also need the environment variable. A view modifier can add both properties, but how would you simply and easily access the useTabletLayout property? I did also try another environment variable for useTabletLayout, but it was tricky to get the value to update. It would be so much easier if each view could derive the value itself.

So yes, as the apple videos inform us, this is almost exactly the purpose of macros. There is definitely ramp up time getting the macro and swift package working. It was very, very tempting to just copy the two properties 5-6 times. I doubt I'll recover the time invested myself. But! If even a few of you find this package useful, it will be time well spent. 
