#import "ADDispatchData.h"

#import "ADDispatchArcDefs.h"
#import "ADSystemVersion.h"

static dispatch_data_t no_copy_dispatch_data( const void* buffer_, NSUInteger length_ )
{
   return dispatch_data_create(buffer_
                               , length_
                               , dispatch_get_current_queue() //Don't copy buffer
                               , ^(){} );
}

@interface ADDispatchData ()

@property ( nonatomic, AD_DISPATCH_PROPERTY ) dispatch_data_t dispatchData;

@end

@implementation ADDispatchData

@synthesize dispatchData = _dispatch_data;

-(void)dealloc
{
   AD_DISPATCH_RELEASE( _dispatch_data );
}

-(id)init
{
   return [ self initWithData: 0 ];
}

-(id)initWithData:( dispatch_data_t )data_
{
   BOOL is_available_ = AD_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO( @"5.0" );
   NSAssert( is_available_, @"ADDispatchData is available only in 5.0" );
   if ( !is_available_ )
      return nil;

   if ( !data_ )
      return nil;

   self = [ super init ];
   if ( self )
   {
      self.dispatchData = data_;
      AD_DISPATCH_RETAIN( self.dispatchData );
   }

   return self;
}

-(id)initWithBuffer:( const void* )buffer_
             length:( NSUInteger )length_
{
   self = [ super init ];
   if ( self )
   {
      self.dispatchData = no_copy_dispatch_data( buffer_, length_ );
   }

   return self;
}

-(void)addBuffer:( const void* )buffer_
          length:( NSUInteger )length_
{
   dispatch_data_t new_chunk_ = no_copy_dispatch_data( buffer_, length_ );

   dispatch_data_t old_data_ = self.dispatchData;

   self.dispatchData = dispatch_data_create_concat( old_data_,new_chunk_ );

   AD_DISPATCH_RELEASE( old_data_ );
}

-(BOOL)eachChunk:( ADChunkHandlerBlock )chunk_block_
{
   return dispatch_data_apply
   ( self.dispatchData, ^bool( dispatch_data_t data_
                              , size_t offset_
                              , const void *buffer_
                              , size_t size_ )
    {
       return chunk_block_( buffer_, size_ );
    });
}

-(NSUInteger)size
{
   return dispatch_data_get_size( self.dispatchData );
}

-(NSData*)data
{
   const void* buffer_ = 0;
   size_t size_ = 0;
   dispatch_data_t new_data_ = dispatch_data_create_map( self.dispatchData, &buffer_, &size_ );
   if ( new_data_ )
   {
      NSData* data_ = [ NSData dataWithBytes: (void*)buffer_ length: size_ ];
      AD_DISPATCH_RELEASE( new_data_ );
      return data_;
   }
   return nil;
}

-(NSString*)string
{
   const void* buffer_ = 0;
   size_t size_ = 0;
   dispatch_data_t new_data_ = dispatch_data_create_map( self.dispatchData, &buffer_, &size_ );
   if ( new_data_ )
   {
      NSString* string_ = [ [ NSString alloc ] initWithBytes: (void*)buffer_
                                                      length: size_
                                                    encoding: NSUTF8StringEncoding ];

      AD_DISPATCH_RELEASE( new_data_ );
      return string_;
   }
   return nil;
}

@end
