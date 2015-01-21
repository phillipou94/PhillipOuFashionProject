//
//  TinderStyleViewController.m
//  Formwear
//
//  Created by Phillip Ou on 11/27/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import "TinderStyleViewController.h"
#import "DraggableView.h"
#import "ServerRequest.h"
#import "CoreDataSingleton.h"
#import "User.h"

@interface TinderStyleViewController ()
@property (strong, nonatomic) IBOutlet DraggableView *draggableView;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) NSMutableArray *arrayOfRecs;
@property (strong, nonatomic) NSMutableArray *arrayOfCards;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;


@end

@implementation TinderStyleViewController{
    NSInteger currentIndex;
}


-(void)viewDidLoad {
    [super viewDidLoad];
    [self getUserInfo];
    currentIndex=-1;
    self.arrayOfCards = [[NSMutableArray alloc]init];
    self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragged:)];
   // self.draggableView = [[DraggableView alloc]init];

    ServerRequest *request = [ServerRequest sharedManager];
    self.arrayOfRecs=[[request getRecommendationsforUserID:self.currentUser.userID] mutableCopy];
    [self.draggableView addGestureRecognizer:self.panGesture];
    [self.draggableView loadImageAndStyle];
    NSInteger offset=0;
    for(int i =0; i<5;i++) {
        offset+=2;
        DraggableView *dragView = [[DraggableView alloc]init];
        dragView.tag=i;
        dragView.backgroundColor=[UIColor greenColor];
       
        [self.view insertSubview:dragView belowSubview:self.draggableView];
        CGRect newFrame = CGRectMake(self.draggableView.frame.origin.x+offset, self.draggableView.frame.origin.y+offset, self.draggableView.frame.size.width-285, self.draggableView.frame.size.height-40);
        dragView.frame=newFrame;
        [self.arrayOfCards addObject:dragView];
    }
    
  
}

-(void)getUserInfo {
    CoreDataSingleton *coreRequest = [CoreDataSingleton sharedManager];
    NSString *userID=[coreRequest getCurrentUserID];
    ServerRequest *serverRequest = [ServerRequest sharedManager];
    self.currentUser=[serverRequest getUserInfoFromServer:userID];
    self.currentUser.userID = userID;
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

-(void)dragged:(UIPanGestureRecognizer *)gestureRecognizer {
    CGFloat xDistance = [gestureRecognizer translationInView:self.draggableView].x;
    CGFloat yDistance = [gestureRecognizer translationInView:self.draggableView].y;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            self.draggableView.originalPoint = self.draggableView.center;
            break;
        };
        case UIGestureRecognizerStateChanged:{
            CGFloat rotationStrength = MIN(xDistance / 320, 1);
            CGFloat rotationAngel = (CGFloat) (2*M_PI * rotationStrength / 16);
            CGFloat scaleStrength = 1 - fabsf(rotationStrength) / 4;
            CGFloat scale = MAX(scaleStrength, 0.93);
            self.draggableView.center = CGPointMake(self.draggableView.originalPoint.x + xDistance, self.draggableView.originalPoint.y + yDistance);
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            self.draggableView.transform = scaleTransform;
            [self updateOverlay:xDistance];
            
            break;
        };
        case UIGestureRecognizerStateEnded: {
            [self resetViewPositionAndTransformations];
            self.draggableView.alpha=1.0;
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }


}

- (void)updateOverlay:(CGFloat)distance
{
    if (distance > 0) {
        //right swipe
        
    } else if (distance <= 0) {
        //left swipe
    }
    CGFloat overlayStrength = MIN(fabsf(distance) / 100, 0.4);
    self.draggableView.alpha = overlayStrength;
    
}

-(void)resetViewPositionAndTransformations {
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.draggableView.center = self.draggableView.originalPoint;
                         self.draggableView.transform = CGAffineTransformMakeRotation(0);
                         self.draggableView.hidden=YES;
                         NSLog(@"CALLED:");
                         
                         
                         
                     }];
   // self.draggableView.hidden=NO;
  [NSTimer scheduledTimerWithTimeInterval:0.3    target:self    selector:@selector(reload)    userInfo:nil repeats:NO];

}

-(void)reload{
    self.draggableView.hidden=NO;
    NSLog(@"CALLED:");
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
