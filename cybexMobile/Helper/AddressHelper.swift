//
//  AddressHelper.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/12.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

class AddressHelper {
    class func sortNameBasedonAddress(_ names: [AddressName]) -> [String] {
        let collation = UILocalizedIndexedCollation.current()
        var newSectionsArray: [[AddressName]] = []

        for _ in 0 ..< collation.sectionTitles.count {
            let array = [AddressName]()
            newSectionsArray.append(array)
        }

        for name in names {
            let sectionNumber = collation.section(for: name, collationStringSelector: #selector(getter: AddressName.name))
            var sectionBeans = newSectionsArray[sectionNumber]

            sectionBeans.append(name)

            newSectionsArray[sectionNumber] = sectionBeans
        }

        for item in 0 ..< collation.sectionTitles.count {
            let beansArrayForSection = newSectionsArray[item]

            let sortedBeansArrayForSection = collation.sortedArray(from: beansArrayForSection, collationStringSelector: #selector(getter: AddressName.name))
            if let sortedBeans = sortedBeansArrayForSection as? [AddressName] {
                newSectionsArray[item] = sortedBeans
            }
        }

        let sortedNames = newSectionsArray.flatMap({ $0 }).map({ $0.name })

        return sortedNames
    }
}
