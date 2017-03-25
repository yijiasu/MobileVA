//
//  VATableListViewController.m
//  MobileVA
//
//  Created by Su Yijia on 3/18/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VATableListViewController.h"
#import "VAEgoNameThumbnailCollectionViewCell.h"
#import "VAEgoListTableViewCell.h"

@interface VATableListViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *allEgoList;
@property (nonatomic, strong) NSMutableArray<VAEgoPerson *> *selectedEgo;
@property (nonatomic, strong) NSArray<VAEgoPerson *> *filteredEgo;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation VATableListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.type = VAViewControllerTypeTable;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _selectedEgo = [NSMutableArray new];
    _allEgoList = [[[VAUtil util] coordinator] allEgoPersons];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];

    _allEgoList = [_allEgoList sortedArrayUsingDescriptors:sortDescriptors];
    [_tableView setHidden:YES];
    
    _collectionView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width / 3, [UIScreen mainScreen].bounds.size.width / 3);
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView setHidden:NO];
    
    [self.dataModel addObserver:self forKeyPath:@"selectedEgoPerson" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.dimsBackgroundDuringPresentation = NO;
    _tableView.tableHeaderView = _searchController.searchBar;
    self.definesPresentationContext = YES;
}

- (void)dealloc
{
    [self.dataModel removeObserver:self forKeyPath:@"selectedEgoPerson"];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    _filteredEgo = [_allEgoList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(VAEgoPerson * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [[evaluatedObject.name lowercaseString] containsString:[searchController.searchBar.text lowercaseString]];
    }]];
    
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark VAViewController View Size Control

- (void)becomeThumbnailView
{
    NSLog(@"%@ becomeThumbnailView", self);
    [self.tableView setHidden:YES];
    [self.collectionView setHidden:NO];
    _searchController.view.hidden = YES;
    
}

- (void)becomeMainView
{
    NSLog(@"%@ becomeMainView", self);
    [self.tableView setHidden:NO];
    [self.collectionView setHidden:YES];
    _searchController.view.hidden = NO;
    
    _selectedEgo = [[[VAUtil util] model].selectedEgoPerson mutableCopy];
    [_tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VAEgoListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EgoListCell" forIndexPath:indexPath];
    VAEgoPerson *egoPerson;
    if (_searchController.active && [_searchController.searchBar.text length] != 0) {
        egoPerson = _filteredEgo[indexPath.row];
    }
    else
    {
        egoPerson = _allEgoList[indexPath.row];
    }
    
    if (cell) {
        [cell configureCellWithEgoPerson:egoPerson];
        if ([self.dataModel.selectedEgoPerson containsObject:egoPerson]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        else
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_searchController.active && [_searchController.searchBar.text length] != 0) {
        return [_filteredEgo count];
    }
    else
    {
        return [_allEgoList count];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    VAEgoListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
//
    
    VAEgoPerson *egoPerson;
    if (_searchController.active && [_searchController.searchBar.text length] != 0) {
        egoPerson = _filteredEgo[indexPath.row];
    }
    else
    {
        egoPerson = _allEgoList[indexPath.row];
    }
    
    [self togglePerson: egoPerson];
    [self refreshSelectedPerson];
}

- (void)refreshSelectedPerson
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.collectionView reloadData];
    });
}

- (void)togglePerson:(VAEgoPerson *)egoPerson
{

    if (egoPerson) {
        if ([_selectedEgo containsObject:egoPerson]) {
            if ([_selectedEgo count] > 1) {
                [_selectedEgo removeObject:egoPerson];
            }
        }
        else
        {
            [_selectedEgo addObject:egoPerson];
            if ([_selectedEgo count] > MAX_SELECTED_EGO_LIMIT) {
                [_selectedEgo removeObjectAtIndex:0];
            }
        }
    }
    
    self.dataModel.selectedEgoPerson = _selectedEgo;

}

#pragma mark Collection View DataSource & Delegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VAEgoNameThumbnailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NameCell" forIndexPath:indexPath];
    VAEgoPerson *egoPerson = _selectedEgo[indexPath.row];
    
    if (cell) {
        [cell configureCellWithEgoPerson:egoPerson index:indexPath.row];
        
    }
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"sizeForItemAtIndexPath :%@", indexPath);
    return CGSizeMake([UIScreen mainScreen].bounds.size.width / 3, 25);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_selectedEgo count];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 0, 10, 0);
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:@"selectedEgoPerson"]) {
        _selectedEgo = change[NSKeyValueChangeNewKey];
        [self refreshSelectedPerson];
    }
}


@end
