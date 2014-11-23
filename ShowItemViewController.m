//
//  ShowItemViewController.m
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import "ShowItemViewController.h"

@interface ShowItemViewController ()
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *brandLabel;
@property (strong, nonatomic) IBOutlet UIButton *buyButton;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *referButton;


@end

@implementation ShowItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate removeBlur];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
