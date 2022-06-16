#include <scheduler.h>
#ifndef WINDOWS_TESTING
#include "stm32l4xx_hal.h"
#else
#include <stdio.h>
#define __STATIC_FORCEINLINE                   __attribute__((always_inline)) static __inline

/**
  \brief   Reverse byte order (32 bit)
  \details Reverses the byte order in unsigned integer value. For example, 0x12345678 becomes 0x78563412.
  \param [in]    value  Value to reverse
  \return               Reversed value
 */
#define __REV(value)   __builtin_bswap32(value)


/**
  \brief   Reverse byte order (16 bit)
  \details Reverses the byte order within each halfword of a word. For example, 0x12345678 becomes 0x34127856.
  \param [in]    value  Value to reverse
  \return               Reversed value
 */
#define __REV16(value) __ROR(__REV(value), 16)


/**
  \brief   Reverse byte order (16 bit)
  \details Reverses the byte order in a 16-bit value and returns the signed 16-bit result. For example, 0x0080 becomes 0x8000.
  \param [in]    value  Value to reverse
  \return               Reversed value
 */
#define __REVSH(value) (int16_t)__builtin_bswap16(value)

/**
  \brief   Rotate Right in unsigned value (32 bit)
  \details Rotate Right (immediate) provides the value of the contents of a register rotated by a variable number of bits.
  \param [in]    op1  Value to rotate
  \param [in]    op2  Number of Bits to rotate
  \return               Rotated value
 */
__STATIC_FORCEINLINE uint32_t __ROR(uint32_t op1, uint32_t op2)
{
  op2 %= 32U;
  if (op2 == 0U)
  {
    return op1;
  }
  return (op1 >> op2) | (op1 << (32U - op2));
}
#endif
#include <stdlib.h>

//Private function definitions

void queue_task(task_s task);
void check_new(void);
void new_to_queue(task_s *new_task);
void check_blocking(void);
void block_task(void);


task_s task_queue[TASK_QUEUE_LEN], *new_tasks[NEW_QUEUE_LEN];
uint8_t new_write_idx = 0;
task_s *current = NULL, *blocking = NULL;
// Binary mask of task queue which has ones where there is an empty spot
// Most significant bit represents first element of task queue
uint32_t free_tasks = 0xFFFFFFFF << TASK_QUEUE_OFFS; 	//Za svako mjesto u Queue-u jedan bit


//Tasks are first added to the new_tasks queue to avoid problems with adding tasks while scheduling is in progress
void queue_task(task_s task){
	if (free_tasks == 0){
		return;
	}
	task_s *first_free;
	// __clz counts number of leading zeros od data value
	// __clz(free_tasks) gets you index of next avaliable spot in task list
    // first_free is pointer to first avaliable element in task list
#ifdef WINDOWS_TESTING
	new_tasks[new_write_idx] = first_free = &task_queue[__builtin_clz(free_tasks)];
#else
	new_tasks[new_write_idx] = first_free = &task_queue[__clz(free_tasks)];
#endif
	// Uses pointer subtraction confusion to get index of first free task in task queue 
	// Sets the first avaliable spot in list to zero to mark it as unavaliable
	free_tasks &= ~(0x01 <<(TASK_QUEUE_LEN - 1 - (first_free - task_queue)));
	// Appends given task to task list on the first available spot
	*first_free = task;
	new_write_idx = (new_write_idx + 1)%NEW_QUEUE_LEN;
}

//At the beginning of scheduling, all the tasks from new_tasks are added to either the current or blocking list 
void check_new(){
	static uint8_t read_idx = 0;
	uint8_t write_idx;
	write_idx = new_write_idx; //copy in case it changes during execution

	// Adds all tasks from new task list to blocking or current list
	while(read_idx != write_idx){
		printf("read_idx: %d",read_idx);
		new_to_queue(new_tasks[read_idx]);
		read_idx = (read_idx+1)%NEW_QUEUE_LEN;
	}
	return;
}

void new_to_queue(task_s *new_task){
	task_s **list_ptr; // List of tasks
	task_s *task_ptr; // Task being processed

	// When task is enabled by flag get list of currently waiting tasks
	if((*new_task->flag & new_task->mask) == new_task->mask)
		list_ptr = &current;
	// When task is not enabled by flag get list of currently blocked tasks
	else
		list_ptr = &blocking;

	// Get first task from task list
	task_ptr = *list_ptr;
	
	// If task list is empty or new task has higher priority than first task in list 
	if (task_ptr == NULL || (new_task->priority > task_ptr->priority)){
		// Set new task as first task of task list
		new_task->next = task_ptr;
		*list_ptr = new_task;
	}
	// When task list is not empty and new task has lower priority than first task in list
	else {
		// Iterate over task list until next task has lower priority than the new task or there is no next task
		while (task_ptr->next != NULL && task_ptr->next->priority >= new_task->priority) { 
			task_ptr = task_ptr->next;
		}
		// Put new task inside list after all tasks with higher or equal priority
		new_task->next = task_ptr->next;
		task_ptr->next = new_task;
	}
}

