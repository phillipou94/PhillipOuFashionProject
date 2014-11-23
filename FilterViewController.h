//
//  FilterViewController.h
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/28/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol updateSearchDelegate
-(void)updateSearch:(NSString *)searchTerm forFilter:(NSString*) categoryFilter :(NSString*)priceFilter;
@end

@interface FilterViewController : UITableViewController
@property (nonatomic, weak) id <updateSearchDelegate> delegate;

@end
