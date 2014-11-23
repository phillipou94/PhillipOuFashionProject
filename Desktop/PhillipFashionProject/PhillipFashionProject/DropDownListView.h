//
//  DropDownListView.h
//  KDropDownMultipleSelection
//
//  Created by macmini17 on 03/01/14.
//  Copyright (c) 2014 macmini17. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol startSearchDelegate
-(void)searchThisTerm:(NSInteger*)index;
@end



@protocol kDropDownListViewDelegate;
@interface DropDownListView : UIView<UITableViewDataSource,UITableViewDelegate>{

    UITableView *_kTableView;
    NSString *_kTitleText;
    NSArray *_kDropDownOption;
    CGFloat R,G,B,A;
    BOOL isMultipleSelection;
}
@property(nonatomic,strong)NSMutableArray *arryData;
@property (nonatomic, assign) id<kDropDownListViewDelegate> delegate;
@property (nonatomic, assign) id <startSearchDelegate>searchDelegate;
- (void)fadeOut;
- (id)initWithTitle:(NSString *)aTitle options:(NSArray *)aOptions xy:(CGPoint)point size:(CGSize)size isMultiple:(BOOL)isMultiple;
- (void)showInView:(UIView *)aView animated:(BOOL)animated;
-(void)SetBackGroundDropDwon_R:(CGFloat)r G:(CGFloat)g B:(CGFloat)b alpha:(CGFloat)alph;
@end


@protocol kDropDownListViewDelegate <NSObject>
- (void)DropDownListView:(DropDownListView *)dropdownListView didSelectedIndex:(NSInteger)anIndex;
- (void)DropDownListView:(DropDownListView *)dropdownListView Datalist:(NSMutableArray*)ArryData;
- (void)DropDownListViewDidCancel;
@end

