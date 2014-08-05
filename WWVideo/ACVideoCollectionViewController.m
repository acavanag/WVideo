//
//  ACVideoCollectionViewController.m
//  WWVideo
//
//  Created by Andrew Cavanagh on 3/7/14.
//  Copyright (c) 2014 WeddingWire. All rights reserved.
//

#import "ACVideoCollectionViewController.h"
#import "ACCDMgr.h"
#import "WWVideoCell.h"

@interface ACVideoCollectionViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@end

@implementation ACVideoCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)takeVideoPressed:(id)sender
{
    [self performSegueWithIdentifier:@"videosToRecord" sender:nil];
}

#pragma mark - Fetched Results Controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) return _fetchedResultsController;
    self.fetchedResultsController = [[ACCDMgr sharedInstance] procureVidoesWithDelegate:self];
    return self.fetchedResultsController;
}

#pragma mark - FetchedResultsController Delegate

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    [self.collectionView addChangeForSection:sectionInfo atIndex:sectionIndex forChangeType:type];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    [self.collectionView addChangeForObjectAtIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView commitChanges];
}

#pragma mark - CollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (WWVideoCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"videoCell";
    WWVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    Video *video = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell.thumbnailView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:video.image]]]];
    
    return cell;
}

#pragma mark - CollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Video *video = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UICollectionViewLayoutAttributes *attrbs = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:video.path]];
    self.player = [[AVPlayer alloc] initWithPlayerItem:item];
    
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.playerLayer.frame = attrbs.frame;
    [self.collectionView.layer addSublayer:self.playerLayer];
    
    [self.player play];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    AVPlayerItem *item = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"])
    {
        switch(item.status)
        {
            case AVPlayerItemStatusFailed:
                NSLog(@"player item status failed");
                break;
            case AVPlayerItemStatusReadyToPlay:
            {
                NSLog(@"player item status is ready to play");
            }
                break;
            case AVPlayerItemStatusUnknown:
                NSLog(@"player item status is unknown");
                break;
                
            default:
                NSLog(@"other status");
        }
    }
    else if ([keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        if (item.playbackBufferEmpty)
        {
            NSLog(@"player item playback buffer is empty");
        }
    }
}

@end
