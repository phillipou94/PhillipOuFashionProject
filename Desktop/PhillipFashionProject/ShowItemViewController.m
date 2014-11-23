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

@end

@implementation ShowItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString: self.imageURL]];
    self.imageView.image = [UIImage imageWithData:data];
    self.view.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    self.priceLabel.text = [self.item objectForKey:@"priceLabel"];
    self.brandLabel.text = [self.item objectForKey:@"brandName"];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
