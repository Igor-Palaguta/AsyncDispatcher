#import "ADSaxHandler.h"

@implementation NSObject (ADSaxHandler)

-(void)didFailWithError:( NSError* )error_
{
}

-(void)didComplete
{
}

-(void)didStartElementWithName:( const ADXMLChar* )name_
                    attributes:( const ADXMLChar** )attributes_
{
}

-(void)didEndElementWithName:( const ADXMLChar* )name_
{
}

-(void)didFoundCharacters:( const ADXMLChar* )characters_
               withLength:( int )length_
{
}

-(void)didStartDocument
{
}

-(void)didEndDocument
{
}

@end
