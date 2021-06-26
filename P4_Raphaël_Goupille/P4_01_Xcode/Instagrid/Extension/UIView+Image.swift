//
//  UIView+Image.swift
//  Instagrid
//
//  Created by Raphaël Goupille on 07/06/2021.
//

import UIKit

extension UIView {
    var image: UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
        return image
    }

}
