/*
** Asyncronous
*/
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif

#include "sys.h"
#include "erl_sys_driver.h"
#include "global.h"
#include "erl_threads.h"

EXTERN_FUNCTION(int, async_ready, (int, void*));
extern  int erts_async_max_threads;

typedef struct _erl_async {
    struct _erl_async* next;
    struct _erl_async* prev;
    DE_Handle*         hndl;   /* The DE_Handle is needed when port is gone */
    int                port;
    long               async_id;
    void*              async_data;

    void (*async_invoke)(void*);
    void (*async_free)(void*);
} ErlAsync;

typedef struct {
    ethr_mutex mtx;
    ethr_cond cv;
    ethr_tid thr;
    int   len;
    int   hndl;
    ErlAsync* head;
    ErlAsync* tail;
} AsyncQueue;

static long async_id = 0;


ethr_mutex async_ready_mtx;
static ErlAsync* async_ready_list = NULL;


/*
** Initialize worker threads (if supported)
*/

/* Detach from driver */
static void async_detach(DE_Handle* dh)
{
    if (dh != NULL) {
	dh->ref_count--;
	DEBUGF(("async_detach: ref_count=%d\r\n", dh->ref_count));
	if (dh->ref_count == 0) {
	    if (dh->cb != NULL)
		(*dh->cb)(dh->ca[0],dh->ca[1],dh->ca[2],dh->ca[3]);
	}
    }
}


#ifdef USE_THREADS

static AsyncQueue* async_q;

static void* async_main(void*);
static void async_add(ErlAsync*, AsyncQueue*);

int init_async(int hndl)
{
    AsyncQueue* q;
    int i;

    erts_mtx_init(&async_ready_mtx);
    async_ready_list = NULL;
    async_id = 0;

    async_q = q = (AsyncQueue*)
	(erts_async_max_threads
	 ? erts_alloc(ERTS_ALC_T_ASYNC_Q,
		      erts_async_max_threads * sizeof(AsyncQueue))
	 : NULL);
    for (i = 0; i < erts_async_max_threads; i++) {
	q->head = NULL;
	q->tail = NULL;
	q->len = 0;
	q->hndl = hndl;
	erts_mtx_init(&q->mtx);
	erts_cnd_init(&q->cv);
	erts_thr_create(&q->thr, async_main, (void*)q, 0);
	q++;
    }
    return 0;
}


int exit_async()
{
    int i;

    /* terminate threads */
    for (i = 0; i < erts_async_max_threads; i++) {
	ErlAsync* a = (ErlAsync*) erts_alloc(ERTS_ALC_T_ASYNC,
					     sizeof(ErlAsync));
	a->port = -1;
	async_add(a, &async_q[i]);
    }

    for (i = 0; i < erts_async_max_threads; i++) {
	erts_thr_join(async_q[i].thr, NULL);
	erts_mtx_destroy(&async_q[i].mtx);
	erts_cnd_destroy(&async_q[i].cv);
    }
    erts_mtx_destroy(&async_ready_mtx);
    if (async_q)
	erts_free(ERTS_ALC_T_ASYNC_Q, (void *) async_q);
    return 0;
}


static void async_add(ErlAsync* a, AsyncQueue* q)
{
    if (a->port != -1)
	driver_attach(a->port);  /* make sure the driver will stay around */

    erts_mtx_lock(&q->mtx);

    if (q->len == 0) {
	q->head = a;
	q->tail = a;
	q->len = 1;
	erts_cnd_signal(&q->cv);
    }
    else { /* no need to signal (since the worker is working) */
	a->next = q->head;
	q->head->prev = a;
	q->head = a;
	q->len++;
    }
    erts_mtx_unlock(&q->mtx);
}

static ErlAsync* async_get(AsyncQueue* q)
{
    ErlAsync* a;

    erts_mtx_lock(&q->mtx);
    while((a = q->tail) == NULL) {
	erts_cnd_wait(&q->cv, &q->mtx);
    }
    if (q->head == q->tail) {
	q->head = q->tail = NULL;
	q->len = 0;
    }
    else {
	q->tail->prev->next = NULL;
	q->tail = q->tail->prev;
	q->len--;
    }
    erts_mtx_unlock(&q->mtx);
    return a;
}