//Move tasks from the blocking queue to the current queue
void check_blocking(){
	task_s *blocking_ptr = blocking, *temp_ptr;
	// If there are no blocked tasks -> return
	if (blocking_ptr == NULL)
		return;
	// If there are no currently running tasks or blocked task has higher priority than current task
	else if (current == NULL || blocking->priority > current->priority) {		//If the 1st one in the queue is ready
		// If 1st task in the blocked queue is ready
		if ((*(blocking_ptr->flag) & blocking_ptr->mask) == blocking_ptr->mask){
			// Remove 1st blocked task from blocking queue
			blocking = blocking_ptr->next;
			// Add 1st blocked task at 1st place of running queue
			blocking_ptr->next = current;
			current = blocking_ptr;
			return;
		}
		// When first task od blocking queue is not ready (is blocked)
		// Find blocking task with higher priority than current task which is ready to be run
		while(blocking_ptr->next != NULL && (current == NULL || blocking_ptr->next->priority > current->priority)) {
			if ((*(blocking_ptr->next->flag) & blocking_ptr->next->mask) == blocking_ptr->next->mask){
				temp_ptr = blocking_ptr->next->next;
				blocking_ptr->next->next = current;
				current = blocking_ptr->next;
				blocking_ptr->next = temp_ptr;
				return;
			}
			blocking_ptr = blocking_ptr->next;
		}
	}
}

//Move tasks from the current queue to the blocking queue
void block_task(){
	task_s *blocking_ptr = blocking;
	task_s *current_ptr = current;
	current = current->next;
	// When blocking queue is empty put current task at first place
	if (blocking_ptr == NULL){
		blocking = current_ptr;
		blocking->next = NULL;
	}
	// Put current task in blocking queue behind tasks with higher or equal priority
	else if (current_ptr->priority > blocking_ptr->priority){
		current_ptr->next = blocking_ptr;
		blocking = current_ptr;
	}
	else {
		while(blocking_ptr->next != NULL && current_ptr->priority <= blocking_ptr->next->priority)
			blocking_ptr = blocking_ptr->next;
		current_ptr->next = blocking_ptr->next;
		blocking_ptr->next = current_ptr;
	}
}

//The scheduler calls the functions of the tasks from the current queue
//If there are no tasks that are ready to run, the mcu goes to sleep
void run_scheduler(){
	uint8_t sleep = 0;
	uint32_t current_spot = 0;
	for(;;){
		// If there are no tasks on the current queue, go to sleep
		if(sleep) {
#ifndef WINDOWS_TESTING
			HAL_SuspendTick();
			EXTI->PR1 = 0xFF;
			HAL_PWR_EnterSLEEPMode(PWR_MAINREGULATOR_ON,PWR_SLEEPENTRY_WFI);	
			__NOP();
			HAL_PWREx_DisableLowPowerRunMode();
			HAL_ResumeTick();
#else
			while(1);
#endif
			sleep = 0;
		}
		check_new();								//Add all the tasks from new_tasks to the current and blocking queues
		check_blocking();							//If a task of higher priority is in the blocking queue, and if it is ready to run, add it to the current queue
		while(current != NULL && (*current->flag & current->mask) != current->mask)
			block_task();							//if the current task is blocking, add it to the blocking queue
		if (current == NULL){
			sleep = 1;									//if there are no tasks on the current queue, go to sleep
			continue;
		}
		current->function(current);																		//Call the function of the current tasks	
		current_spot = TASK_QUEUE_LEN - 1 - (current - task_queue); 	//Spot in the free_tasks flag
		current = current->next;																			//Advance to the next task in the queue
		free_tasks |= 0x01 << (current_spot);													//Mark the spot in the task_queue as free
	}
}


//Public functions

buffer_status_t init_buffer(buffer_s *buffer, uint32_t n_elem, uint32_t size_elem, task_s *task_to_add, task_cond_t add_task_cond){
	buffer->n_elem = n_elem;
	buffer->size_elem = size_elem;
	buffer->buff = (uint8_t *)malloc(n_elem*size_elem);
	buffer->rd_ptr = buffer->wr_ptr = buffer->buff;
	buffer->add_task_cond = add_task_cond;
	buffer->n_curr = 0;
	if (add_task_cond)
		buffer->task_to_add = *task_to_add;
	return BUFF_OK;
	
}

