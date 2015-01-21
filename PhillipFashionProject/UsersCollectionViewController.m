//
//  UsersCollectionViewController.m
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/26/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import "UsersCollectionViewController.h"
#import "ServerRequest.h"
#import <Parse/Parse.h>
#import "CoreDataSingleton.h"
#import "RecommendationViewController.h"

@interface UsersCollectionViewController ()
@property (nonatomic, strong) NSArray *allUsersArray;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) NSMutableArray *imagesArray;

@end

@implementation UsersCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imagesArray= [[NSMutableArray alloc]init];

   
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    ServerRequest *request = [ServerRequest sharedManager];
    self.allUsersArray = [request getAllUsers];
    self.tabBarController.tabBar.hidden=NO;
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"   "
                                      style:UIBarButtonItemStylePlain
                                     target:nil
                                     action:nil];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(self.view.bounds.size.width/2-15, collectionView.bounds.size.width);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"%@",self.allUsersArray);
    return [self.allUsersArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:-1];
    NSDictionary *user = [self.allUsersArray objectAtIndex:indexPath.row];
    nameLabel.text = user[@"username"];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:-2];
    UIButton *referButton = (UIButton*)[cell viewWithTag:-3];
    [referButton addTarget:self action:@selector(referTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
   
    NSString *userID=user[@"userID"];
    NSString *profilePictureID = user[@"profilePictureID"][0];
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
      ;
        PFQuery *query = [PFQuery queryWithClassName:@"ProfilePictures"];
        [query getObjectInBackgroundWithId:profilePictureID block:^(PFObject * photoObject, NSError *error) {
                imageView.image =[[UIImage alloc] initWithData: [[photoObject objectForKey:@"file"] getData]];
            [self.imagesArray addObject:imageView.image];
            if(!imageView.image){
                NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", userID];
                imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userImageURL]]];
                [self.imagesArray addObject:imageView.image];
            }

        }];
    
    });
    
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *user = [self.allUsersArray objectAtIndex:indexPath.row];
    NSLog(@"selected:%@",user);
}


- (NSIndexPath*)indexPathForEvent:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.collectionView];
    
    return [self.collectionView indexPathForItemAtPoint:currentTouchPosition];
    
}

-(IBAction)referTapped:(id)sender withEvent:(UIEvent*)event {
    
    UIButton *button = (UIButton*)sender;
    button.selected=YES;
    NSIndexPath *buttonIndexPath = [self indexPathForEvent:event];
    NSDictionary *userDic= [self.allUsersArray objectAtIndex:buttonIndexPath.row];
   
    self.selectedUser = [[User alloc]init];
    self.selectedUser.username = userDic[@"username"];
    self.selectedUser.userID = userDic[@"userID"];
    self.selectedImage = [self.imagesArray objectAtIndex:buttonIndexPath.row];
    [self performSegueWithIdentifier:@"Recommendation" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"Recommendation"]) {
        
        RecommendationViewController *other = [segue destinationViewController];
        other.selectedUser = self.selectedUser;
        other.profileImage = self.selectedImage;
       
    }
}


@end
