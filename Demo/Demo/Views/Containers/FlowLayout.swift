//
//  FlowLayout.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class FlowLayout: View {
    // MARK: Nested Types

    public typealias Direction = DIFlowLayoutEngine.Direction
    public typealias HorizontalAlignment = DIFlowLayoutEngine.HorizontalAlignment
    public typealias VerticalAlignment = DIFlowLayoutEngine.VerticalAlignment

    // MARK: Overridden Properties

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: self.lastFittingHeight)
    }

    // MARK: Properties

    private var engine = DIFlowLayoutEngine()
    private var arrangedViews = [UIView]()
    private var lastFittingHeight: CGFloat = 0

    // MARK: Computed Properties

    public var viewCount: Int {
        return self.arrangedViews.count
    }

    // MARK: Overridden Functions

    public override func layoutSubviews() {
        super.layoutSubviews()
        guard !self.arrangedViews.isEmpty else {
            if !self.lastFittingHeight.isZero() {
                self.lastFittingHeight = 0
                self.invalidateIntrinsicContentSize()
            }
            return
        }
        // Measure subviews
        let rects: [DIFlowLayoutEngine.Rectangle] = self.arrangedViews.map({ view in
            let size = self.measureSize(of: view)
            return DIFlowLayoutEngine.Rectangle(x: 0, y: 0, width: size.width, height: size.height)
        })
        // Measure self
        let boundsRect = DIFlowLayoutEngine.Rectangle(
            x: 0,
            y: 0,
            width: self.bounds.width,
            height: self.bounds.height
        )
        // Apply positions via frames
        let layout = self.engine.position(of: rects, in: boundsRect)
        for (index, position) in layout.positions.enumerated() {
            let view = self.arrangedViews[index]
            let size = rects[index]
            view.frame = CGRect(
                x: position.x,
                y: position.y,
                width: size.width,
                height: size.height
            )
        }
        self.lastFittingHeight = layout.fittingHeight
        self.invalidateIntrinsicContentSize()
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let width = size.width.isFinite ? size.width : self.bounds.width
        let rects: [DIFlowLayoutEngine.Rectangle] = self.arrangedViews.map({ view in
            let size = self.measureSize(of: view)
            return DIFlowLayoutEngine.Rectangle(x: 0, y: 0, width: size.width, height: size.height)
        })
        let boundsRect = DIFlowLayoutEngine.Rectangle(x: 0, y: 0, width: width, height: .zero)
        let layout = self.engine.position(of: rects, in: boundsRect)
        return CGSize(width: width, height: layout.fittingHeight)
    }

    public override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        let width: CGFloat = if horizontalFittingPriority == .required, targetSize.width.isFinite {
            targetSize.width
        } else {
            self.bounds.width
        }
        let measured = self.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: measured.height)
    }

    // MARK: Functions

    @discardableResult
    public func setDirection(to direction: Direction) -> Self {
        self.engine.direction = direction
        self.setNeedsLayout()
        return self
    }

    @discardableResult
    public func setHorizontalAlignment(to alignment: HorizontalAlignment) -> Self {
        self.engine.horizontalAlignment = alignment
        self.setNeedsLayout()
        return self
    }

    @discardableResult
    public func setVerticalAlignment(to alignment: VerticalAlignment) -> Self {
        self.engine.verticalAlignment = alignment
        self.setNeedsLayout()
        return self
    }

    @discardableResult
    public func setHorizontalSpacing(to spacing: Double) -> Self {
        self.engine.horizontalSpacing = spacing
        self.setNeedsLayout()
        return self
    }

    @discardableResult
    public func setVerticalSpacing(to spacing: Double) -> Self {
        self.engine.verticalSpacing = spacing
        self.setNeedsLayout()
        return self
    }

    @discardableResult
    public func setSpacing(to spacing: Double) -> Self {
        self.engine.verticalSpacing = spacing
        self.engine.horizontalSpacing = spacing
        self.setNeedsLayout()
        return self
    }

    @discardableResult
    public func append(_ view: UIView) -> Self {
        self.add(view)
        self.setNeedsLayout()
        self.arrangedViews.append(view)
        return self
    }

    @discardableResult
    public func appendMany(_ views: [UIView]) -> Self {
        for view in views {
            self.add(view)
        }
        self.setNeedsLayout()
        self.arrangedViews.append(contentsOf: views)
        return self
    }

    @discardableResult
    public func insert(_ view: UIView, at position: Int) -> Self {
        let validPosition = max(min(position, self.arrangedViews.count), 0)
        self.insertSubview(view, at: validPosition)
        self.setNeedsLayout()
        self.arrangedViews.insert(view, at: validPosition)
        return self
    }

    @discardableResult
    public func pop(_ view: UIView) -> Self {
        guard let index = self.arrangedViews.firstIndex(of: view) else {
            return self
        }
        view.remove()
        self.setNeedsLayout()
        self.arrangedViews.remove(at: index)
        return self
    }

    @discardableResult
    public func pop(position: Int? = nil) -> Self {
        let count = self.arrangedViews.count
        guard count > 0 else {
            return self
        }
        let last = count - 1
        let index = position ?? last
        guard index >= 0, index <= last else {
            return self
        }
        let view = self.arrangedViews[index]
        return self.pop(view)
    }

    private func measureSize(of view: UIView) -> CGSize {
        var size = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if size.width.isLessOrEqualZero() || size.height.isLessOrEqualZero() {
            size = view.contentBasedSize
        }
        return size
    }
}

