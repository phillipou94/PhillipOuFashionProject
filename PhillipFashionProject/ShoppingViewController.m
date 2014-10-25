//
//  ShoppingViewController.m
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import "ShoppingViewController.h"





@interface ShoppingViewController ()
@property (nonatomic, strong) NSArray *arrayOfResults;


@end

@implementation ShoppingViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *urlString = @"http://api.shopstyle.com/action/apiSearch?pid=uid1361-25624519-1&format=json&fts=dresses&min=0&count=1000";
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data=[NSData dataWithContentsOfURL:url];
    NSError *error=nil;
    id response=[NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:&error];
    NSMutableDictionary *results = (NSMutableDictionary*) response;
    self.arrayOfResults = [results objectForKey:@"products"];
    
    
    //NSLog(@"Your JSON Object: %@",self.arrayOfResults);
    
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    
    // Do any additional setup after loading the view.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Customize your menubar programmatically here.
    //[menu setMenubarTitle:self.titleLabel.text];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.arrayOfResults count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //this will start the image loading in background
    dispatch_async(concurrentQueue, ^{
        NSMutableDictionary *item = self.arrayOfResults[indexPath.row];
        NSString *imageString=[item[@"images"][3] objectForKey:@"url"];
        NSURL *imageURL = [NSURL URLWithString:imageString];
        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        UIImage *itemImage = [UIImage imageWithData: data];
        
        //this will set the image when loading is finished
        dispatch_async(dispatch_get_main_queue(), ^{
            
            cell.backgroundView = [[UIImageView alloc] initWithImage:itemImage];
            cell.backgroundView.contentMode = UIViewContentModeScaleAspectFit;
            cell.backgroundColor = [UIColor whiteColor];
        });
    });
    
    
    
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */

@end
