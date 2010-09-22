//
//  TestKitTestingAppDelegate.h
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/08/29.
//  Copyright KISSAKI 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MessengerSystem.h"

@interface TestKitTestingAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	MessengerSystem * paren;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

- (void)test:(NSNotification * )notification;
- (void) testResetParent;

@end

