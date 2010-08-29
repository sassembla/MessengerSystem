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

@end
