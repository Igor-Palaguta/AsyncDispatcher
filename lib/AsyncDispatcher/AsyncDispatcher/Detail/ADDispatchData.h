#import "../ADBuffer.h"

#import <Foundation/Foundation.h>

@interface ADDispatchData : NSObject< ADBuffer >

-(id)initWithData:( dispatch_data_t )data_;

@end
