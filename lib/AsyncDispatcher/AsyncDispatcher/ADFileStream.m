#import "ADFileStream.h"

#import "ADDispatchQueue.h"
#import "ADDispatchData.h"

#import "ADDispatchArcDefs.h"
#import "ADSystemVersion.h"

#import "NSError+AsyncDispatcher.h"

#include <fcntl.h>

@interface ADFileStream ()

@property ( nonatomic, strong ) ADDispatchQueue* queue;
@property ( nonatomic, AD_DISPATCH_PROPERTY ) dispatch_io_t file;

@end

@implementation ADFileStream

@synthesize queue;
@synthesize file = _file;

-(void)dealloc
{
   if ( _file )
   {
      dispatch_io_close( _file, DISPATCH_IO_STOP );
   }
   AD_DISPATCH_RELEASE( _file );
}

-(id)initWithPath:( NSString* )path_
{
   BOOL is_available_ = AD_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO( @"5.0" );
   NSAssert( is_available_, @"ADFileStream is available only in 5.0" );
   if ( !is_available_ )
      return nil;

   NSAssert( path_, @"path can't be nil" );
   if ( !path_ )
      return nil;

   self = [ super init ];

   if ( self )
   {
      self.queue = [ ADDispatchQueue serialQueueWithName: path_ ];

      self.file = dispatch_io_create_with_path
      ( DISPATCH_IO_STREAM
       , [ path_ cStringUsingEncoding: NSUTF8StringEncoding ]
       , O_RDONLY
       , 0
       , self.queue.queue
       , nil
       );
   }

   return self;
}

-(void)read:( NSUInteger )count_
    handler:( ADReadHandlerBlock )handler_
{
   dispatch_io_read( self.file
                    , 0/*Is ignored for DISPATCH_IO_STREAM file*/
                    , count_
                    , self.queue.queue
                    , ^( bool done_, dispatch_data_t data_, int error_num_ )
                    {
                       id< ADBuffer > buffer_ = [ [ ADDispatchData alloc ] initWithData: data_ ];

                       BOOL eof_ = error_num_ == 0
                        && [ buffer_ size ] < count_;

                       NSError* error_ = [ NSError errorWithErrno: error_num_ ];

                       handler_( eof_
                                , [ [ ADDispatchData alloc ] initWithData: data_ ]
                                , error_ );
                    });
}

-(void)cyclicRead:( NSUInteger )count_
          handler:( ADReadHandlerBlock )handler_
{
   __block ADReadHandlerBlock cyclic_handler_ = ^BOOL( BOOL eof_, id< ADBuffer > buffer_, NSError* error_ )
   {
      BOOL continue_ = handler_( eof_, buffer_, error_ );

      if ( continue_ && !eof_ && error_ == nil )
      {
         [ self read: count_ handler: cyclic_handler_ ];
      }
      return continue_;
   };

   [ self read: count_ handler: cyclic_handler_ ];
}

@end
