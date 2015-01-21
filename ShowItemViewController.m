//
//  ShowItemViewController.m
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import "ShowItemViewController.h"
#import "ServerRequest.h"
#import "CoreDataSingleton.h"

@interface ShowItemViewController ()
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *brandLabel;
@property (strong, nonatomic) IBOutlet UIButton *buyButton;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *referButton;

@property (strong, nonatomic) IBOutlet UIButton *heartButton;

@end

@implementation ShowItemViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.heartButton.hidden=YES;
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString: self.imageURL]];
    self.imageView.image = [UIImage imageWithData:data];
    self.view.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    
    self.priceLabel.text = [self.item objectForKey:@"priceLabel"];
    [self.priceLabel setFont:[UIFont fontWithName:@"CaviarDreams-Italic" size:24.0]];
    
    self.brandLabel.text = [self.item objectForKey:@"brandName"];
    [self.brandLabel setFont:[UIFont fontWithName:@"CaviarDreams-Bold" size:17.0]];
    self.brandLabel.adjustsFontSizeToFitWidth=YES;
    
    for(UILabel * label in @[self.referButton.titleLabel,self.buyButton.titleLabel,self.likeButton.titleLabel]){
        [label setFont:[UIFont fontWithName:@"CaviarDreams-Bold" size:17.0]];
    }
    
}

- (IBAction)dismiss:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate removeBlur];
}

- (IBAction)referPressed:(id)sender {
    
    //if we know who we're recommending to already
    if ([self.fromViewController isEqualToString:@"RecommendationViewController"]) {
        
        ServerRequest *request = [ServerRequest sharedManager];
        [request sendReferal:self.item fromUser:self.fromUser toUser:self.toUser];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.animationDelegate showConfirmationAnimation];
        
    }
}
- (IBAction)likePressed:(id)sender {
    
    CoreDataSingleton *coreRequest = [CoreDataSingleton sharedManager];
    NSString *userID=[coreRequest getCurrentUserID];
    
    ServerRequest *request = [ServerRequest sharedManager];
    [request saveLikedItem:self.item forUser:userID];
    
    if ([self.fromViewController isEqualToString:@"ShoppingViewController"]) {
        
       [self.likeDelegate removeItemFromMainviewAtIndex:self.index];
    }
    
    self.heartButton.hidden=NO;

}

@end
