//
//  This file is part of the NineAnimator project.
//
//  Copyright © 2018 Marcus Zhou. All rights reserved.
//
//  NineAnimator is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  NineAnimator is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with NineAnimator.  If not, see <http://www.gnu.org/licenses/>.
//

import CoreSpotlight
import Foundation
import Kingfisher
import UIKit

/// A helper struct that facilitates NineAnimator continuity functions
enum Continuity {
    static let activityTypeViewAnime = "com.marcuszhou.nineanimator.activity.viewAnime"
    
    static func activity(for anime: Anime) -> NSUserActivity {
        let link = anime.link
        let activity = NSUserActivity(activityType: activityTypeViewAnime)
        
        activity.title = "Watch \(link.title)"
        activity.webpageURL = link.link
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: "public.movie")
        attributeSet.contentURL = link.link
        attributeSet.displayName = link.title
        attributeSet.keywords = [ link.title, "anime" ]
        attributeSet.thumbnailURL = URL(string: Kingfisher.ImageCache.default.cachePath(forKey: link.image.absoluteString))
        
        if let url = attributeSet.thumbnailURL, let image = UIImage(contentsOfFile: url.absoluteString) {
            attributeSet.thumbnailData = image.jpegData(compressionQuality: 0.8)
        } else { Log.info("Thumbnail cannot be saved to activity now for this anime. Will be saved later if needed.") }
        
        attributeSet.contentSources = [ link.source.name ]
        attributeSet.comment = anime.description
        
        activity.contentAttributeSet = attributeSet
        
        activity.isEligibleForSearch = true
        activity.isEligibleForHandoff = true
        activity.isEligibleForPublicIndexing = true
        activity.needsSave = false
        
        if #available(iOS 12.0, *) {
            activity.isEligibleForPrediction = true
        }
        
        activity.keywords = [ link.title, "anime" ]
        
        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(link)
            
            activity.userInfo = [ "link": data ]
        } catch { Log.error("Cannot encode AnimeLink into activity (%@). This activity may become invalid.", error) }
        
        return activity
    }
}