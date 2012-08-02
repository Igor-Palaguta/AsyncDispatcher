#import "ADBlockUtils.h"

#import "ADOperationMonitor.h"
#import "ADDispatchQueue.h"

ADDoneBlock ADDoneBlockResumeQueue( ADDispatchQueue* queue_ )
{
   return ^( id< ADResult > result_ )
   {
      [ queue_ resume ];
   };
}

ADDoneBlock ADDoneBlockDecrementMonitor( ADOperationMonitor* monitor_ )
{
   return ^( id< ADResult > result_ )
   {
      [ monitor_ decrementUsage ];
   };
}
