//
//  ShoppingViewController.h
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownListView.h"


@interface ShoppingViewController : UICollectionViewController<startSearchDelegate,kDropDownListViewDelegate>{
    
    DropDownListView * Dropobj;
}
@property (retain, nonatomic) IBOutlet UIButton *btnSelect;
@property (strong, nonatomic) IBOutlet UILabel *lblSelectedCountryNames;



@end
