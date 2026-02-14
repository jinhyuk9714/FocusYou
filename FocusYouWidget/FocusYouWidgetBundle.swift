import WidgetKit
import SwiftUI

@main
struct FocusYouWidgetBundle: WidgetBundle {
    var body: some Widget {
        FocusStatusWidget()
        StreakWidget()
    }
}
