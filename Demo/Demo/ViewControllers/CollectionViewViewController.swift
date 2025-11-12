//
//  CollectionViewViewController.swift
//  Demo
//

import UIKit

public class CollectionViewViewController: UIViewController {
    // MARK: Nested Types

    private enum Section: Int, CaseIterable {
        case rows
        case grid
    }

    // MARK: Properties

    private let header = HeaderView()
    private let collectionView = CollectionView<Section, UUID>()

    private let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
        let section = Section.allCases[sectionIndex]
        switch section {
        case .rows:
            // Full-width rows, fixed height
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(50)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.interGroupSpacing = 12
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: Dimensions.screenContentPaddingHorizontal,
                bottom: 0,
                trailing: Dimensions.screenContentPaddingHorizontal
            )
            return sectionLayout
        case .grid:
            // Grid of 4 per row, square cells
            let columns = 4
            let spacing = 12.0
            let itemHeight = 60.0
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
                heightDimension: .absolute(itemHeight)
            )
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(itemHeight)
            )
            let subitems = (0..<columns).map({ _ in NSCollectionLayoutItem(layoutSize: itemSize) })
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: subitems)
            group.interItemSpacing = .fixed(spacing)
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.interGroupSpacing = spacing
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(
                top: 36,
                leading: Dimensions.screenContentPaddingHorizontal,
                bottom: Dimensions.screenContentPaddingVertical,
                trailing: Dimensions.screenContentPaddingHorizontal
            )
            return sectionLayout
        }
    }

    private let rowIDs = (0..<4).map({ _ in UUID() })
    private let gridIDs = (0..<32).map({ _ in UUID() })

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.collectionView)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "CollectionView")
            .setDescription(to: "A container that renders an ordered collection of data items using customizable layouts.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.collectionView
            .constrainHorizontal(respectSafeArea: false)
            .constrainToUnderneath(of: self.header, padding: 36)
            .constrainBottom()
            .setVerticalBounce(to: true)
            .setLayout(to: self.layout)
            .register(
                View.self,
                for: .rows,
                render: { view, _ in
                    view.setBackgroundColor(to: Colors.fillSecondary)
                        .setCornerRadius(to: 4)
                }
            )
            .register(
                View.self,
                for: .grid,
                render: { view, _ in
                    view.setBackgroundColor(to: Colors.fillSecondary)
                        .setCornerRadius(to: 4)
                }
            )
            .configureDataSource()

        self.collectionView.render(
            (section: .rows, items: self.rowIDs),
            (section: .grid, items: self.gridIDs),
            animate: false
        )
    }
}
