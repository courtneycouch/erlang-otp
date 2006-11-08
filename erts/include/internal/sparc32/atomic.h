/*
 * Native ethread atomics on SPARC V9.
 * Author: Mikael Pettersson.
 */
#ifndef ETHR_SPARC32_ATOMIC_H
#define ETHR_SPARC32_ATOMIC_H

typedef struct {
    volatile int value;
} ethr_native_atomic_t;

static ETHR_INLINE void
ethr_native_atomic_init(ethr_native_atomic_t *a, int i)
{
    a->value = i;
}
#define ethr_native_atomic_set(v, i)	ethr_native_atomic_init((v), (i))

static ETHR_INLINE int
ethr_native_atomic_read(ethr_native_atomic_t *a)
{
    return a->value;
}

static ETHR_INLINE int
ethr_native_atomic_add_return(ethr_native_atomic_t *a, int incr)
{
    int old, tmp;

    __asm__ __volatile__("membar #LoadLoad|#StoreLoad\n");
    do {
	old = a->value;
	tmp = old+incr;
	__asm__ __volatile__(
	    "cas [%2], %1, %0"
	    : "=&r"(tmp)
	    : "r"(old), "r"(&a->value), "0"(tmp)
	    : "memory");
    } while (__builtin_expect(old != tmp, 0));
    __asm__ __volatile__("membar #StoreLoad|#StoreStore");
    return old+incr;
}   
    
static ETHR_INLINE void
ethr_native_atomic_add(ethr_native_atomic_t *a, int incr)
{
    (void)ethr_native_atomic_add_return(a, incr);
}   
    
static ETHR_INLINE int
ethr_native_atomic_inc_return(ethr_native_atomic_t *a)
{
    return ethr_native_atomic_add_return(a, 1);
}

static ETHR_INLINE void
ethr_native_atomic_inc(ethr_native_atomic_t *a)
{
    (void)ethr_native_atomic_add_return(a, 1);
}

static ETHR_INLINE int
ethr_native_atomic_dec_return(ethr_native_atomic_t *a)
{
    return ethr_native_atomic_add_return(a, -1);
}

static ETHR_INLINE void
ethr_native_atomic_dec(ethr_native_atomic_t *a)
{
    (void)ethr_native_atomic_add_return(a, -1);
}

static ETHR_INLINE int
ethr_native_atomic_and_retold(ethr_native_atomic_t *a, int mask)
{
    int old, tmp;

    __asm__ __volatile__("membar #LoadLoad|#StoreLoad\n");
    do {
	old = a->value;
	tmp = old & mask;
	__asm__ __volatile__(
	    "cas [%2], %1, %0"
	    : "=&r"(tmp)
	    : "r"(old), "r"(&a->value), "0"(tmp)
	    : "memory");
    } while (__builtin_expect(old != tmp, 0));
    __asm__ __volatile__("membar #StoreLoad|#StoreStore");
    return old;
}   
    
static ETHR_INLINE int
ethr_native_atomic_or_retold(ethr_native_atomic_t *a, int mask)
{
    int old, tmp;

    __asm__ __volatile__("membar #LoadLoad|#StoreLoad\n");
    do {
	old = a->value;
	tmp = old | mask;
	__asm__ __volatile__(
	    "cas [%2], %1, %0"
	    : "=&r"(tmp)
	    : "r"(old), "r"(&a->value), "0"(tmp)
	    : "memory");
    } while (__builtin_expect(old != tmp, 0));
    __asm__ __volatile__("membar #StoreLoad|#StoreStore");
    return old;
}   
    
static ETHR_INLINE int
ethr_native_atomic_xchg(ethr_native_atomic_t *a, int val)
{
    int old, new;
    
    __asm__ __volatile__("membar #LoadLoad|#StoreLoad");
    do {
	old = a->value;
	new = val;
	__asm__ __volatile__(
	    "cas [%2], %1, %0"
	    : "=&r"(new)
	    : "r"(old), "r"(&a->value), "0"(new)
	    : "memory");
    } while (__builtin_expect(old != new, 0));
    __asm__ __volatile__("membar #StoreLoad|#StoreStore");
    return old;
}   
    
#endif /* ETHR_SPARC32_ATOMIC_H */