### AsyncDispatcher - library for performing operations asynchronously ###

*   Based on GCD
*   Requires XCode >= 4.3 (was tested on 4.3, 4.5)
*   Deployment target iOS 4.3
*   Uses ARC

#### Main Features: ####
*   Simple interfaces
*   Concurrent and sequence composite operations
*   Easy cancel mechanism
*   Documentation

#### Basic: ####

*   *ADWorkerBlock* - block that will be executed asynchronously in separate thread

It must return result in case of success or error. Not both at the same time

*   *ADResult* - result of asynchronous operation

Result or error that returned worker block, and cancel flag if operations was cancelled

*   *ADDoneBlock* - block that is called when operation is completed, as parameter it takes id< ADResult >

*   *ADMutableResult* - mutable result

*   *ADTransformBlock* - block that transforms result of operation and then it passes modified result to done block

*   *ADOperation* - base class/protocol for any asynchronous operation

Any operation can have transform block, done block, name

*   *ADBlockOperation* - executes worker block asynchronously

Sample:

    ADWorkerBlock worker_ = ^id( NSError** error_ )
    {
       return [ NSNumber numberWithInteger: 1 ];
    };

    ADWorkerBlock transform_block_ = ^( id< ADMutableResult > mutable_result_ )
    {
       mutable_result_.result = [ NSNumber numberWithInteger: [ mutable_result_.result integerValue ] * 2 ];
    };

    ADDoneBlock done_block_ = ^( id< ADResult > result_ )
    {
       NSLog( @"Result: %@, error: %@, isCancelled: %d", result_.result, result_.error, result_.isCancelled );
    };

    ADBlockOperation* operation_ = [ [ ADBlockOperation alloc ] initWithWorker: worker_ name: @"Any name" ];
    operation_.doneBlock = done_block_;
    operation_.transformBlock = transform_block_;

    [ operation_ async ];

*   *ADSequence* - composite asynchronous operation that executes all operations sequentially

All operations will be executed in predefined order

Can include any type of asynchronous operation as block operation or composite operation

*   *ADConcurrent* - composite asynchronous operation that executes all operations concurrently.

All operations will be executed in any order

Can include any type of asynchronous operation as block operation or composite operation

Sample:

    ADSequence* sequence_ = [ [ ADSequence alloc ] initWithOperations: @[ operation1_, operation2_ ] name: @"sequence" ];
    
    [ sequence_ async ];

*   *ADRequest* - is returned by async call

Is useful for managing operation. Supports wait, waitForTimeInterval, cancel methods

Cancel can stop operation if it is not yet pushed to queue

If block operation is cancelled when it is in progress, worker will be completed, done block will be called with result of worker block and with isCancelled == YES.
Worker block is not executed at all if operation is not yet in queue, result of this operation will be {result: nil, error: nil, isCancelled: YES }.

If composite operation is cancelled, all active operations will be completed with cancel flag in result. And all operations that were not yet pushed to queue will have {result: nil, error: nil, isCancelled: YES } as result

Sample:

    id< ADRequest > request_ = [ sequence_ async ];
    
    //...
    [ request_ cancel ];

*   *ADCompositeResult* - result of composite operation. resultForName: - returns result of operation by name

If operation without name, result is not saved to ADCompositeResult. resultForName: can return another composite result. This operation does not work recursively.

*   *ADDoneOnMainThread (ADTransfromOnMainThread)* - functions that create done block (transform block) that is executed on main thread

If block is wrapped with ADDoneOnMainThread or ADTransfromOnMainThread and [ request_ wait ] is called on main thread is cause to deadlock

*   *ADSession* - provides mechanism for cancel all active asynchronous requests

Sample:

    [ [ ADSession sharedSession ] cancelAll ];