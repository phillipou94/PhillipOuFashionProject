//
//  ShoppingViewController.h
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownListView.h"
#import "ShowItemViewController.h"
#import "FilterViewController.h"


@interface ShoppingViewController : UICollectionViewController<startSearchDelegate,kDropDownListViewDelegate,removeBlurDelegate,UISearchBarDelegate, updateSearchDelegate>{
    
    DropDownListView * Dropobj;
}




@end
