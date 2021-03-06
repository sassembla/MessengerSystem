//
//  coTestObject.h
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/08/29.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessengerSystem.h"

@interface coTestObject : NSObject {
	MessengerSystem * messenger;
}
- (void)test:(NSNotification * )notification;

- (id) init;
- (id) init2;
- (id) init3;
- (id) init4;
- (id) init5;

- (void) setParent;
- (void) forInvocaton:(NSString * )str;

@end
