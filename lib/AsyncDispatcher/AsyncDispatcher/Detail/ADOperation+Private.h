#import "../ADOperation.h"
#import "../ADBlockDefs.h"

@protocol ADRequest;

@class ADDispatchQueue;
@class ADOperationMonitor;

@interface ADOperation (Private)

-(ADQueueBlock)queueBlockForRequest:( id< ADRequest > )request_
                          doneBlock:( ADDoneBlock )client_done_block_;

-(ADQueueBlock)queueBlockForRequest:( id< ADRequest > )request_
                          doneBlock:( ADDoneBlock )client_done_block_
                            context:( id )context_;

//Caller done block can be used when caller want to know when process is completed
-(id< ADRequest >)asyncWithDoneBlock:( ADDoneBlock )done_block_;

-(id< ADRequest >)asyncWithDoneBlock:( ADDoneBlock )client_done_block_
                             inQueue:( ADDispatchQueue* )queue_;

-(void)asyncWithDoneBlock:( ADDoneBlock )client_done_block_
                  inQueue:( ADDispatchQueue* )queue_
              withMonitor:( ADOperationMonitor* )monitor_;

@end
