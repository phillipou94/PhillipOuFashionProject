//
//  ShoppingViewController.m
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import "ShoppingViewController.h"
#import "DropDownListView.h"
#import "ShowItemViewController.h"
#import "ServerRequest.h"
#import "CoreDataSingleton.h"
#import "User.h"

@interface ShoppingViewController ()
@property (nonatomic, strong) NSMutableArray *arrayOfResults;
@property BOOL showHeader;
@property (nonatomic, strong) NSString* searchTerm;
@property (nonatomic,strong) User *currentUser;
@property (nonatomic, strong) UICollectionReusableView *header;
@property (nonatomic, strong) NSString *searchItem;
@property (nonatomic, strong) NSString *priceFilter;
@property (nonatomic, strong) NSString *categoryFilter;

@end

@implementation ShoppingViewController{
    NSMutableArray *categoryList;
    BOOL isShowingMenu;
    UIImageView *blurredView;
}

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];

    [[UITabBar appearance] setTintColor:[UIColor blackColor]];
    self.title=@"Shop";
    
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor colorWithRed:0.70 green:0.70 blue:0.70 alpha:1.0] forKey:NSForegroundColorAttributeName];
   self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.99 green:0.99 blue:0.99 alpha:0.25];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"CaviarDreams" size:21],
      NSFontAttributeName, nil]];
    
    isShowingMenu=NO;
    self.showHeader=NO;
    
    categoryList=[@[@"Tops", @"Dresses", @"Jeans",@"Accessories", @"Jackets", @"Shorts"]mutableCopy];
    
    CoreDataSingleton *coreRequest = [CoreDataSingleton sharedManager];
    NSString *userID=[coreRequest getCurrentUserID];
    ServerRequest *serverRequest = [ServerRequest sharedManager];
    self.currentUser=[serverRequest getUserInfoFromServer:userID];
    self.currentUser.userID = userID;
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"CaviarDreams" size:15.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButton:)];
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(filterButtonPressed:)];
    NSArray *buttonArray = @[searchButton,filterButton];
    
    self.navigationItem.rightBarButtonItems = buttonArray;
    
  
}
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if(!self.searchTerm){
        self.searchTerm = @"http://api.shopstyle.com/action/apiSearch?pid=uid1361-25624519-1&format=json&fts=Tops&fl=p20&count=250"; //p50 is price filter
    }
    
    NSURL *url = [NSURL URLWithString:self.searchTerm];
    NSData *data=[NSData dataWithContentsOfURL:url];
    NSError *error=nil;
    
    if (data) {
        id response=[NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:&error];
        NSMutableDictionary *results = (NSMutableDictionary*) response;
        self.arrayOfResults = [[results objectForKey:@"products"]mutableCopy];
        [self shuffleArray];
    }
    
}

- (void)shuffleArray {
    
    NSUInteger count = [self.arrayOfResults count];
    
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [self.arrayOfResults exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

-(void)filterButtonPressed:(id)sender{
    
    [self performSegueWithIdentifier:@"showFilter" sender:self];
    self.searchTerm=nil;
}

- (CGSize)collectionViewContentSize{

    NSInteger rowCount = [self.collectionView numberOfSections] / 2;
    
    if ([self.collectionView numberOfSections] % 2) rowCount++;
    
    CGFloat height = 10+ rowCount * 250 + (rowCount - 1) * 10 + 10;
    
    return CGSizeMake(self.collectionView.bounds.size.width, height);
}

#pragma mark <UICollectionViewDataSource>
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
   
    return CGSizeMake(self.view.bounds.size.width/2-15, collectionView.bounds.size.width);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.arrayOfResults count];
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
   
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        NSMutableDictionary *item = self.arrayOfResults[indexPath.row];
        NSString *imageString=[item[@"images"][3] objectForKey:@"url"];
        NSURL *imageURL = [NSURL URLWithString:imageString];
        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        UIImage *itemImage = [UIImage imageWithData: data];
        
        //this will set the image when loading is finished
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.backgroundColor=[UIColor whiteColor];
            UIImageView *imageView = (UIImageView*)[cell viewWithTag:-1];
            imageView.image=itemImage;
            imageView.contentMode=UIViewContentModeScaleAspectFit;
        });
    });

    //this will start the image loading in background
    UIButton *likeButton = (UIButton *)[cell viewWithTag:-2];
    //will change
    likeButton.selected=NO;
    [likeButton addTarget:self action:@selector(likeButtonClicked:withEvent:) forControlEvents:UIControlEventTouchUpInside];

    
    
    return cell;
}

