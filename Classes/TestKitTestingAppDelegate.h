//
//  TestKitTestingAppDelegate.h
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/08/29.
//  Copyright KISSAKI 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestKitTestingAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;}

@property (nonatomic, retain) IBOutlet UIWindow *window;
- (void)test:(NSNotification * )notification;


@end

