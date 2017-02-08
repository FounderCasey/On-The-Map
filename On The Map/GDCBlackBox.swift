//
//  GDCBlackBox.swift
//  On The Map
//
//  Created by Casey Wilcox on 1/3/17.
//  Copyright © 2017 Casey Wilcox. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
