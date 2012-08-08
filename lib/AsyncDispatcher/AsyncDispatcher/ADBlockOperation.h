#import "ADOperation.h"
#import "ADBlockDefs.h"

#import <Foundation/Foundation.h>

/** Executes worker block asynhronously
 */
@interface ADBlockOperation : ADOperation

/** Returns an initialized ADBlockOperation object
 @param name_ operation name
 @param worker_ block that will be executed asynchronously
 */
-(id)initWithName:( NSString* )name_
           worker:( ADWorkerBlock )worker_;

@end
