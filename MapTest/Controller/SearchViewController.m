//
//  SearchViewController.m
//  MapTest
//
//  Created by MD313 on 10/14/16.
//  Copyright © 2016 MD313. All rights reserved.
//

#import "SearchViewController.h"
#import "HeaderView.h"
#import "LocationCell.h"
#import "APIClient.h"
#import "PlaceModel.h"
#import "AppDelegate.h"

@interface SearchViewController ()<UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SearchViewController
{
    NSMutableArray *resultArray;
    BOOL isHistory;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self selectHistoryAction:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return resultArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"HeaderView" owner:self options:nil] objectAtIndex:0];
    [headerView.historyButton addTarget:self action:@selector(selectHistoryAction:) forControlEvents:UIControlEventTouchUpInside];
    [headerView.chooseMapButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 88.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"identifier";
    LocationCell *locationCell = (LocationCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    locationCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSArray *cells = [[NSBundle mainBundle] loadNibNamed:@"LocationCell" owner:self options:nil];
    locationCell = [cells objectAtIndex:0];
    
    PlaceModel *place = resultArray[indexPath.row];
    locationCell.nameLabel.text = place.long_name;
    locationCell.detailLabel.text = place.formatted_address;
    
    return locationCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_placeIndex == 0) {
        APPDELEGATE.place0 = resultArray[indexPath.row];
    } else {
        APPDELEGATE.place1 = resultArray[indexPath.row];
    }
    if (!isHistory) {
        NSMutableArray *backUpArray = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"Backup"];
        if (!backUpArray || backUpArray.count == 0) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [array addObject:((PlaceModel *)resultArray[indexPath.row]).responseObject];
            [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"Backup"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            if (backUpArray.count >= 10) {
                [backUpArray removeObjectAtIndex:backUpArray.count - 1];
            }
            NSMutableArray *array = [NSMutableArray arrayWithArray:backUpArray];
            [array addObject:((PlaceModel *)resultArray[indexPath.row]).responseObject];
            [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"Backup"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSDictionary *params = [[APIClient sharedInstance] paramsSearch:searchBar.text];
        [[APIClient sharedInstance] httpRequestUrl:URL_SEARCH parameter:params completionHandler:^(NSError *error, id response) {
            NSLog(@"%@",response);
            if (!resultArray) {
                resultArray = [[NSMutableArray alloc] init];
            } else {
                [resultArray removeAllObjects];
            }
            NSArray *array = response[@"results"];
            for (int i = 0; i< array.count; i++) {
                PlaceModel *place = [[PlaceModel alloc] init];
                place.responseObject = array[i];
                [place parseResponse:array[i]];
                [resultArray addObject:place];
            }
            [_tableView reloadData];
            isHistory = NO;
        }];
    });
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    NSDictionary *params = [[APIClient sharedInstance] paramsSearch:searchBar.text];
//    [[APIClient sharedInstance] httpRequestUrl:URL_SEARCH parameter:params completionHandler:^(NSError *error, id response) {
//        NSLog(@"%@",response);
//        if (!resultArray) {
//            resultArray = [[NSMutableArray alloc] init];
//        } else {
//            [resultArray removeAllObjects];
//        }
//        NSArray *array = response[@"results"];
//        for (int i = 0; i< array.count; i++) {
//            PlaceModel *place = [[PlaceModel alloc] init];
//            [place parseResponse:array[i]];
//            [resultArray addObject:place];
//        }
//        [_tableView reloadData];
//    }];
}

#pragma mark - Action
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectHistoryAction:(UIButton *)sender {
    if (!resultArray) {
        resultArray = [[NSMutableArray alloc] init];
    } else {
        [resultArray removeAllObjects];
    }
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"Backup"];
    if (array.count >0) {
        for (int i = 0; i < array.count; i++) {
            PlaceModel *place = [[PlaceModel alloc]init];
            place.responseObject = array[i];
            [place parseResponse:array[i]];
            [resultArray addObject:place];
        }
        [_tableView reloadData];
    }
    isHistory = YES;
}

@end
