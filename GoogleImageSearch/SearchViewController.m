//
//  SearchViewController.m
//  GoogleImageSearch
//
//  Created by Seema Kamath on 8/24/13.
//  Copyright (c) 2013 Y.CORP.YAHOO.COM\seemakam. All rights reserved.
//

#import "SearchViewController.h"
#import <AFJSONRequestOperation.h>
#import <UIImageView+AFNetworking.h>
#import <Reachability.h>

#define DEBUGGING 0

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *imageResults;


- (void) fetchData;
- (void) checkReachability;

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Image Search";
        self.imageResults = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.searchBar.placeholder = @"Search";
    self.searchBar.delegate = self;
    self.searchResultsView.delegate = self;
    self.searchResultsView.dataSource = self;
    [self.searchResultsView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.searchResultsView setBackgroundColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CollectionView delegates


- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageResults.count;
    
}


- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    // Dequeue or create a cell of the appropriate type.
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSDictionary *details = self.imageResults[indexPath.item];
    NSString *cellHeight = [details objectForKey:@"tbHeight"];
    NSString *cellWidth = [details objectForKey:@"tbWidth"];
    UIImageView *imageView = nil;
    const int IMAGE_TAG = 1;
    
    if([cell.contentView viewWithTag:IMAGE_TAG]==nil){
        imageView = [[UIImageView alloc] init];
#if DEBUGGING
        NSLog(@"Url=%@", [[self.imageResults objectAtIndex:indexPath.item] objectForKey:@"tbUrl"]);
#endif
        imageView.tag = IMAGE_TAG;
        [cell.contentView addSubview:imageView];
    }else{
        imageView = (UIImageView *)[cell.contentView viewWithTag:IMAGE_TAG];
    }
    
    imageView.image=nil;
    imageView.frame = CGRectMake(0,0,[cellWidth integerValue],[cellHeight integerValue]);
    [imageView setImageWithURL:[NSURL URLWithString:[[self.imageResults objectAtIndex:indexPath.item] objectForKey:@"tbUrl"]]];
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    // TODO: Select Item (implement cover flow)
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *details = self.imageResults[indexPath.item];
    NSString *cellHeight = [details objectForKey:@"tbHeight"];
    NSString *cellWidth = [details objectForKey:@"tbWidth"];
    
    return CGSizeMake([cellWidth integerValue], [cellHeight integerValue]);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark - UISearchBar delegates

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    // [self.imageResults removeAllObjects];
    //[self.searchResultsView clearsContextBeforeDrawing];
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    
    [self.imageResults removeAllObjects];
    [self.searchResultsView reloadData];
    searchBar.text = nil;
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.imageResults removeAllObjects];
    [self.searchResultsView reloadData];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self fetchData];
    [self fetchData];
    
}

#pragma mark - UIScrollView delegates




- (void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    CGPoint scrollVelocity = [scrollView.panGestureRecognizer velocityInView:self.searchResultsView];
    if (scrollVelocity.y > 0.0f){
#if DEBUGGING
        NSLog(@"going down");
#endif
    }else if (scrollVelocity.y < 0.0f){
#if DEBUGGING
        NSLog(@"going up");
#endif
        [self fetchData];
        [self fetchData];
        
    }
    
}

#pragma mark - Private methods

- (void) checkReachability{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    if(reachability.currentReachabilityStatus == NotReachable){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No internet connection" message:@"Make sure you have internet connection available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void) fetchData
{
    [self checkReachability];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&rsz=8&start=%d", [self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], self.imageResults.count]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        id results = [JSON valueForKeyPath:@"responseData.results"];
        if ([results isKindOfClass:[NSArray class]]) {
            //[self.searchResultsView performBatchUpdates:^{
                [self.imageResults addObjectsFromArray:results];
                [self.searchResultsView reloadData];
                //    } completion:nil];
        }
    } failure:nil];
    
    [operation start];
    
}


@end
