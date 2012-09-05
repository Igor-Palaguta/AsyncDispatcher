#import "../ADRequest.h"

#import <Foundation/Foundation.h>

@interface ADRequestHolder : NSObject< ADRequest >

@property ( nonatomic, strong ) id< ADRequest > request;

@end
