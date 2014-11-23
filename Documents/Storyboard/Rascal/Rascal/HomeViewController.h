//
//  HomeViewController.h
//  Rascal
//
//  Created by Phillip Ou on 6/29/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <Parse/Parse.h>


@interface HomeViewController : PFQueryTableViewController


@property (nonatomic, strong) PFObject *message;
@property (nonatomic, strong) NSMutableArray *topPhotos;







@end
