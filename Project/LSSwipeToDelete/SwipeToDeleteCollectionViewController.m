//
//  SwipeToDeleteCollectionViewController.m
//  LSSwipeToDelete
//
//  Created by Lukman Sanusi on 1/9/14.
//  Copyright (c) 2014 Lukman Sanusi. All rights reserved.
//

#import "SwipeToDeleteCollectionViewController.h"

static NSString *LSCollectionViewCellIdentifier = @"Cell";

@interface SwipeToDeleteCollectionViewController () <UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *colors;
}
@end

@implementation SwipeToDeleteCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:LSCollectionViewCellIdentifier];
    [self.collectionView setAlwaysBounceVertical:YES];
    
    LSSwipeToDeleteCollectionViewLayout *layout = (LSSwipeToDeleteCollectionViewLayout *)self.collectionView.collectionViewLayout;
    [layout setSwipeToDeleteDelegate:self];
    
    [self resetColors];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self becomeFirstResponder];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
}

-(void)resetColors{
    colors = @[[UIColor redColor], [UIColor purpleColor], [UIColor orangeColor], [UIColor greenColor], [UIColor redColor], [UIColor blueColor], [UIColor orangeColor], [UIColor greenColor], [UIColor redColor], [UIColor blueColor], [UIColor orangeColor], [UIColor greenColor]].mutableCopy;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ( event.subtype == UIEventSubtypeMotionShake )
    {
        [self resetColors];
        [self.collectionView reloadData];
    }
    
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return colors.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LSCollectionViewCellIdentifier forIndexPath:indexPath];
    
    [cell setBackgroundColor:colors[indexPath.row]];
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(200.0f, 200.0f);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0f;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0f;   
}

#pragma mark - LSSwipeToDeleteLayoutDelegate

-(void)swipeToDeleteLayout:(LSSwipeToDeleteCollectionViewLayout *)layout didDeleteAttributesAtIndexPath:(NSIndexPath *)indexPath{
    [colors removeObjectAtIndex:indexPath.row];
}

@end
