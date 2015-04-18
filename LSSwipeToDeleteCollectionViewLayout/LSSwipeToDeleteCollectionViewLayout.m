//
//  SwipeToDeleteLayout.m
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

#import "LSSwipeToDeleteCollectionViewLayout.h"

typedef NS_ENUM(NSInteger, LSSwipeToDeleteLayoutState){
    LSSwipeToDeleteLayoutStateNone,
    LSSwipeToDeleteLayoutStateDragging,
    LSSwipeToDeleteLayoutStateTransitionToEnd,
    LSSwipeToDeleteLayoutStateTransitionToStart,
    LSSwipeToDeleteLayoutStateDeleting
};

static NSString * const kLSCollectionViewKeyPath = @"collectionView";

@interface LSSwipeToDeleteCollectionViewLayout () <UIGestureRecognizerDelegate>
{
    CGPoint panGesturetranslation;
    NSIndexPath *selectedIndexPath;
    LSSwipeToDeleteDirection userTriggerredSwipeToDeleteDirection;
}
@property (nonatomic, assign) LSSwipeToDeleteLayoutState state;
@end

@implementation LSSwipeToDeleteCollectionViewLayout

- (id)init {
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp{
    [self addObserver:self forKeyPath:kLSCollectionViewKeyPath options:NSKeyValueObservingOptionNew context:nil];
    self.deletionDistanceTresholdValue = LSSwipeToDeleteCollectionViewLayoutDefaultDeletionDistanceTresholdValue;
    self.deletionVelocityTresholdValue = LSSwipeToDeleteCollectionViewLayoutDefaultDeletionVelocityTresholdValue;
    self.swipeToDeleteDirection = LSSwipeToDeleteDirectionMin;
}

- (void)setupCollectionView {
    
    if(_panGestureRecognizer == nil){
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [_panGestureRecognizer addObserver:self forKeyPath:@"delegate" options:NSKeyValueObservingOptionNew context:nil];
        _panGestureRecognizer.delegate = self;
        
    }
    
    for (UIGestureRecognizer *gestureRecognizer in self.collectionView.gestureRecognizers) {
        if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [gestureRecognizer requireGestureRecognizerToFail:_panGestureRecognizer];
        }
    }
    
    [self.collectionView addGestureRecognizer:_panGestureRecognizer];
    
}


#pragma mark - Layout

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray *attributesInRect = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    if (selectedIndexPath) {
        __block NSInteger selectedAttributesIndex = NSNotFound;
        
        [attributesInRect enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attributes, NSUInteger idx, BOOL *stop) {
            if ([attributes.indexPath isEqual:selectedIndexPath]) {
                selectedAttributesIndex = idx;
                *stop = YES;
            }
        }];
        
        if (selectedAttributesIndex != NSNotFound) {
            UICollectionViewLayoutAttributes *selectedAttributes = [self layoutAttributesForItemAtIndexPath:selectedIndexPath];
            [attributesInRect replaceObjectAtIndex:selectedAttributesIndex withObject:selectedAttributes];
        }
    }
    
    return attributesInRect;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    if ([attributes.indexPath isEqual:selectedIndexPath]) {
        CGPoint center = attributes.center;
        [self applySelectedStateToAttributes:attributes];
        [self didDisplaceSelectedAttributes:attributes withInitialCenter:center];
    }
    return attributes;
}

-(void)applySelectedStateToAttributes:(UICollectionViewLayoutAttributes *)attributes{
    CGPoint center = attributes.center;
    
    CGFloat minCenterX = center.x;
    CGFloat minCenterY = center.y;
    CGFloat maxCenterX = center.x;
    CGFloat maxCenterY = center.y;
    
    if (self.swipeToDeleteDirection & LSSwipeToDeleteDirectionMin) {
        minCenterX = - MAXFLOAT;
        minCenterY = - MAXFLOAT;
    }
    
    if (self.swipeToDeleteDirection & LSSwipeToDeleteDirectionMax) {
        maxCenterX = MAXFLOAT;
        maxCenterY = MAXFLOAT;
    }
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        center.x = MAX(minCenterX, MIN(maxCenterX, center.x + panGesturetranslation.x));
    }else if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal){
        center.y = MAX(minCenterY, MIN(maxCenterY, center.y + panGesturetranslation.y));
    }
    
    if (self.state == LSSwipeToDeleteLayoutStateTransitionToEnd) {
        center = [self finalCenterPositionForAttributes:attributes];
    }
    
    attributes.center = center;
}

