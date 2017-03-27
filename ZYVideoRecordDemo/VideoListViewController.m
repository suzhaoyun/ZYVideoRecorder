//
//  VideoListViewController.m
//  ZYVideoRecordDemo
//
//  Created by ZYSu on 2017/3/27.
//  Copyright © 2017年 ZYSu. All rights reserved.
//

#import "VideoListViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VideoListViewController ()

@property (nonatomic, strong) NSMutableArray *urls;

@end

@implementation VideoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    self.urls = [manager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"ZYVideoRecordCache"]] includingPropertiesForKeys:nil options:0 error:NULL].mutableCopy;
    
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.urls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    UILabel *titleL = [cell viewWithTag:10];
    NSURL *url = self.urls[indexPath.row];
    titleL.text = url.path.lastPathComponent;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MPMoviePlayerViewController *vc = [[MPMoviePlayerViewController alloc] initWithContentURL:self.urls[indexPath.row]];
    [self presentMoviePlayerViewControllerAnimated:vc];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[NSFileManager defaultManager] removeItemAtURL:self.urls[indexPath.row] error:NULL];
        [self.urls removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
