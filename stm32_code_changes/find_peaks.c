//This function finds the peaks in the magnitude FFT of the events
#define MIN_PROM 0.3f
#define MIN_WIDTH 2
#define WIDTH_MUL 0.5f

void find_peaks(task_s *task){
	float32_t *x;
	uint32_t	n_data, i, j, pts_left = 0;
	//uint8_t n_peaks = 0;
	float32_t pts_leftover = 0;
	float32_t time_h;
	float32_t min_amp;
	
	uint32_t max_idx = 0;
	float32_t max_amp;
	
	uint8_t cand_flag = 0x00;
	
//	uint32_t peak_idx[16];
//	float32_t peak_amp[16];
	
	//static uint8_t wr_buff[9] = {0};
	
	read_from_buffer((buffer_s *)task->args, &x, 1);
	time_h = x[128]/(100*60*60);
	min_amp = x[10];
	max_amp = 0;
	
	n_data = ((buffer_s *)task->args)->size_elem/4 - 1;
	
	for (i = 10; i < n_data; i++){
		if (x[i] - x[i-1] > 0 && x[i] - x[i+1] > 0) {	//local maximum
			if (x[i] - MIN_PROM > min_amp){							//satisfies left prominence
				max_idx = i;
				max_amp = x[i];
				cand_flag &= 0x00;
				min_amp = x[i] - MIN_PROM;
			}
		}
		if (x[i] - x[i-1] < 0 && x[i] - x[i+1] < 0) {	//local minimum
			if (x[i] < min_amp) {
				min_amp = x[i];
				if (max_amp - MIN_PROM > min_amp)	{				//satisfies right prominence
					if (cand_flag & 2) {										//passed width check already
						//wr_buff[0] = n_peaks++;
						//*(uint32_t *)&wr_buff[1] = max_idx;
						//max_as_int = *(uint32_t *)&max_amp;
						//*(uint32_t *)&wr_buff[5] = *(uint32_t *)&max_as_int;
						//write_to_buffer(&peak_buffer, wr_buff, 0);
						write_to_buffer(&pk_freq_buffer, &fft_freqs[max_idx], 0);
						write_to_buffer(&pk_time_buffer, &time_h, 0);
						cand_flag &= 0x00;
						max_idx = 0;
						max_amp = 0;
					}
					else
						cand_flag |= 1;
				}
			}
		}
		
		if (max_idx != 0 && (x[i] - max_amp*WIDTH_MUL < 1.0f/10000 || i - max_idx == MIN_WIDTH + 1)) {	//got to width or
			pts_leftover = 0;																																						// amp below threshold
			if (i - max_idx < MIN_WIDTH + 1) {
				pts_left = MIN_WIDTH - i + max_idx + 1;
				pts_leftover = (max_amp*WIDTH_MUL - x[i-1])/(x[i] - x[i-1]);
			}

			for (j = 1; j <= pts_left; j++) {
				if (x[max_idx - j] <= max_amp * WIDTH_MUL || x[max_idx - j] >= max_amp) {
					pts_leftover += (max_amp * WIDTH_MUL - x[max_idx - j + 1])/(x[max_idx - j] - x[max_idx - j + 1]);
					break;
				}
				pts_left -= 1;
			}
			if (pts_left - pts_leftover <= 0) {
				if (cand_flag & 0x01) {
					//wr_buff[0] = n_peaks++;
					//*(uint32_t *)&wr_buff[1] = max_idx;
					//max_as_int = *(uint32_t *)&max_amp;
					//*(uint32_t *)&wr_buff[5] = *(uint32_t *)&max_as_int;
					//write_to_buffer(&peak_buffer, wr_buff, 0);
					write_to_buffer(&pk_freq_buffer, &fft_freqs[max_idx], 0);
					write_to_buffer(&pk_time_buffer, &time_h, 0);
					cand_flag &= 0x00;
					max_idx = 0;
					max_amp = 0;
				}
				else
					cand_flag |= 0x02;
			}
			else {
				max_idx = 0;
				max_amp = 0;
				cand_flag &= 0x00;
				min_amp = x[i] - MIN_PROM;
			}
		}
	}
	/*
	if (n_peaks == 0){
		wr_buff[0] = 0;
		*(uint32_t *)&wr_buff[1] = 0;
		*(uint32_t *)&wr_buff[5] = 0;
		write_to_buffer(&peak_buffer, wr_buff, 0);
	}
	*/
}
