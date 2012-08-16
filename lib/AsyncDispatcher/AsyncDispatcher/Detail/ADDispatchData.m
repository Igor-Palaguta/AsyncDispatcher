#import "ADDispatchData.h"

#import "ADDispatchArcDefs.h"

@interface ADDispatchData ()

@property ( nonatomic, AD_DISPATCH_PROPERTY ) dispatch_data_t dispatchData;

@end

@implementation ADDispatchData

@synthesize dispatchData = _dispatch_data;

-(void)dealloc
{
   AD_DISPATCH_RELEASE( _dispatch_data );
}

-(id)initWithData:( dispatch_data_t )data_
{
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
      NSData* data_ = [ [ NSData alloc ] initWithBytes: buffer_ length: size_ ];
      AD_DISPATCH_RELEASE( new_data_ );
      return data_;
   }
   return nil;
}

@end
