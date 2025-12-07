//
//  SectionBackgroundFlowLayout.swift
//  EarnLog
//
//  Created by M3 pro on 01/11/2025.
//
import UIKit

final class SectionBackgroundFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }

        var allAttributes: [UICollectionViewLayoutAttributes] = []

            // Отфильтровываем headers, чтобы использовать наши кастомные
        for attr in attributes {
            if attr.representedElementKind == UICollectionView.elementKindSectionHeader {
                    // Пропускаем стандартные headers
                continue
            }
            allAttributes.append(attr)
        }

        let sectionIndexes = Set(attributes.map { $0.indexPath.section })
        for sectionIndex in sectionIndexes {
                // Атрибуты для фона
            if let sectionBackground = layoutAttributesForSection(section: sectionIndex) {
                allAttributes.append(sectionBackground)
            }

                // Атрибуты для header - НАШИ кастомные
            if let header = layoutAttributesForSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                at: IndexPath(item: 0, section: sectionIndex)
            ) {
                allAttributes.append(header)
            }
        }

        return allAttributes
    }

    private func layoutAttributesForSection(section: Int) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else { return nil }
        let indexPath = IndexPath(item: 0, section: section)
        let attributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: "SectionBackground", with: indexPath)
        attributes.zIndex = -1 // фон позади ячеек

            // Получаем рамки секции
        guard let first = layoutAttributesForItem(at: IndexPath(item: 0, section: section)),
              let last = layoutAttributesForItem(at: IndexPath(item: collectionView.numberOfItems(inSection: section) - 1, section: section)) else { return nil }

        let sectionFrame = first.frame.union(last.frame).insetBy(dx: -20, dy: -10)
        attributes.frame = sectionFrame

        return attributes
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView, elementKind == UICollectionView.elementKindSectionHeader else { return nil }

        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)

            // Позиционируем header
        if let firstItem = layoutAttributesForItem(at: IndexPath(item: 0, section: indexPath.section)) {
            let leftInset = sectionInset.left                                // используем тот же отступ что и у секции
            let rightInset = sectionInset.right
            let headerWidth = collectionView.frame.width - leftInset - rightInset
            let headerX = leftInset                                          // отступ слева как у секции
            let headerHeight = headerReferenceSize.height
            let headerY = firstItem.frame.minY - headerHeight - 10

            attributes.frame = CGRect(x: headerX, y: headerY, width: headerWidth, height: headerHeight)
            attributes.zIndex = 1024
            return attributes
        }

        return nil
    }

}