//
// DIFlowLayoutEngine
// https://github.com/danielinoa/DIFlowLayoutEngine
//
// All source code licensed under the MIT License.
//

/// This engine computes the positions of items within a containing bound adopting a flow layout,
/// where items are arranged horizontally and wrapped vertically.
public struct DIFlowLayoutEngine {
    // MARK: Nested Types

    public struct Layout {
        /// The height require to fit all items, based on the width of the bounds originally passed in.
        public let fittingHeight: Double
        /// The position of the items within fitting height and the bounds' width.
        public let positions: [Position]
    }

    /// The direction items flow within a row.
    public enum Direction {
        /// In this direction items flow from left to right.
        case forward
        /// In this direction items flow from right to left.
        case reverse
    }

    /// The horizontal alignment of items within a row.
    public enum HorizontalAlignment {
        case leading, center, trailing
    }

    /// The vertical alignment of items within a row.
    public enum VerticalAlignment {
        case top, center, bottom
    }

    public struct Position: Equatable {
        public var x: Double
        public var y: Double
    }

    public struct Rectangle: Equatable {
        // MARK: Properties

        public var x: Double
        public var y: Double
        public var width: Double
        public var height: Double

        // MARK: Computed Properties

        public var minY: Double {
            return self.y
        }

        public var minX: Double {
            return self.x
        }

        public var maxX: Double {
            return self.width + self.x
        }

        // MARK: Lifecycle

        public init(x: Double, y: Double, width: Double, height: Double) {
            self.x = x
            self.y = y
            self.width = width
            self.height = height
        }
    }

    private struct Row {
        public var items = [Rectangle]()
        /// The offset from the container-bounds' min-y (not necessarily zero).
        public var topOffset = Double.zero
        /// The height of the row, based on the tallest item within the row.
        public var height = Double.zero
        /// The sum of all the items' widths. This does not include any interim spacing.
        public var totalItemsWidth = Double.zero
    }

    // MARK: Properties

    /// The direction items flow within a row.
    public var direction: Direction

    /// The horizontal alignment of items within a row.
    public var horizontalAlignment: HorizontalAlignment

    /// The vertical alignment of items within a row.
    public var verticalAlignment: VerticalAlignment

    /// The horizontal distance between adjacent items within a row.
    public var horizontalSpacing: Double

    /// The vertical distance between adjacent rows.
    public var verticalSpacing: Double

    // MARK: Lifecycle