- (IBAction)searchButton:(id)sender {
    
    [UIView animateWithDuration:0.5 animations:^{
        // animation 1
        [self.collectionView setContentOffset:
         CGPointMake(0, -self.collectionView.contentInset.top) animated:YES];
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.5 animations:^{
             self.collectionView.frame = CGRectMake(0, 0, self.collectionView.frame.size.width, self.collectionView.frame.size.height+self.header.frame.size.height);
       
        }];
    }];
    
}

- (NSIndexPath*)indexPathForEvent:(id)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.collectionView];
    
    return [self.collectionView indexPathForItemAtPoint:currentTouchPosition];
    
}

-(IBAction)likeButtonClicked:(id)sender withEvent:(UIEvent*)event {
    
    UIButton *button = (UIButton*)sender;
    button.selected=YES;
    NSIndexPath *buttonIndexPath = [self indexPathForEvent:event];
    NSDictionary *item= [self.arrayOfResults objectAtIndex:buttonIndexPath.row];
    ServerRequest *serverRequest = [ServerRequest sharedManager];
    [serverRequest saveLikedItem:item forUser:self.currentUser.userID];
    
    [self.collectionView performBatchUpdates:^{
        [self.arrayOfResults removeObjectAtIndex:buttonIndexPath.row];

        [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:buttonIndexPath]];
        
    } completion:^(BOOL finished) {
    
    }];
}

- (IBAction)DropDownSingle:(id)sender {
    
    [Dropobj fadeOut];
    
    if(isShowingMenu)
    {
        isShowingMenu = NO;
    } else
    {
        [self showPopUpWithTitle:@"  " withOption:categoryList xy:CGPointMake(0, 15) size:CGSizeMake(160, 370) isMultiple:NO];
        isShowingMenu=YES;
    }
}