- (void)didDisplaceSelectedAttributes:(UICollectionViewLayoutAttributes *)attributes withInitialCenter:(CGPoint)initialCenter{
    
}

#pragma mark - Gesture Recogniser

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint velocity = [self.panGestureRecognizer velocityInView:[self.panGestureRecognizer view]];
    if ([gestureRecognizer isEqual:self.panGestureRecognizer]) {
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical && fabs(velocity.x) > fabs(velocity.y)) {
            return YES;
        }else if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal && fabs(velocity.y) > fabs(velocity.x)){
            return YES;
        }
    }
    return NO;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture{
    
    if(self.collectionView.allowsSelection == NO){
        return;
    }
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.state = LSSwipeToDeleteLayoutStateDragging;
            panGesturetranslation = [gesture translationInView:[gesture view]];
            CGPoint currentPoint = [gesture locationInView:[gesture view]];
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:currentPoint];
            if ([self.swipeToDeleteDelegate respondsToSelector:@selector(swipeToDeleteLayout:canDeleteCellAtIndexPath:)]) {
                if (![self.swipeToDeleteDelegate swipeToDeleteLayout:self canDeleteCellAtIndexPath:indexPath]) {
                    return;
                }
            }
            selectedIndexPath = indexPath;
            
            if ([self.swipeToDeleteDelegate respondsToSelector:@selector(swipeToDeleteLayout:willBeginDraggingCellAtIndexPath:)]) {
                [self.swipeToDeleteDelegate swipeToDeleteLayout:self willBeginDraggingCellAtIndexPath:selectedIndexPath];
            }
            
            [self invalidateLayout];
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            if (!selectedIndexPath) return;
            panGesturetranslation = [gesture translationInView:[gesture view]];
            [self cellDidTranslate];
            
            [self invalidateLayout];
            break;
        }
            
        
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if (!selectedIndexPath) return;
            
            userTriggerredSwipeToDeleteDirection = [self deletionDirectionWithGestureRecogniser:gesture];
            BOOL shouldDelete = (userTriggerredSwipeToDeleteDirection != LSSwipeToDeleteDirectionNone);
            
            if ([self.swipeToDeleteDelegate respondsToSelector:@selector(swipeToDeleteLayout:willEndDraggingCellAtIndexPath:willDeleteCell:)]) {
                [self.swipeToDeleteDelegate swipeToDeleteLayout:self willEndDraggingCellAtIndexPath:selectedIndexPath willDeleteCell:shouldDelete];
            }
            
            __weak __typeof(self)weakSelf = self;
            
            void (^completionBlock)(BOOL finished) = ^(BOOL finished){
                if (finished) {
                    __typeof(weakSelf)strongSelf = weakSelf;
                    if ([strongSelf.swipeToDeleteDelegate respondsToSelector:@selector(swipeToDeleteLayout:didEndAnimationWithCellAtIndexPath:didDeleteCell:)]) {
                        [strongSelf.swipeToDeleteDelegate swipeToDeleteLayout:strongSelf didEndAnimationWithCellAtIndexPath:selectedIndexPath didDeleteCell:shouldDelete];
                    }
                    selectedIndexPath = nil;
                    userTriggerredSwipeToDeleteDirection = LSSwipeToDeleteDirectionNone;
                }
            };
            
            if (!shouldDelete || gesture.state == UIGestureRecognizerStateFailed || gesture.state == UIGestureRecognizerStateCancelled) {
                [self cancelSwipeToDeleteWithCompletion:completionBlock];
            }else{
                NSArray *indexPathsToDelete = @[selectedIndexPath];
                [self performSwipeToDeleteForCellsAtIndexPaths:indexPathsToDelete withCompletion:completionBlock];
            }
            
            [self cellDidTranslate];
            
            break;
        }
            
        default:
            break;
    }
    
}