static int async_del(long id)
{
    int i;
    /* scan all queue for an entry with async_id == 'id' */

    for (i = 0; i < erts_async_max_threads; i++) {
	ErlAsync* a;
	erts_mtx_lock(&async_q[i].mtx);
	
	a = async_q[i].head;
	while(a != NULL) {
	    if (a->async_id == id) {
		if (a->prev != NULL)
		    a->prev->next = a->next;
		else
		    async_q[i].head = a->next;
		if (a->next != NULL)
		    a->next->prev = a->prev;
		else
		    async_q[i].tail = a->prev;
		async_q[i].len--;
		erts_mtx_unlock(&async_q[i].mtx);
		if (a->async_free != NULL)
		    a->async_free(a->async_data);
		async_detach(a->hndl);
		erts_free(ERTS_ALC_T_ASYNC, a);
		return 1;
	    }
	}
	erts_mtx_unlock(&async_q[i].mtx);
    }
    return 0;
}

static void* async_main(void* arg)
{
    AsyncQueue* q = (AsyncQueue*) arg;

    while(1) {
	ErlAsync* a = async_get(q);

	if (a->port == -1) { /* TIME TO DIE SIGNAL */
	    erts_free(ERTS_ALC_T_ASYNC, (void *) a);
	    break;
	}
	else {
	    (*a->async_invoke)(a->async_data);
	    /* Major problem if the code for async_invoke
	       or async_free is removed during a blocking operation */
	    erts_mtx_lock(&async_ready_mtx);
	    a->next = async_ready_list;
	    async_ready_list = a;
	    erts_mtx_unlock(&async_ready_mtx);

	    sys_async_ready(q->hndl);
	}
    }

    return NULL;
}


#endif



int check_async_ready()
{
    ErlAsync* a;
    int count = 0;

    erts_mtx_lock(&async_ready_mtx);
    a = async_ready_list;
    async_ready_list = NULL;
    erts_mtx_unlock(&async_ready_mtx);

    while(a != NULL) {
	ErlAsync* a_next = a->next;
	count++;
	if (async_ready(a->port, a->async_data)) {
	    if (a->async_free != NULL)
		(*a->async_free)(a->async_data);
	}
	async_detach(a->hndl);
	erts_free(ERTS_ALC_T_ASYNC, (void *) a);
	a = a_next;
    }
    return count;
}

/*
** Schedule async_invoke on a worker thread
** NOTE will be syncrounous when threads are unsupported
** return values:
**  0  completed 
**  -1 error
**  N  handle value (used with async_cancel)
**  arguments:
**      ix             driver index 
**      key            pointer to secedule queue (NULL means round robin)
**      async_invoke   function to run in thread
**      async_data     data to pass to invoke function
**      async_free     function for relase async_data in case of failure
*/
long driver_async(ErlDrvPort ix, unsigned int* key,
		  void (*async_invoke)(void*), void* async_data,
		  void (*async_free)(void*))
{
    ErlAsync* a = (ErlAsync*) erts_alloc(ERTS_ALC_T_ASYNC, sizeof(ErlAsync));
    Port* ptr;
    long id;
    unsigned int qix;

    if ((ix < 0) || (ix >= erts_max_ports) || erts_port[ix].status == FREE)
	return -1;
    ptr = &erts_port[ix];

    a->next = NULL;
    a->prev = NULL;
    a->hndl = (DE_Handle*)ptr->drv_ptr->handle;
    a->port = ix;
    a->async_data = async_data;
    a->async_invoke = async_invoke;
    a->async_free = async_free;

    async_id = (async_id + 1) & 0x7fffffff;
    if (async_id == 0)
	async_id++;
    id = async_id;
    a->async_id = id;

    if (key == NULL) {
	qix = (erts_async_max_threads > 0)
	    ? (async_id % erts_async_max_threads) : 0;
    }
    else {
	qix = (erts_async_max_threads > 0) ? 
	    (*key % erts_async_max_threads) : 0;
	*key = qix;
    }
#ifdef USE_THREADS
    if (erts_async_max_threads > 0) {
	async_add(a, &async_q[qix]);
	return id;
    }
#endif

    (*a->async_invoke)(a->async_data);

    if (async_ready(a->port, a->async_data)) {
	if (a->async_free != NULL)
	    (*a->async_free)(a->async_data);
    }
    erts_free(ERTS_ALC_T_ASYNC, (void *) a);

    return id;
}

int driver_async_cancel(unsigned int id)
{
#ifdef USE_THREADS
    if (erts_async_max_threads > 0)
	return async_del(id);
#endif
    return 0;
}
