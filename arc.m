#import "objc/runtime.h"
#import "objc/blocks_runtime.h"
#import "nsobject.h"
#import "selector.h"

static Class AutoreleasePool;
static IMP NewAutoreleasePool;
static IMP DeleteAutoreleasePool;

void *objc_autoreleasePoolPush(void)
{
	// TODO: This should be more lightweight.  We really just need to allocate
	// an array here...
	if (Nil == AutoreleasePool)
	{
		AutoreleasePool = objc_getRequiredClass("NSAutoreleasePool");
		NewAutoreleasePool = class_getMethodImplementation(
				object_getClass(AutoreleasePool),
				SELECTOR(new));
		DeleteAutoreleasePool = class_getMethodImplementation(
				object_getClass(AutoreleasePool),
				SELECTOR(release));
	}
	return NewAutoreleasePool(AutoreleasePool, SELECTOR(new));
}
void objc_autoreleasePoolPop(void *pool)
{
	// TODO: Keep a small pool of autorelease pools per thread and allocate
	// from there.
	DeleteAutoreleasePool(pool, SELECTOR(release));
}

id objc_autorelease(id obj)
{
	return [obj autorelease];
}

id objc_autoreleaseReturnValue(id obj)
{
	// TODO: Fast path for allowing this to be popped from the pool.
	return [obj autorelease];
}

id objc_retain(id obj)
{
	return [obj retain];
}

id objc_retainAutorelease(id obj)
{
	return objc_autorelease(objc_retain(obj));
}

id objc_retainAutoreleaseReturnValue(id obj)
{
	return objc_autoreleaseReturnValue(objc_retain(obj));
}

id objc_retainAutoreleasedReturnValue(id obj)
{
	// TODO: Fast path popping this from the autorelease pool
	return objc_retain(obj);
}

id objc_retainBlock(id b)
{
	return _Block_copy(b);
}

void objc_release(id obj)
{
	[obj release];
}

id objc_storeStrong(id *object, id value)
{
	value = [value retain];
	id oldValue = *object;
	*object = value;
	[oldValue release];
	return value;
}
