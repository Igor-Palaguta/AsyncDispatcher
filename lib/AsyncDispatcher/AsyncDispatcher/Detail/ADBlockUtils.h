#import "../ADBlockDefs.h"
#import "ADExport.h"

@class ADDispatchQueue;
@class ADOperationMonitor;

AD_EXPORT ADDoneBlock ADDoneBlockResumeQueue( ADDispatchQueue* queue_ );
AD_EXPORT ADDoneBlock ADDoneBlockDecrementMonitor( ADOperationMonitor* monitor_ );
