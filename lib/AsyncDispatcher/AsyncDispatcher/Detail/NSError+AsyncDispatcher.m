#import "NSError+AsyncDispatcher.h"

#include <string.h>

NSString* const ADAsyncDispatcherErrorDomain = @"com.AsyncDispatcher";

@implementation NSError (AsyncDispatcher)

+(id)errorWithErrno:( int )errno_
{
   if ( errno_ == 0 )
      return nil;

   const char* error_c_str_ = strerror( errno_ );
   NSString* error_str_ = error_c_str_
      ? [ NSString stringWithFormat: @"%s", error_c_str_ ]
      : [ NSString stringWithFormat: @"Error number: %d", errno_ ];

   return [ self errorWithDomain: @"com.AsyncDispatcher"
                            code: errno_
                        userInfo: [ NSDictionary dictionaryWithObject: error_str_ forKey: NSLocalizedDescriptionKey ] ];
}

@end
