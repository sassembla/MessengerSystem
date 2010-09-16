//
//  main.m
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/08/29.
//  Copyright KISSAKI 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal;
	NSLog(@"アプリケーション開始");
	@try {
		retVal = UIApplicationMain(argc, argv, nil, nil);
	}
	@catch (NSException * e) {
		NSLog(@"exception_", e);
	}
	@finally {
		
	}
    
    [pool release];
    return retVal;
}
