#import "../ADBlockDefs.h"
#import "../ADOperationPriority.h"

#import <Foundation/Foundation.h>

@interface ADDispatchQueue : NSObject

@property ( nonatomic, assign, readonly ) BOOL isConcurrent;
@property ( nonatomic, assign ) ADOperationPriority priority;

-(id)initWithName:( NSString* )name_ concurrent:( BOOL )concurrent_;

+(id)concurrentQueueWithName:( NSString* )name_;
+(id)serialQueueWithName:( NSString* )name_;

-(void)async:( ADQueueBlock )block_;

-(void)pause;
-(void)resume;

@end


@class ADOperationMonitor;

@interface ADDispatchQueue (Monitor)

-(void)async:( ADQueueBlock )block_
 withMonitor:( ADOperationMonitor* )monitor_;

-(void)reqisterCompleteBlock:( ADQueueBlock )complete_block_
                  forMonitor:( ADOperationMonitor* )monitor_;

@end
