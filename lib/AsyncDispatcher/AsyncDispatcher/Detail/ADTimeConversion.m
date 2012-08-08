#import "ADTimeConversion.h"

dispatch_time_t ADDispatchTimeSinceNow( NSTimeInterval time_interval_ )
{
   return dispatch_time( DISPATCH_TIME_NOW, time_interval_ * NSEC_PER_SEC );
}
