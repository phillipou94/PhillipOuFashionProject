//
//  ProfileViewController.h
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController<UIImagePickerControllerDelegate,UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, readonly) UICollectionView *collectionView;
@property (nonatomic, readonly) UICollectionReusableView *header;


@end