-(CGSize)GetHeightDyanamic:(UILabel*)lbl
{
    NSRange range = NSMakeRange(0, [lbl.text length]);
    CGSize constraint;
    constraint= CGSizeMake(288 ,MAXFLOAT);
    CGSize size;
    
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)) {
        NSDictionary *attributes = [lbl.attributedText attributesAtIndex:0 effectiveRange:&range];
        CGSize boundingBox = [lbl.text boundingRectWithSize:constraint options: NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        
        size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    } else{
        
        size = [lbl.text sizeWithFont:[UIFont fontWithName:@"CaviarDreams" size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    return size;
}

-(void)showPopUpWithTitle:(NSString*)popupTitle withOption:(NSArray*)arrOptions xy:(CGPoint)point size:(CGSize)size isMultiple:(BOOL)isMultiple{
    
    
    Dropobj = [[DropDownListView alloc] initWithTitle:popupTitle options:arrOptions xy:point size:size isMultiple:isMultiple];
    Dropobj.delegate = self;
    Dropobj.searchDelegate=self;
    [Dropobj showInView:self.view animated:YES];
    
    /*----------------Set DropDown backGroundColor-----------------*/
    [Dropobj SetBackGroundDropDwon_R:1.0 G:1.0 B:1.0 alpha:0.25];
    
}
- (void)DropDownListView:(DropDownListView *)dropdownListView didSelectedIndex:(NSInteger)anIndex{
    NSLog(@"clicked");
    [self searchThisTerm:anIndex];
}

-(void)searchThisTerm:(NSInteger)index{
    isShowingMenu=NO;
    
    NSString *searchString= [categoryList objectAtIndex:index];
    NSString *searchTerm =[searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //this will start the image loading in background
    dispatch_async(concurrentQueue, ^{
        
        if(!self.categoryFilter){
            self.categoryFilter=@"";
        }
        
        if(!self.priceFilter){
            self.priceFilter=@"";
        }
        self.searchTerm = [NSString stringWithFormat:@"http://api.shopstyle.com/action/apiSearch?pid=uid1361-25624519-1&format=json&fts=%@+%@&%@&count=250",self.categoryFilter,searchTerm, self.priceFilter];
        NSLog(@"searching:%@",self.searchTerm);
        NSURL *url = [NSURL URLWithString:self.searchTerm];
        NSData *data=[NSData dataWithContentsOfURL:url];
        NSError *error=nil;
        id response=[NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:&error];
        NSMutableDictionary *results = (NSMutableDictionary*) response;
        self.arrayOfResults = [results objectForKey:@"products"];

        //this will set the image when loading is finished
        dispatch_async(dispatch_get_main_queue(), ^{

            [self.collectionView performBatchUpdates:^{
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            } completion:nil];
            

        
        });
    });
   

}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *selectedItem = [self.arrayOfResults objectAtIndex:indexPath.row];
    ShowItemViewController *newViewController = [[ShowItemViewController alloc] initWithNibName:@"ShowItemViewController" bundle:nil];
    
    newViewController.item = selectedItem;
    newViewController.imageURL = [selectedItem[@"images"][3] objectForKey:@"url"];
    newViewController.likeDelegate=self;
    newViewController.fromViewController=@"ShoppingViewController";
    newViewController.index=indexPath.row;
   
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.collectionView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Blur the UIImage with a CIFilter
    CIImage *imageToBlur = [CIImage imageWithCGImage:viewImage.CGImage];
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:imageToBlur forKey: @"inputImage"];
    [gaussianBlurFilter setValue:[NSNumber numberWithFloat: 10] forKey: @"inputRadius"];
    CIImage *resultImage = [gaussianBlurFilter valueForKey: @"outputImage"];
    UIImage *endImage = [[UIImage alloc] initWithCIImage:resultImage];
    
    //Place the UIImage in a UIImageView
   blurredView = [[UIImageView alloc] initWithFrame:CGRectMake(newViewController.view.frame.origin.x-50,newViewController.view.frame.origin.y-50,500,800)];
    blurredView.image = endImage;
    newViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    newViewController.delegate=self;
    [self presentViewController:newViewController animated:YES completion:nil];
    [self.view addSubview:blurredView];
   
   
}
-(void)removeBlur{
    [@[blurredView] makeObjectsPerformSelector: @selector(removeFromSuperview)];
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)cv viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    
        
      self.header = [cv dequeueReusableSupplementaryViewOfKind:kind
                                                    withReuseIdentifier:@"Header"
                                                           forIndexPath:indexPath];
    UISearchBar *searchBar = (UISearchBar*)[self.header viewWithTag:10];
    searchBar.delegate = self;
    
    return self.header;
}
//right now we randomize results every time
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    NSString *searchTerm =[searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //this will start the image loading in background
    dispatch_async(concurrentQueue, ^{
        if(!self.categoryFilter){
            self.categoryFilter=@"";
        }
        
        if(!self.priceFilter){
            self.priceFilter=@"";
        }
        self.searchTerm = [NSString stringWithFormat:@"http://api.shopstyle.com/action/apiSearch?pid=uid1361-25624519-1&format=json&fts=%@+%@&%@&count=250",self.categoryFilter,searchTerm, self.priceFilter ];
        NSLog(@"searching:%@",self.searchTerm);
        NSURL *url = [NSURL URLWithString:self.searchTerm];
        NSData *data=[NSData dataWithContentsOfURL:url];
        NSError *error=nil;
        id response=[NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:&error];
        NSMutableDictionary *results = (NSMutableDictionary*) response;
        self.arrayOfResults = [results objectForKey:@"products"];
        [self shuffleArray];
        
        //this will set the image when loading is finished
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView performBatchUpdates:^{
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            } completion:nil];

             searchBar.text=nil;
            
        });
    });

    
   
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    FilterViewController *other = [segue destinationViewController];
    other.delegate = self;
}

-(void)updateSearch:(NSString *)searchTerm forFilter:(NSString*) categoryFilter :(NSString*)priceFilter{
    
    NSLog(@"delegate called!!!");
    self.searchTerm = searchTerm;
    self.categoryFilter=categoryFilter;
    self.priceFilter=priceFilter;
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];

    
}

-(void)removeItemFromMainviewAtIndex:(NSInteger)index
{
    [self.arrayOfResults removeObjectAtIndex:index];
         
    [self.collectionView reloadData];
         
}


@end
