//
//  ViewsViewController.swift
//  Demo
//

import UIKit

public class ViewsViewController: UIViewController {
    // MARK: Properties

    private let scroll = Scroll()
    private let stack = VStack()

    private let views: [String: UIViewController] = [
        "Button": ButtonViewController(),
        "CapsuleButton": CapsuleButtonViewController(),
        "Card": CardViewController(),
        "CollectionView": CollectionViewViewController(),
        "FlowLayout": FlowLayoutViewController(),
        "HStack": HStackViewController(),
        "ClearableTextField": ClearableTextFieldViewController(),
        "Control": ControlViewController(),
        "Icon": IconViewController(),
        "IconButton": IconButtonViewController(),
        "IconImage": IconImageViewController(),
        "Image": ImageViewController(),
        "PanGesture": PanGestureViewController(),
        "Pill": PillViewController(),
        "PillButton": PillButtonViewController(),
        "PillMultiselect": PillMultiselectViewController(),
        "PillSelect": PillSelectViewController(),
        "PillToggle": PillToggleViewController(),
        "PillX": PillXViewController(),
        "ProgressBar": ProgressBarViewController(),
        "Scroll": ScrollViewController(),
        "SegmentedControl": SegmentedControlViewController(),
        "SegmentedSlider": SegmentedSliderViewController(),
        "Slider": SliderViewController(),
        "Spinner": SpinnerViewController(),
        "Stepper": StepperViewController(),
        "TabBarButton": TabBarButtonViewController(),
        "Text": TextViewController(),
        "TextField": TextFieldViewController(),
        "Toggle": ToggleViewController(),
        "VStack": VStackViewController(),
        "View": ViewViewController(),
    ]

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.setBackgroundColor(to: Colors.fillForeground)

        self.view
            .add(self.scroll)

        self.scroll
            .constrainAllSides()
            .setVerticalBounce(to: true)
            .append(self.stack)

        self.stack
            .constrainVertical(padding: Dimensions.screenContentPaddingVertical, toContentLayoutGuide: true)
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .appendGap(size: DeviceContext.deviceType == .phone ? 0 : 24)

        for (name, viewController) in self.views.sorted(by: { $0.key < $1.key }) {
            let toAppend = OpenView()
                .setText(to: name)
                .setOnTap({
                    guard let nav = self.navigationController else {
                        assertionFailure("Expected navigation controller")
                        return
                    }
                    nav.pushViewController(viewController, animated: true)
                })

            self.stack.append(toAppend)
        }
    }
}
