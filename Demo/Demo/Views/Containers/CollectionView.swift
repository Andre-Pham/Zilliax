//
//  CollectionView.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class CollectionView<Section: Hashable, ItemID: Hashable & Sendable>: UICollectionView {
    // MARK: Nested Types

    public typealias ReuseIdentifier = String
    public typealias SupplementaryViewKind = String
    public typealias RenderCell = (_ cell: UICollectionViewCell, _ id: ItemID) -> UICollectionViewCell?
    public typealias RenderReusableView = (_ reusableView: UICollectionReusableView, _ section: Section) -> UICollectionReusableView?

    // MARK: Properties

    /// The collection view data source
    private var data: UICollectionViewDiffableDataSource<Section, ItemID>? = nil
    /// Sections, mapped to reuse identifiers, mapped to render closures
    private var renders = [Section: [ReuseIdentifier: RenderCell]]()
    /// Supplementary view kinds, mapped to reuse identifiers, mapped to render closures
    private var supplementaryRenders = [SupplementaryViewKind: [ReuseIdentifier: RenderReusableView]]()

    // MARK: Lifecycle

    public init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        self.setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    // MARK: Functions

    @discardableResult
    public func setLayout(to layout: UICollectionViewLayout) -> Self {
        self.collectionViewLayout = layout
        return self
    }

    @discardableResult
    public func register<C: UIView>(
        _ view: C.Type,
        for sections: Section...,
        render: @escaping (_ view: C, _ id: ItemID) -> Void
    ) -> Self {
        let cellClass = CollectionViewCell<C>.self
        self.register(cellClass.self, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
        for section in sections {
            if self.renders[section] == nil {
                self.renders[section] = [:]
            }
            self.renders[section]![cellClass.reuseIdentifier] = { anyCell, id in
                guard let typed = anyCell as? CollectionViewCell<C> else {
                    return nil
                }
                render(typed.view, id)
                return typed
            }
        }
        return self
    }

    @discardableResult
    public func register<C: UIView>(
        _ view: C.Type,
        kind: SupplementaryViewKind,
        render: @escaping (_ view: C, _ section: Section) -> Void
    ) -> Self {
        let reusableViewClass = CollectionReusableView<C>.self
        self.register(reusableViewClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: reusableViewClass.reuseIdentifier)
        if self.supplementaryRenders[kind] == nil {
            self.supplementaryRenders[kind] = [:]
        }
        self.supplementaryRenders[kind]![reusableViewClass.reuseIdentifier] = { reusableView, section in
            guard let typed = reusableView as? CollectionReusableView<C> else {
                return nil
            }
            render(typed.view, section)
            return typed
        }
        return self
    }

    @discardableResult
    public func configureDataSource() -> Self {
        self.data = UICollectionViewDiffableDataSource<Section, ItemID>(
            collectionView: self
        ) { [weak self] collectionView, indexPath, id in
            guard let self, let data = self.data else {
                return nil
            }
            let section = data.snapshot().sectionIdentifiers[indexPath.section]
            guard let reuseIdentifiers = self.renders[section]?.keys else {
                return nil
            }
            for reuseIdentifier in reuseIdentifiers {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: reuseIdentifier,
                    for: indexPath
                )
                if let render = self.renders[section]?[reuseIdentifier],
                   let rendered = render(cell, id) {
                    return rendered
                }
            }
            assertionFailure("Could not render cell for section: \(section)")
            return nil
        }
        self.data?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self, let data = self.data else {
                return nil
            }
            let section = data.snapshot().sectionIdentifiers[indexPath.section]
            guard let reuseIdentifiers = self.supplementaryRenders[kind]?.keys else {
                return nil
            }
            for reuseIdentifier in reuseIdentifiers {
                let reusableView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: reuseIdentifier,
                    for: indexPath
                )
                if let render = self.supplementaryRenders[kind]?[reuseIdentifier],
                   let rendered = render(reusableView, section) {
                    return rendered
                }
            }
            return nil
        }
        return self
    }

    @discardableResult
    public func render(_ toRender: (section: Section, items: [ItemID])..., animate: Bool) -> Self {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemID>()
        snapshot.appendSections(Array(toRender.map(\.section)))
        for sectionItems in toRender {
            snapshot.appendItems(sectionItems.items, toSection: sectionItems.section)
        }
        assert(self.data != nil, "Attempted to render before configuring the data source")
        self.data?.apply(snapshot, animatingDifferences: animate)
        return self
    }

    @discardableResult
    public func render(
        _ toRender: (section: Section, items: [ItemID])...,
        reloadItems: [ItemID] = [],
        reloadSections: [Section] = [],
        animate: Bool
    ) -> Self {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemID>()
        snapshot.appendSections(toRender.map(\.section))
        for (section, items) in toRender {
            snapshot.appendItems(items, toSection: section)
        }
        if !reloadItems.isEmpty {
            // `reloadItems` causes an opacity animation which is undesired
            snapshot.reconfigureItems(reloadItems)
        }
        if !reloadSections.isEmpty {
            snapshot.reloadSections(reloadSections)
        }
        assert(self.data != nil, "Attempted to render before configuring the data source")
        self.data?.apply(snapshot, animatingDifferences: animate)
        return self
    }

    @discardableResult
    public func setVerticalBounce(to state: Bool) -> Self {
        self.alwaysBounceVertical = state
        return self
    }

    @discardableResult
    public func setHorizontalBounce(to state: Bool) -> Self {
        self.alwaysBounceHorizontal = state
        return self
    }

    private func setup() {
        self.useAutoLayout()
            .setBackgroundColor(to: .clear)
    }
}

private class CollectionReusableView<T>: UICollectionReusableView where T: UIView {
    // MARK: Static Computed Properties

    public static var reuseIdentifier: String {
        return String(describing: type(of: T.self))
    }

    // MARK: Properties

    public let view: T

    // MARK: Lifecycle

    public override init(frame: CGRect) {
        self.view = T()
        super.init(frame: frame)
        self.setup()
    }

    public required init?(coder: NSCoder) {
        self.view = T()
        super.init(coder: coder)
        self.setup()
    }

    // MARK: Functions

    private func setup() {
        self.view
            .addAsSubview(of: self)
            .constrainAllSides()
    }
}

private class CollectionViewCell<T>: UICollectionViewCell where T: UIView {
    // MARK: Static Computed Properties

    public static var reuseIdentifier: String {
        return String(describing: type(of: T.self))
    }

    // MARK: Properties

    public let view: T

    // MARK: Lifecycle

    public override init(frame: CGRect) {
        self.view = T()
        super.init(frame: frame)
        self.setup()
    }

    public required init?(coder: NSCoder) {
        self.view = T()
        super.init(coder: coder)
        self.setup()
    }

    // MARK: Functions

    private func setup() {
        self.view
            .addAsSubview(of: self.contentView)
            .constrainAllSides()
    }
}
