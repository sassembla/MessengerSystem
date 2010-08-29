//
//  MessageSystemTest.h
//  Qlippy
//
//  Created by Inoue 徹 on 10/06/09.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageSystem.h"

@interface MessageSystemTest : NSObject {
	
	MessageSystem * messenger_default_observer;
	MessageSystem * messenger_default_reciever;
	
	MessageSystem * messenger_test1_observer;
	MessageSystem * messenger_test1_reciever;
	
	MessageSystem * messenger_test2_observer;
	MessageSystem * messenger_test2_reciever;
}

- (id) initTest;
- (void) setup;
- (void) go;

@end
