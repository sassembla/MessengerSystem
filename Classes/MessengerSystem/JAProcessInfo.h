//
//  JAProcessInfo.h
//  TestKitTesting
//
//  Created by ToruInoue on 10/09/01.
//  Copyright 2010 NOT KISSAKI. All rights reserved.
//

/**
 これらのソースは、
 Blog
 http://jongampark.wordpress.com/2008/01/26/a-simple-objectie-c-class-for-checking-if-a-specific-process-is-running/
 より抜粋した物です。
 
 */

//#import <Cocoa/Cocoa.h> //古いのか？ 手直しが必要だった。下記インポートに切り替え。
#import <Foundation/Foundation.h>



@interface JAProcessInfo : NSObject {
	
@private
    int numberOfProcesses;
    NSMutableArray *processList;
}
- (id) init;
- (int)numberOfProcesses;
- (void)obtainFreshProcessList;
- (BOOL)findProcessWithName:(NSString *)procNameToSearch;
@end