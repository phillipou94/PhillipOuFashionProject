//
//  RecommendationViewController.m
//  PhillipFashionProject
//
//  Created by Phillip Ou on 11/10/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import "RecommendationViewController.h"
#import "DropDownListView.h"
#import "CoreDataSingleton.h"
#import "ServerRequest.h"
#import "SCLAlertView.h"
@interface RecommendationViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *arrayOfRecs;
@property (strong, nonatomic) NSString *searchTerm;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *arrayOfImages;
@property CGPoint originalCenter;

@end

@implementation RecommendationViewController{
    NSArray *categoryList;
    BOOL isShowingMenu;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self getCurrentUser];
    self.searchBar.delegate=self;
    self.tabBarController.tabBar.hidden=YES;
    isShowingMenu=NO;
    
    categoryList=[@[@"Tops", @"Dresses", @"Jeans",@"Accessories", @"Jackets", @"Shorts"]mutableCopy];
    
    self.title=@"Recommendation";
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor colorWithRed:0.70 green:0.70 blue:0.70 alpha:1.0] forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.99 green:0.99 blue:0.99 alpha:0.25];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"CaviarDreams" size:21], NSFontAttributeName, nil]];

    self.profileImageView.image=self.profileImage;
    
    self.arrayOfImages = [[NSMutableArray alloc]init];

    if(!self.searchTerm){
        self.searchTerm = @"http://api.shopstyle.com/action/apiSearch?pid=uid1361-25624519-1&format=json&fts=Tops&fl=p20&count=50"; //p50 is price filter
    }
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        
        NSURL *url = [NSURL URLWithString:self.searchTerm];
        NSData *data=[NSData dataWithContentsOfURL:url];
        NSError *error=nil;
        id response=[NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:&error];
        NSMutableDictionary *results = (NSMutableDictionary*) response;
        self.arrayOfRecs = [[results objectForKey:@"products"]mutableCopy];
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [self setupHorizontalScrollView];
            self.scrollView.delegate=self;
        });
        
    });
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.originalCenter = self.view.center;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
}

-(void)getCurrentUser {
    
    CoreDataSingleton *coreData = [CoreDataSingleton sharedManager];
    NSString *userID=[coreData getCurrentUserID];
    
    ServerRequest *serverRequest = [ServerRequest sharedManager];
    self.currentUser=[serverRequest getUserInfoFromServer:userID];
}


- (void)keyboardDidShow:(NSNotification*)notification {
    
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                             self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y-keyboardFrameBeginRect.size.height);
                     }
                     completion:nil];

}


-(void)dismissKeyboard
{
    [self.searchBar resignFirstResponder];
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.view.center = self.originalCenter;
                     }
                     completion:nil];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
   
    NSString *searchTerm =[self.searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //this will start the image loading in background
    dispatch_async(concurrentQueue, ^{

        self.searchTerm = [NSString stringWithFormat:@"http://api.shopstyle.com/action/apiSearch?pid=uid1361-25624519-1&format=json&fts=%@&fl=p20&count=50",searchTerm ];
        NSLog(@"searching:%@",self.searchTerm);
        NSURL *url = [NSURL URLWithString:self.searchTerm];
        NSData *data=[NSData dataWithContentsOfURL:url];
        NSError *error=nil;
        id response=[NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:&error];
        NSMutableDictionary *results = (NSMutableDictionary*) response;
        self.arrayOfRecs = [results objectForKey:@"products"];
        NSLog(@"new arrayOf Recs:%@", response);
        //this will set the image when loading is finished
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.arrayOfRecs count]>1){
                [self setupHorizontalScrollView];
            }
            searchBar.text=nil;
            
        });
    });
    
    
    
}

- (void)setupHorizontalScrollView
{
    
    self.scrollView.backgroundColor= [UIColor blackColor];
    
    __block CGFloat contentOffSet = 0.0f;
    
    for (int i = 0; i < [self.arrayOfRecs count]; i++)
    {
        
        NSMutableDictionary *item = self.arrayOfRecs[i];
        NSString *imageString=[item[@"images"][3] objectForKey:@"url"];
        dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //this will start the image loading in background
        dispatch_async(concurrentQueue, ^{
            NSURL *imageURL = [NSURL URLWithString:imageString];
            NSData *data = [NSData dataWithContentsOfURL:imageURL];
            UIImage *itemImage = [UIImage imageWithData: data];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(contentOffSet,0,200, self.scrollView.frame.size.height)];
                imageView.image=itemImage;
                imageView.backgroundColor=[UIColor whiteColor];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                UIButton *button = [[UIButton alloc]initWithFrame:imageView.frame];
                [button addTarget:self action:@selector(pictureTapped:) forControlEvents:UIControlEventTouchUpInside];
                [self.scrollView addSubview:button];
                button.tag = i;
                [self.scrollView addSubview:imageView];
                contentOffSet += imageView.frame.size.width*1.1;
                
            });
        });
        
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * [self.arrayOfRecs count], self.scrollView.frame.size.height);
}

-(void)pictureTapped:(id)sender
{
    if (self.searchBar.isFirstResponder){
        [self dismissKeyboard];
    } else {
        UIButton *button = (UIButton*) sender;
        NSDictionary *selectedItem = self.arrayOfRecs[button.tag];
        
        ShowItemViewController *newViewController = [[ShowItemViewController alloc] initWithNibName:@"ShowItemViewController" bundle:nil];
        newViewController.item = selectedItem;
        newViewController.imageURL = [selectedItem[@"images"][3] objectForKey:@"url"];
        newViewController.fromViewController=@"RecommendationViewController";
        newViewController.toUserImage = self.profileImage;
        newViewController.fromUser=self.currentUser;
        newViewController.toUser=self.selectedUser;
        newViewController.animationDelegate=self;
        
        [self presentViewController:newViewController animated:YES completion:nil];
    }

}

-(void)showConfirmationAnimation{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    UIColor *color = [UIColor colorWithRed:245.0/255.0 green:120.0/255.0 blue:120.0/255.0 alpha:1.0];
    [alert showCustom:self image:[UIImage imageNamed:@"whiteCheckMark"] color:color title:@"Recommendation Sent" subTitle:@"Thanks for Sharing!" closeButtonTitle:@"Done" duration:0.0f];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    [self.scrollView setContentOffset: CGPointMake(self.scrollView.contentOffset.x, 0)];
    

}
@end
