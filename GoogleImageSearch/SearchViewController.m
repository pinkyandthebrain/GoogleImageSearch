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

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *imageResults;

- (void) onCancel;

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
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,[cellWidth integerValue],[cellHeight integerValue])];
    
    NSLog(@"Url=%@", [[self.imageResults objectAtIndex:indexPath.item] objectForKey:@"tbUrl"]);
    [imageView setImageWithURL:[NSURL URLWithString:[[self.imageResults objectAtIndex:indexPath.item] objectForKey:@"tbUrl"]]];
    [imageView setBackgroundColor:[UIColor whiteColor]];
    if(imageView.image){
        NSLog(@"Image = %p", imageView.image);
    }
    [cell.contentView addSubview:imageView];
    
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
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
    
    CGSize retval = [cellWidth integerValue] > 0 ? CGSizeMake([cellWidth integerValue], [cellHeight integerValue]) : CGSizeMake(100, 100);
    return retval;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - UISearchBar delegates

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@", [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        id results = [JSON valueForKeyPath:@"responseData.results"];
        if ([results isKindOfClass:[NSArray class]]) {
            [self.imageResults removeAllObjects];
            [self.imageResults addObjectsFromArray:results];
            [self.searchResultsView reloadData];
        }
    } failure:nil];
    
    [operation start];
}


#pragma mark - Private methods

- (void) onCancel {
    
    [self.searchBar resignFirstResponder];
    
    
}



@end
