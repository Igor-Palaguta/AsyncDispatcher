#import "ADOperation.h"
#import "ADBlockDefs.h"

#import <Foundation/Foundation.h>

/** Executes worker block asynhronously
 */
@interface ADBlockOperation : ADOperation

/** Returns an initialized ADBlockOperation object
 @param worker_ block that will be executed asynchronously
 @param name_ operation name
 */
-(id)initWithWorker:( ADWorkerBlock )worker_
               name:( NSString* )name_;

@end
