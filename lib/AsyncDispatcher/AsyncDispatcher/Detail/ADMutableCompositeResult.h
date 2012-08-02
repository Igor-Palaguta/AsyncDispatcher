#import "ADMutableResult.h"

#import <Foundation/Foundation.h>

@protocol ADResult;

@interface ADMutableCompositeResult : ADMutableResult< ADMutableCompositeResult >

-(void)setResult:( id< ADResult > )result_
         forName:( NSString* )name_;

-(id< ADResult >)resultForName:( NSString* )name_;

@end
