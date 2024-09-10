//
//  +UIScreen.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/23/24.
//

import UIKit

extension UIScreen {

    static var safeAreaInsets: UIEdgeInsets {
        let keyWindow = UIApplication.shared.connectedScenes
            .map({ $0 as? UIWindowScene })
            .compactMap({ $0 })
            .first?.windows.first

        return (keyWindow?.safeAreaInsets) ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    static var screenSize: CGRect {
        let keyWindow = UIApplication.shared.connectedScenes
            .map({ $0 as? UIWindowScene })
            .compactMap({ $0 })
            .first?.windows.first

        return (keyWindow?.screen.bounds) ?? CGRect()
    }

}
