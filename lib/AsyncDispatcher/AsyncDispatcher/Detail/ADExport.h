#ifndef ASYNC_DISPATCHER_AD_EXPORT_H_INCLUDED
#define ASYNC_DISPATCHER_AD_EXPORT_H_INCLUDED

#if !defined(AD_EXPORT)
#  if defined(__cplusplus)
#    define AD_EXPORT extern "C"
#  else
#    define AD_EXPORT extern
#  endif
#endif

#endif