- (void)cellDidTranslate{
    if ([self.swipeToDeleteDelegate respondsToSelector:@selector(swipeToDeleteLayout:cellDidTranslateWithOffset:)]) {
        UICollectionViewLayoutAttributes *unselectedAttribute = [super layoutAttributesForItemAtIndexPath:selectedIndexPath];
        UICollectionViewLayoutAttributes *selectedAttribute = [self layoutAttributesForItemAtIndexPath:selectedIndexPath];
        UIOffset offset = UIOffsetMake(selectedAttribute.center.x - unselectedAttribute.center.x, selectedAttribute.center.y - unselectedAttribute.center.y);
        
        [self.swipeToDeleteDelegate swipeToDeleteLayout:self cellDidTranslateWithOffset:offset];
    }
}

-(LSSwipeToDeleteDirection)deletionDirectionWithGestureRecogniser:(UIPanGestureRecognizer *)panGesture{
    LSSwipeToDeleteDirection direction = LSSwipeToDeleteDirectionNone;
    
    CGPoint tranlastion = [panGesture translationInView:[panGesture view]];
    CGPoint velocity = [panGesture velocityInView:[panGesture view]];
    CGFloat escapeDistance = [self translationValue];
    CGFloat escapeVelocity = [self velocityMagnitude];
    
    if (escapeDistance > self.deletionDistanceTresholdValue && [self isTranslationInDeletionDirection:tranlastion]) {
        direction = [self swipeToDeleteDirectionFromValue:tranlastion];
    }else if (escapeVelocity > self.deletionVelocityTresholdValue && [self isVelocityInDeletionDirection:velocity]){
        direction = [self swipeToDeleteDirectionFromValue:tranlastion];
    }
    
    return direction;
}

-(void)performSwipeToDeleteForCellsAtIndexPaths:(NSArray *)indexPathsToDelete withCompletion:(void (^)(BOOL finished))completionBlock{
    [self.panGestureRecognizer setEnabled:NO];
    self.state = LSSwipeToDeleteLayoutStateTransitionToEnd;
    
    __weak __typeof(self)weakSelf = self;
    
    [self.collectionView performBatchUpdates:^{
        
    }  completion:^(BOOL finished) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.state = LSSwipeToDeleteLayoutStateDeleting;
        NSAssert(strongSelf.swipeToDeleteDelegate, @"No delegate found");
        [strongSelf.swipeToDeleteDelegate swipeToDeleteLayout:strongSelf didDeleteCellAtIndexPath:selectedIndexPath];
        [strongSelf clearSelectedIndexPaths];
        
        [strongSelf.collectionView performBatchUpdates:^{
            __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.collectionView deleteItemsAtIndexPaths:indexPathsToDelete];
        }  completion:^(BOOL finished) {
            __typeof(weakSelf)strongSelf = weakSelf;
            
            if (completionBlock) completionBlock(finished);
            [strongSelf.panGestureRecognizer setEnabled:YES];
        }];
    }];
}

-(void)cancelSwipeToDeleteWithCompletion:(void (^)(BOOL finished))completionBlock{
    [self.panGestureRecognizer setEnabled:NO];
    if ([self.swipeToDeleteDelegate respondsToSelector:@selector(swipeToDeleteLayout:cellDidTranslateWithOffset:)]) {
        [self.swipeToDeleteDelegate swipeToDeleteLayout:self cellDidTranslateWithOffset:UIOffsetMake(0, 0)];
    }
    
    __weak __typeof(self)weakSelf = self;
    
    self.state = LSSwipeToDeleteLayoutStateTransitionToStart;
    [self clearSelectedIndexPaths];
    [self.collectionView performBatchUpdates:nil
                                  completion:^(BOOL finished) {
                                      __typeof(weakSelf)strongSelf = weakSelf;
                                      if (completionBlock) completionBlock(finished);
                                      strongSelf.state = LSSwipeToDeleteLayoutStateNone;
                                      [strongSelf.panGestureRecognizer setEnabled:YES];
                                  }];
}

-(void)clearSelectedIndexPaths{
    selectedIndexPath = nil;
}