    public init(
        direction: Direction = .forward,
        horizontalAlignment: HorizontalAlignment = .leading,
        verticalAlignment: VerticalAlignment = .center,
        horizontalSpacing: Double = .zero,
        verticalSpacing: Double = .zero
    ) {
        self.direction = direction
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }

    // MARK: Functions

    /// Returns the positions of the items within the specified bounds,
    /// and the height require to fit all items within the bounds.
    public func position(of items: [Rectangle], in bounds: Rectangle) -> Layout {
        let (rows, fittingHeight) = self.rows(
            from: items,
            in: bounds,
            horizontalSpacing: self.horizontalSpacing,
            verticalSpacing: self.verticalSpacing
        )
        var positions = [Position]()
        for row in rows {
            let itemPositions = self.positions(for: row, in: bounds)
            positions.append(contentsOf: itemPositions)
        }
        return .init(fittingHeight: fittingHeight, positions: positions)
    }

    private func positions(for row: Row, in bounds: Rectangle) -> [Position] {
        // Implementation (when direction is .reverse):
        // A-B-C items will be reversed to C-B-A, positions will be calculated based on the items' size,
        // and resulting positions will be reversed so that they match the corresponding items from original array.
        let items = self.direction == .forward ? row.items : row.items.reversed()
        var positions = [Position]()
        var leadingOffset = self.initialLeadingOffset(
            for: row,
            in: bounds,
            alignment: self.horizontalAlignment,
            horizontalSpacing: self.horizontalSpacing
        )
        for item in items {
            let topOffset = self.topOffset(for: item, aligned: self.verticalAlignment, within: row)
            positions.append(.init(x: leadingOffset, y: topOffset))
            leadingOffset += item.width + self.horizontalSpacing
        }
        if self.direction == .reverse {
            // Reverse once again so the positions' array-index match with the corresponding forwarded items.
            positions.reverse()
        }
        return positions
    }

    /// This function groups items into rows based on the available width defined by the bounds
    /// and the specified spacing.
    private func rows(
        from items: [Rectangle],
        in bounds: Rectangle,
        horizontalSpacing: Double,
        verticalSpacing: Double
    ) -> (rows: [Row], fittingHeight: Double) {
        var items = items
        var rows = [Row]()
        while !items.isEmpty {
            let topOffset = rows.last.map { $0.topOffset + $0.height + verticalSpacing } ?? bounds.minY
            var row = Row(topOffset: topOffset)
            var isOverflown = false
            var leadingOffset = bounds.minX
            while !isOverflown, !items.isEmpty {
                let item = items.removeFirst()
                row.items.append(item)
                row.totalItemsWidth += item.width
                row.height = max(row.height, item.height)
                let nextItem = items.first
                leadingOffset += item.width + horizontalSpacing
                isOverflown = nextItem.map { (leadingOffset + $0.width) > bounds.maxX } ?? false
            }
            rows.append(row)
        }
        let verticalGapsCount = rows.count > 1 ? rows.count - 1 : .zero
        let fittingHeight = rows.map(\.height).reduce(.zero, +) + (Double(verticalGapsCount) * verticalSpacing)
        return (rows, fittingHeight)
    }

    private func topOffset(for item: Rectangle, aligned: VerticalAlignment, within row: Row) -> Double {
        let shift: Double = switch aligned {
        case .top: .zero
        case .center: (row.height - item.height) / 2
        case .bottom: row.height - item.height
        }
        return row.topOffset + shift
    }

    /// Returns the leading offset the row's first item can be placed in.
    private func initialLeadingOffset(
        for row: Row,
        in bounds: Rectangle,
        alignment: HorizontalAlignment,
        horizontalSpacing: Double
    ) -> Double {
        let gaps: Int = row.items.count == 1 ? .zero : row.items.count - 1
        let gapsWidth = Double(gaps) * horizontalSpacing
        let remainingSpace = bounds.width - (row.totalItemsWidth + gapsWidth)
        let shift: Double = switch alignment {
        case .leading: .zero
        case .center: remainingSpace / 2
        case .trailing: remainingSpace
        }
        return bounds.minX + shift
    }
}
