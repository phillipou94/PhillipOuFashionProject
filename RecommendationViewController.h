//
//  RecommendationViewController.h
//  PhillipFashionProject
//
//  Created by Phillip Ou on 11/10/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "ShowItemViewController.h"
#import "DropDownListView.h"

@interface RecommendationViewController : UIViewController <UIScrollViewDelegate,kDropDownListViewDelegate, UISearchBarDelegate, startSearchDelegate>{
    DropDownListView * Dropobj;
}
@property (nonatomic, strong) UIImage *profileImage;
@property (nonatomic, strong) User *selectedUser;


@end