#pragma mark - Helper Methods

-(CGPoint)finalCenterPositionForAttributes:(UICollectionViewLayoutAttributes *)attributes{
    CGPoint finalCenterPosition = attributes.center;
    
    switch (userTriggerredSwipeToDeleteDirection) {
        case LSSwipeToDeleteDirectionMin:
        {
            if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                finalCenterPosition.x = CGRectGetMinX(self.collectionView.bounds) - (attributes.frame.size.width/2.0f);
            }else if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal){
                finalCenterPosition.y = CGRectGetMinY(self.collectionView.bounds) - (attributes.frame.size.height/2.0f);
            }
            break;
        }
            
        case LSSwipeToDeleteDirectionMax:
        {
            if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                finalCenterPosition.x = CGRectGetMaxX(self.collectionView.bounds) + (attributes.frame.size.width/2.0f);
            }else if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal){
                finalCenterPosition.y = CGRectGetMaxY(self.collectionView.bounds) + (attributes.frame.size.height/2.0f);
            }
            break;
        }
            
        default:
            break;
    }
    
    return finalCenterPosition;
}

-(CGFloat)translationValue{
    CGFloat tranlationValue = 0.0f;
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        tranlationValue = panGesturetranslation.x;
    }else if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal){
        tranlationValue = panGesturetranslation.y;
    }
    
    return fabs(tranlationValue);
}

-(CGFloat)velocityMagnitude{
    
    return fabs([self velocity]);
}

-(CGFloat)velocity{
    
    CGPoint velocity = [self.panGestureRecognizer velocityInView:[self.panGestureRecognizer view]];
    CGFloat velocityValue = 0.0f;
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        velocityValue = velocity.x;
    }else if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal){
        velocityValue = velocity.y;
    }
    return velocityValue;
    
}

-(LSSwipeToDeleteDirection)swipeToDeleteDirectionFromValue:(CGPoint)value{
    
    LSSwipeToDeleteDirection direction = LSSwipeToDeleteDirectionNone;
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        if (value.x < 0) {
            direction = LSSwipeToDeleteDirectionMin;
        }else if (value.x > 0){
            direction = LSSwipeToDeleteDirectionMax;
        }
    }else if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal){
        if (value.y < 0) {
            direction = LSSwipeToDeleteDirectionMin;
        }else if (value.y > 0){
            direction = LSSwipeToDeleteDirectionMax;
        }
    }
    
    return direction;
}

-(BOOL)isVelocityInDeletionDirection:(CGPoint)velocity{
    
    LSSwipeToDeleteDirection userTriggerredSwipeToDeleteVelocityDirection = [self swipeToDeleteDirectionFromValue:velocity];
    BOOL inDeletionDirection = (self.swipeToDeleteDirection & userTriggerredSwipeToDeleteVelocityDirection);
    
    if (userTriggerredSwipeToDeleteVelocityDirection == LSSwipeToDeleteDirectionNone) {
        inDeletionDirection = NO;
    }

    return inDeletionDirection;
}

-(BOOL)isTranslationInDeletionDirection:(CGPoint)translation{
    
    LSSwipeToDeleteDirection userTriggerredSwipeToDeleteTranslationDirection = [self swipeToDeleteDirectionFromValue:translation];
    BOOL inDeletionDirection = (self.swipeToDeleteDirection & userTriggerredSwipeToDeleteTranslationDirection);
    
    if (userTriggerredSwipeToDeleteTranslationDirection == LSSwipeToDeleteDirectionNone) {
        inDeletionDirection = NO;
    }
    
    return inDeletionDirection;
}

#pragma mark - Key-Value Observing methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kLSCollectionViewKeyPath]) {
        if (self.collectionView != nil) {
            [self setupCollectionView];
        }
    }else if ([keyPath isEqualToString:@"delegate"] && [object isEqual:self.panGestureRecognizer]){
        NSAssert([[change objectForKey:NSKeyValueChangeNewKey] isEqual:self], @"The delegate of the PanGestureRecogniser must be the layout object");
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:kLSCollectionViewKeyPath];
    [_panGestureRecognizer removeObserver:self forKeyPath:@"delegate"];
}

@end
