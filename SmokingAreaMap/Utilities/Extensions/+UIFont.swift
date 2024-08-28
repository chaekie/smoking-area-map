//
//  +UIFont.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/28/24.
//

import UIKit

extension UIFont {

    static func customPreferredFont(for style: TextStyle, weight: Weight) -> UIFont {
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let font = UIFont.systemFont(ofSize: desc.pointSize, weight: weight)
        let metrics = UIFontMetrics(forTextStyle: style)
        return metrics.scaledFont(for: font, maximumPointSize: 36)
    }

}
