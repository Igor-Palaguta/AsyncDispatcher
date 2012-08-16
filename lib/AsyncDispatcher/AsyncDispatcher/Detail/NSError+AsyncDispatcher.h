#import <Foundation/Foundation.h>

extern NSString* const ADAsyncDispatcherErrorDomain;

@interface NSError (AsyncDispatcher)

+(id)errorWithErrno:( int )errno_;

@end
