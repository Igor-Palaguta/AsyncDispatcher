#ifndef ASYNC_DISPATCHER_AD_DISPATCH_ARC_DEFS_H_INCLUDED
#define ASYNC_DISPATCHER_AD_DISPATCH_ARC_DEFS_H_INCLUDED

#ifdef OS_OBJECT_USE_OBJC
#define AD_GCD_SUPPORTS_ARC OS_OBJECT_USE_OBJC
#else
#define AD_GCD_SUPPORTS_ARC 0
#endif

#if AD_GCD_SUPPORTS_ARC

#define AD_DISPATCH_RETAIN(object_)
#define AD_DISPATCH_RELEASE(object_)
#define AD_DISPATCH_PROPERTY strong

#else

#define AD_DISPATCH_RETAIN(object_) if (object_) dispatch_retain(object_)
#define AD_DISPATCH_RELEASE(object_) if (object_) dispatch_release(object_)
#define AD_DISPATCH_PROPERTY assign

#endif

#endif
