//
//  SearchViewController.h
//  GoogleImageSearch
//
//  Created by Seema Kamath on 8/24/13.
//  Copyright (c) 2013 Y.CORP.YAHOO.COM\seemakam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController <UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *searchResultsView;


@end
