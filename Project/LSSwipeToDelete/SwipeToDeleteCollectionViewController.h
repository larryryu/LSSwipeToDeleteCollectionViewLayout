//
//  SwipeToDeleteCollectionViewController.h
//  LSSwipeToDelete
//
//  Created by Lukman Sanusi on 1/9/14.
//  Copyright (c) 2014 Lukman Sanusi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LSSwipeToDeleteCollectionViewLayout.h>

@interface SwipeToDeleteCollectionViewController : UIViewController <LSSwipeToDeleteCollectionViewLayoutDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@end
