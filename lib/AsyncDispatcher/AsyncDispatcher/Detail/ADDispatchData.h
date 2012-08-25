#import "../ADBuffer.h"

#import <Foundation/Foundation.h>

@interface ADDispatchData : NSObject< ADMutableBuffer >

-(id)initWithData:( dispatch_data_t )data_;

-(id)initWithBuffer:( const void* )buffer_
             length:( NSUInteger )length_;

@end
