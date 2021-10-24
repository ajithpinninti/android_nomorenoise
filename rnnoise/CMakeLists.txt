cmake_minimum_required(VERSION 3.10)
set(RN_NOISE_SRC
        denoise.c
        celt_lpc.c
        pitch.c
        rnn.c
        rnn_data.c
        kiss_fft.c
        rnn_reader.c
        running_rnnoise.c
        )
include_directories("../include")
add_library(rnnoise SHARED ${RN_NOISE_SRC})


