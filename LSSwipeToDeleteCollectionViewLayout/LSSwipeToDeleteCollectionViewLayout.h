//
//  SwipeToDeleteLayout.h
//  LSSwipeToDelete
//
//  Created by Lukman Sanusi on 1/9/14.
//  Copyright (c) 2014 Lukman Sanusi <egobooster@me.com>. All rights reserved.
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LSSwipeToDeleteDirection){
    LSSwipeToDeleteDirectionNone    =   1 << 0,      // prevents deletion
    LSSwipeToDeleteDirectionMin     =   1 << 1, // Causes deletion animation toward the CollectionView's bounds minX or minY
    LSSwipeToDeleteDirectionMax     =   1 << 2  // Causes deletion animation toward the CollectionView's bounds maxX or maxY 
};

static const CGFloat LSSwipeToDeleteCollectionViewLayoutDefaultDeletionDistanceTresholdValue = 100.0f;
static const CGFloat LSSwipeToDeleteCollectionViewLayoutDefaultDeletionVelocityTresholdValue = 100.0f;

@protocol LSSwipeToDeleteCollectionViewLayoutDelegate;

@interface LSSwipeToDeleteCollectionViewLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) CGFloat deletionDistanceTresholdValue;
@property (nonatomic, assign) CGFloat deletionVelocityTresholdValue;
@property (nonatomic, assign) LSSwipeToDeleteDirection swipeToDeleteDirection;
@property (nonatomic, assign) id <LSSwipeToDeleteCollectionViewLayoutDelegate> swipeToDeleteDelegate;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGestureRecognizer;
/* You can overide this method in a subclass to add extra effects to the cell that is being swiped for deletion */
- (void)didDisplaceSelectedAttributes:(UICollectionViewLayoutAttributes *)attributes withInitialCenter:(CGPoint)initialCenter;
@end

@protocol LSSwipeToDeleteCollectionViewLayoutDelegate <NSObject>
/* required method. The datasoures need to remove the object at the specified indexPath */ 
-(void)swipeToDeleteLayout:(LSSwipeToDeleteCollectionViewLayout *)layout didDeleteCellAtIndexPath:(NSIndexPath *)indexPath;

@optional
/* return YES to allow the for deletion of the indexPath. Default is YES */
-(BOOL)swipeToDeleteLayout:(LSSwipeToDeleteCollectionViewLayout *)layout canDeleteCellAtIndexPath:(NSIndexPath *)indexPath;
/* Called just after the pan to delete gesture is recognised with a proposed item for deletion. */
-(void)swipeToDeleteLayout:(LSSwipeToDeleteCollectionViewLayout *)layout willBeginDraggingCellAtIndexPath:(NSIndexPath *)indexPath;
/* Called just after the user lift the finger and right before the deletion/restoration animation begins. */
-(void)swipeToDeleteLayout:(LSSwipeToDeleteCollectionViewLayout *)layout willEndDraggingCellAtIndexPath:(NSIndexPath *)indexPath willDeleteCell:(BOOL)willDelete;
/* Called just after the deletion/restoration animation ended. */
-(void)swipeToDeleteLayout:(LSSwipeToDeleteCollectionViewLayout *)layout didEndAnimationWithCellAtIndexPath:(NSIndexPath *)indexPath didDeleteCell:(BOOL)didDelete;
@end
