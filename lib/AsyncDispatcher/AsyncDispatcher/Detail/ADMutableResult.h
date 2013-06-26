#import "../ADResult.h"

#import <Foundation/Foundation.h>

@interface ADMutableResult : NSObject< ADMutableResult >

@property ( strong ) id result;
@property ( strong ) NSError* error;
@property ( assign, getter=isCancelled ) BOOL cancelled;

-(id)initWithResult:( id )result_
              error:( NSError* )error_;

-(id)initWithResult:( id )result_;
-(id)initWithError:( NSError* )error_;

+(id)cancelledResult;

@end