uint32_t read_from_buffer(buffer_s *buffer, void *data, uint32_t elem_to_read){
	uint32_t elem_read = 0;
	
	if (buffer->n_curr == 0)
		return 0;
	
	*(uint8_t **)data = buffer->rd_ptr;

	if (buffer->rd_ptr > buffer->wr_ptr){
		if (elem_to_read == 0 || buffer->rd_ptr + elem_to_read*buffer->size_elem >= buffer->buff + buffer->n_elem*buffer->size_elem){
			elem_read = (buffer->buff + buffer->n_elem*buffer->size_elem - buffer->rd_ptr)/buffer->size_elem;
			buffer->rd_ptr = buffer->buff;
		}
		else {
			buffer->rd_ptr += elem_to_read*buffer->size_elem;
			elem_read = elem_to_read;
		}
	}
	else {
		if (elem_to_read == 0 || buffer->rd_ptr + elem_to_read*buffer->size_elem >= buffer->wr_ptr){
			elem_read = (buffer->wr_ptr - buffer->rd_ptr)/buffer->size_elem;
			buffer->rd_ptr = buffer->wr_ptr;
		}
		else {
			buffer->rd_ptr += elem_to_read*buffer->size_elem;
			elem_read = elem_to_read;
		}
	}

	buffer->n_curr -= elem_read;
	
	if ((buffer->add_task_cond & COND_NUMBER) == 0){
		if (buffer->add_task_cond & COND_EMPTY && buffer->rd_ptr == buffer->wr_ptr)
			queue_task(buffer->task_to_add); 
	}
	if (buffer->add_task_cond & FLAG_COND)
		buffer->add_task_cond &= ~FLAG_COND;
	
	return elem_read;
}

buffer_status_t write_to_buffer(buffer_s *buffer, void *data_ptr, uint8_t rev){	//if *data = NULL, only move the write ptr etc.
	uint32_t words_to_copy = buffer->size_elem/4;
	uint32_t hfwords_to_copy = (buffer->size_elem%4)/2;
  	uint32_t bytes_to_copy = buffer->size_elem%2;
	uint8_t *data = (uint8_t *)data_ptr;
	buffer_status_t retval = BUFF_OK;
	
	if (data != NULL){
		for(;words_to_copy > 0; words_to_copy--){
			if (rev)
				*(uint32_t *)buffer->wr_ptr = __REV16(*(uint32_t *)data);
			else
				*(uint32_t *)buffer->wr_ptr = *(uint32_t *)data;
			buffer->wr_ptr += 4;
			data += 4;
		}
		for(;hfwords_to_copy > 0; hfwords_to_copy--){
			if (rev)
				*(uint16_t *)buffer->wr_ptr = __REVSH(*(uint16_t *)data);
			else
				*(uint16_t *)buffer->wr_ptr = *(uint16_t *)data;
			buffer->wr_ptr += 2;
			data += 2;
		}
		for(;bytes_to_copy;bytes_to_copy--){
			*buffer->wr_ptr = *(uint8_t *)data;
			buffer->wr_ptr ++;
			data ++;
		}
	}
	else
		buffer->wr_ptr += buffer->size_elem;
	
	if(buffer->n_curr == buffer->n_elem)
		retval = BUFF_OVERWRITE;
	else
		buffer->n_curr++;
	if (buffer->add_task_cond & COND_NUMBER){
		if ((buffer->add_task_cond & FLAG_COND) == 0 && buffer->n_curr >= (buffer->add_task_cond & 0x3FFFFFFF)){
			buffer->add_task_cond |= FLAG_COND;
			queue_task(buffer->task_to_add);
		}
	}	
	else {
		if (buffer->add_task_cond & COND_ALWAYS)
			queue_task(buffer->task_to_add);
		else if(buffer->add_task_cond & COND_FULL && buffer->n_curr == buffer->n_elem)
			queue_task(buffer->task_to_add);
		else if ( buffer->add_task_cond & COND_HALF_FULL && (buffer->add_task_cond & FLAG_COND) == 0 && buffer->n_curr >= buffer->n_elem/2){
			buffer->add_task_cond |= FLAG_COND;
			queue_task(buffer->task_to_add);
		}
	}
	if (buffer->wr_ptr - buffer->buff == buffer->n_elem*buffer->size_elem)
		buffer->wr_ptr = buffer->buff;
	
	if (buffer->n_curr == buffer->n_elem)
		retval = BUFF_FULL;
	return retval;
}
