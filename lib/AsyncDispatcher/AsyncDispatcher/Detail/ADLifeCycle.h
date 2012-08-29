#import <Foundation/Foundation.h>

@class ADOperation;

@protocol ADLifeCycle <NSObject>

-(void)birth:( ADOperation* )operation_;
-(void)death:( ADOperation* )operation_;

@end
