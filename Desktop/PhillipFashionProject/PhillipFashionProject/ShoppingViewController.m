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
@property (nonatomic, strong) NSArray *arrayOfResults;

@property (nonatomic,strong) User *currentUser;

@end

@implementation ShoppingViewController{
    NSArray *categoryList;
    BOOL isShowingMenu;
}

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    isShowingMenu=NO;
    categoryList=@[@"Men's Shirts", @"Women's Tops", @"Dresses", @"Jeans",@"Accessoies", @"Jackets", @"Shorts"];
    NSString *urlString = @"http://api.shopstyle.com/action/apiSearch?pid=uid1361-25624519-1&format=json&fts=Tops&min=0&count=1000";
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data=[NSData dataWithContentsOfURL:url];
    NSError *error=nil;
    id response=[NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:&error];
    NSMutableDictionary *results = (NSMutableDictionary*) response;
    self.arrayOfResults = [results objectForKey:@"products"];
    
    CoreDataSingleton *coreRequest = [CoreDataSingleton sharedManager];
    NSString *userID=[coreRequest getCurrentUserID];
    
    ServerRequest *serverRequest = [ServerRequest sharedManager];
    self.currentUser=[serverRequest getUserInfoFromServer:userID];
    
    
    //NSLog(@"Your JSON Object: %@",self.arrayOfResults);
    
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    
    // Do any additional setup after loading the view.
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

-(UIButton *)makeLikeButtonForCell:(UICollectionViewCell *)cell
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor=[UIColor redColor];
    
    CGFloat width = 50;
    CGFloat height = 50;
    CGFloat X = cell.frame.size.width - width;
    CGFloat Y = 0;
    
    button.frame = CGRectMake(X, Y, width, height);
    
    [button addTarget:self
               action:@selector(likeButtonClicked:withEvent:)
     forControlEvents:UIControlEventTouchUpInside];
    
    return button;
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
            UIButton *likeButton = [self makeLikeButtonForCell:cell];
            likeButton.tag = indexPath.row;
            cell.backgroundView = [[UIImageView alloc] initWithImage:itemImage];
            cell.backgroundView.contentMode = UIViewContentModeScaleAspectFit;
            cell.backgroundColor = [UIColor whiteColor];
            [cell addSubview:likeButton];
        });
    });
    
    UIButton *likeButton = (UIButton*)[cell viewWithTag:-1];
    [likeButton addTarget:self action:@selector(likeButtonClicked:withEvent:) forControlEvents:UIControlEventTouchUpInside];

    
    
    return cell;
}

- (NSIndexPath*)indexPathForEvent:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.collectionView];
    return [self.collectionView indexPathForItemAtPoint:currentTouchPosition];
    
}

-(IBAction)likeButtonClicked:(id)sender withEvent:(UIEvent*)event {
    
    UIButton *button = (UIButton*)sender;
    long index = button.tag;
    NSDictionary *item= [self.arrayOfResults objectAtIndex:index];
    ServerRequest *serverRequest = [ServerRequest sharedManager];
    [serverRequest saveLikedItem:item forUser:self.currentUser];
    
    
    
}

- (IBAction)DropDownSingle:(id)sender {
    [Dropobj fadeOut];
    if(isShowingMenu){
        isShowingMenu = NO;
    }
    else{
        [self showPopUpWithTitle:@"  " withOption:categoryList xy:CGPointMake(0, 15) size:CGSizeMake(120, 280) isMultiple:NO];
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
    }
    else{
        
        
        size = [lbl.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    }
    return size;
}

-(void)showPopUpWithTitle:(NSString*)popupTitle withOption:(NSArray*)arrOptions xy:(CGPoint)point size:(CGSize)size isMultiple:(BOOL)isMultiple{
    
    
    Dropobj = [[DropDownListView alloc] initWithTitle:popupTitle options:arrOptions xy:point size:size isMultiple:isMultiple];
    Dropobj.delegate = self;
    Dropobj.searchDelegate=self;
    [Dropobj showInView:self.view animated:YES];
    
    /*----------------Set DropDown backGroundColor-----------------*/
    [Dropobj SetBackGroundDropDwon_R:0.0 G:108.0 B:194.0 alpha:0.70];
    
}
- (void)DropDownListView:(DropDownListView *)dropdownListView didSelectedIndex:(NSInteger)anIndex{
    /*----------------Get Selected Value[Single selection]-----------------*/
    self.title=[categoryList objectAtIndex:anIndex];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if ([touch.view isKindOfClass:[UIView class]]) {
        
            [Dropobj fadeOut];
        
    }
    
}

-(void)searchThisTerm:(NSInteger*)index{
    isShowingMenu=NO;
    NSString *searchString= [categoryList objectAtIndex:index];
    NSString *searchTerm =[searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //this will start the image loading in background
    dispatch_async(concurrentQueue, ^{
        NSString *urlString = [NSString stringWithFormat:@"http://api.shopstyle.com/action/apiSearch?pid=uid1361-25624519-1&format=json&fts=%@&min=0&count=1000",searchTerm ];
        NSURL *url = [NSURL URLWithString:urlString];
        NSData *data=[NSData dataWithContentsOfURL:url];
        NSError *error=nil;
        id response=[NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:&error];
        NSMutableDictionary *results = (NSMutableDictionary*) response;
        self.arrayOfResults = [results objectForKey:@"products"];
        //this will set the image when loading is finished
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        
        });
    });
    

    
    
    
    

}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *selectedItem = [self.arrayOfResults objectAtIndex:indexPath.row];
    ShowItemViewController *newViewController = [[ShowItemViewController alloc] initWithNibName:@"ShowItemViewController" bundle:nil];
    newViewController.item = selectedItem;
    newViewController.imageURL = [selectedItem[@"images"][3] objectForKey:@"url"];
 
    [self presentModalViewController:newViewController animated:YES];
  
    

    
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
