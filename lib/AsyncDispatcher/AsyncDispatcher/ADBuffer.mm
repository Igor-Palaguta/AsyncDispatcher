#import "ADBuffer.h"

#include <list>
#include <numeric>

namespace
{
   struct chunk_type
   {
      const void* buffer;
      NSUInteger size;
      explicit chunk_type( const void* buffer_, NSUInteger size_ )
      : buffer( buffer_ )
      , size( size_ )
      {
      }
   };

   typedef std::list< chunk_type > chunks_type;

   NSUInteger sum_size( NSUInteger previous_length_, const chunk_type& chunk_ )
   {
      return previous_length_ + chunk_.size;
   }

   NSString* to_string( const chunk_type& chunk_ )
   {
      return [ [ NSString alloc ] initWithBytesNoCopy: ( void* )chunk_.buffer
                                               length: chunk_.size
                                             encoding: NSUTF8StringEncoding
                                         freeWhenDone: NO ];
   }

   NSData* to_data( const chunk_type& chunk_ )
   {
      return [ [ NSData alloc ] initWithBytesNoCopy: ( void* )chunk_.buffer
                                             length: chunk_.size
                                       freeWhenDone: NO ];
   }

   NSMutableString* add_to_string( NSMutableString* total_string_, const chunk_type& chunk_ )
   {
      [ total_string_ appendString: to_string( chunk_ ) ];
      return total_string_;
   }

   NSMutableData* add_to_data( NSMutableData* total_data_, const chunk_type& chunk_ )
   {
      [ total_data_ appendBytes: chunk_.buffer length: chunk_.size ];
      return total_data_;
   }
}

@implementation ADMutableBuffer
{
@private
   chunks_type chunks;
}

-(id)initWithBuffer:( const void* )buffer_
             length:( NSUInteger )length_
{
   self = [ super init ];
   if ( self )
   {
      [ self addBuffer: buffer_ length: length_ ];
   }
   return self;
}

-(BOOL)eachChunk:( ADChunkHandlerBlock )chunk_block_
{
   BOOL continue_ = YES;
   for ( chunks_type::const_iterator it_ = self->chunks.begin(), end_ = self->chunks.end()
        ; continue_ && it_ != end_
        ; ++it_ )
   {
      continue_ = chunk_block_( it_->buffer, it_->size );
   }
   return continue_;
}

-(NSUInteger)size
{
   return std::accumulate( self->chunks.begin(), self->chunks.end(), 0, sum_size );
}

-(NSData*)data
{
   if ( self->chunks.size() == 1 )
   {
      return to_data( self->chunks.front() );
   }

   NSMutableData* data_ = [ NSMutableData dataWithCapacity: [ self size ] ];
   return std::accumulate( self->chunks.begin(), self->chunks.end(), data_, add_to_data );
}

-(NSString*)string
{
   if ( self->chunks.size() == 1 )
   {
      return to_string( self->chunks.front() );
   }

   NSMutableString* string_ = [ NSMutableString stringWithCapacity: [ self size ] ];
   return std::accumulate( self->chunks.begin(), self->chunks.end(), string_, add_to_string );
}

-(void)addBuffer:( const void* )buffer_
          length:( NSUInteger )length_
{
   self->chunks.push_back( chunk_type( buffer_, length_ ) );
}

@end
