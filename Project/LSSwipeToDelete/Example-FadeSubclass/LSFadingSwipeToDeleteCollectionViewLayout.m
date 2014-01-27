//
//  LSFadingSwipeToDeleteCollectionViewLayout.m
//  LSSwipeToDeleteCollectionViewLayout
//
//  Created by Simon Gislen on 27/01/14.
//  Copyright (c) 2014 Lukman Sanusi. All rights reserved.
//

#import "LSFadingSwipeToDeleteCollectionViewLayout.h"

static CGFloat const kFadeConstant = M_PI; //Higher values causes the fade to happen quicker

//TODO: Currently, this is a very simple curve. Can perhaps be replaced by something neater.
static CGFloat easingDisplacementFade(CGFloat ratio) {
    return fmaxf(pow(kFadeConstant,ratio)/kFadeConstant, 0.01f);
};

@implementation LSFadingSwipeToDeleteCollectionViewLayout

- (void)didDisplaceSelectedAttributes:(UICollectionViewLayoutAttributes *)attributes withInitialCenter:(CGPoint)initialCenter {
    CGPoint center = attributes.center;
    
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat middle = initialCenter.y;
        CGFloat displacementRatio = (center.y <= middle? (center.y/middle): ((middle - (center.y - middle))/middle));
        CGFloat alpha = easingDisplacementFade(displacementRatio);
        attributes.alpha = alpha;
    }
    else {
        CGFloat middle = initialCenter.x;
        CGFloat displacementRatio = (center.x <= middle? (center.x/middle): ((middle - (center.x - middle))/middle));
        CGFloat alpha = easingDisplacementFade(displacementRatio);
        attributes.alpha = alpha;
    }
}
@end
