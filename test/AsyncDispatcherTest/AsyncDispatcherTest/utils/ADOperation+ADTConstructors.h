#import <AsyncDispatcher/AsyncDispatcher.h>

#import <Foundation/Foundation.h>

typedef NSTimeInterval (^ADTDelayFunction)( NSInteger index_, NSRange range_ );

extern ADTDelayFunction ADTNoDelay(void);
extern ADTDelayFunction ADTConstDelay( NSTimeInterval delay_ );
extern ADTDelayFunction ADTDirectDelay(void);
extern ADTDelayFunction ADTIndexDelay(void);
extern ADTDelayFunction ADTReverseDelay(void);

@interface ADBlockOperation (ADTConstructors)

+(id)operationWithIndex:( NSInteger )index_
              doneBlock:( ADDoneBlock )done_block_;

+(id)operationWithIndex:( NSInteger )index_
              doneBlock:( ADDoneBlock )done_block_
                  delay:( NSTimeInterval )delay_;

+(id)operationWithName:( NSString* )name_
      errorDescription:( NSString* )description_
             doneBlock:( ADDoneBlock )done_block_;

+(id)operationWithName:( NSString* )name_
      errorDescription:( NSString* )description_
             doneBlock:( ADDoneBlock )done_block_
                 delay:( NSTimeInterval )delay_;

@end

@interface ADCompositeOperation (ADTConstructors)

+(id)compositeWithOperations:( NSArray* )operations_
                        name:( NSString* )name_
                   doneBlock:( ADDoneBlock )done_block_;

@end

@interface NSArray (ADTConstructors)

+(id)arrayWithOperationsFromRange:( NSRange )range_
                        doneBlock:( ADDoneBlock )done_block_
                    delayFunction:( ADTDelayFunction )delay_function_
                             step:( NSUInteger )step_;

+(id)arrayWithOperationsFromRange:( NSRange )range_
                        doneBlock:( ADDoneBlock )done_block_
                    delayFunction:( ADTDelayFunction )delay_function_;

+(id)arrayWithOperationsFromRange:( NSRange )range_
                        doneBlock:( ADDoneBlock )done_block_;

-(id)reverseOrder;

@end

@interface NSMutableArray (ADTConstructors)

-(void)addOperationsFromRange:( NSRange )range_
                    doneBlock:( ADDoneBlock )done_block_
                delayFunction:( ADTDelayFunction )delay_function_
                         step:( NSUInteger )step_;

-(void)addOperationsFromRange:( NSRange )range_
                    doneBlock:( ADDoneBlock )done_block_
                delayFunction:( ADTDelayFunction )delay_function_;

-(void)addOperationsFromRange:( NSRange )range_
                    doneBlock:( ADDoneBlock )done_block_;

@end
