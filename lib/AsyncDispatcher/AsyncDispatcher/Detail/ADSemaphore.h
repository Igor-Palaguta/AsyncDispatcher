#import <Foundation/Foundation.h>

@interface ADSemaphore : NSObject

-(id)initWithValue:( NSUInteger )value_;
+(id)semaphoreWithValue:( NSUInteger )value_;

-(BOOL)wait;
-(BOOL)waitForTimeInterval:( NSTimeInterval )seconds_;

-(void)signal;

@end
