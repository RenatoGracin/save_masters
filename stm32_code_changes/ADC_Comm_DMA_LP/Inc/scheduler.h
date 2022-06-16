#include <stdint.h>

#define TASK_QUEUE_LEN 32
#define NEW_QUEUE_LEN 32
#define TASK_QUEUE_OFFS (32-TASK_QUEUE_LEN)

typedef struct task task_s;
typedef struct buffer buffer_s;

//Enum used for return values of init_buffer and write_to_buffer functions
typedef enum {
	BUFF_OK = 1<<0,
	BUFF_FULL = 1<<2,
	BUFF_NO_MEMORY = 1<<3,
	BUFF_OVERWRITE = 1<<4,
}buffer_status_t;

//Conditions for adding tasks when writing to/reading from buffers
typedef enum {
	COND_NEVER = 0,					//Never add the task
	COND_ALWAYS = 1U<<0,			//Add the task whenever buffer is written to
	COND_FULL = 1U<<1,				//Add the task when buffer is full
	COND_HALF_FULL = 1U<<2,	//Add the task when buffer is half full
	COND_EMPTY = 1U<<3,			//Add the task when buffer is empty
	FLAG_COND = 1U<<29,			//A flag used so that COND_HALF_FULL and COND_NUMBER doesn't add the task multiple times before reading
	COND_NUMBER = 1U<<30			//When using COND_NUMBER, task is added when number of elements is equal to the 28 LSB-s of add_task_cond
	
}task_cond_t;

struct task {
	void (*function)(task_s *);	// Pointer to the function called by the task	-> The function must take a pointer to the task as an argument
	void *args;									//Task arguments
	task_s *next;								//Pointer to the next task in the queue
	volatile uint32_t *flag;		//Pointer to the flag used for blocking tasks
	uint32_t mask;							//Tasks are blocking unless mask == flag
	uint8_t priority;						//Task priority, higher number -> higher priority
};

struct buffer {
	uint32_t n_elem;						//Number of elements in the buffer
	uint32_t size_elem;					//Size of elements 
	uint8_t *buff;							//Pointer to the start of allocated memory
	uint8_t *rd_ptr;						//Read pointer
	uint8_t *wr_ptr;						//Write pointer
	uint32_t n_curr;						//Number of elements currently in the buffer
	task_cond_t add_task_cond;	//The condition for adding a task to queue
	task_s task_to_add;					//The task to add when condition is met
};

//Definition of public functions used to interface with queues and tasks

//Initialize the buffer structure and allocate memory for it
buffer_status_t init_buffer(buffer_s *buffer, uint32_t n_elem, uint32_t size_elem, task_s *task_to_add, task_cond_t add_task_cond);

//Read elem_to_read elements from the buffer, *data is modified to point at the first element read
//If elem_to_read is more than the current number of elements, the function only reads that number of elements
//If the read elements would wrap around to the beginning of the buffer, only the ones up to the end of the buffer are read
//If elem_to_read == 0, the function reads as many elements as possible
//The function returns the number of elements actually read
uint32_t read_from_buffer(buffer_s *buffer, void *data, uint32_t elem_to_read);

//Write an element to the buffer
//if *data == NULL, only move the write_ptr and increment n_curr (in case data was written directly, without using the function)
//if rev == 1, reverses the byte order before writing
buffer_status_t write_to_buffer(buffer_s *buffer, void *data_ptr, uint8_t rev);

//Add a task to the queue
void queue_task(task_s task);

//Start the scheduler, this function should never exit
void run_scheduler(void);
