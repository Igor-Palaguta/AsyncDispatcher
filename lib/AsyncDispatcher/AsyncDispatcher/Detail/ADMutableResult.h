#import "../ADResult.h"

#import <Foundation/Foundation.h>

@interface ADMutableResult : NSObject< ADMutableResult >

@property ( nonatomic, strong ) id result;
@property ( nonatomic, strong ) NSError* error;
@property ( nonatomic, assign, getter=isCancelled ) BOOL cancelled;

-(id)initWithResult:( id )result_
              error:( NSError* )error_;

-(id)initWithResult:( id )result_;
-(id)initWithError:( NSError* )error_;

+(id)cancelledResult;

@end